require 'moonrope_client'

module MyOps
  module Notifiers

    class Dasher < MyOps::Notifier
      def collection_trigger_change(collection)
        DasherUpdateJob.queue
      end
    end

    class DasherUpdateJob < ApplicationJob
      def perform
        # Update OK services
        ok_services = Collection.where(:current_trigger_id => nil, :error_code => nil).count
        client.squares.update_property(:square => "#{config.screen}.#{config.square}", :key => 'quantity_ok', :value => ok_services)

        # Update warning services
        warning_services = Collection.includes(:current_trigger).references(:current_trigger).order(:trigger_last_updated_at => :desc).where("triggers.color != 'Red'")
        client.squares.update_property(:square => "#{config.screen}.#{config.square}", :key => 'quantity_warning', :value => warning_services.size)

        # Update critical services
        critical_services = Collection.includes(:current_trigger).references(:current_trigger).order(:trigger_last_updated_at => :desc).where("triggers.color = 'Red'")
        client.squares.update_property(:square => "#{config.screen}.#{config.square}", :key => 'quantity_critical', :value => critical_services.size)

        # Update the list of issues to the screen
        list_items = []
        (critical_services + warning_services).each do |collection|
          list_items << {
            :identifier => collection.id.to_s,
            :properties => {
              :category => collection.status == 'Red' ? 'critical' : 'warning',
              :timestamp => collection.trigger_last_updated_at.to_i,
              :details => "*#{collection.server.hostname}:* #{collection.message}"
            }
          }
        end
        client.lists.replace(:square => "#{config.screen}.#{config.square}", :items => list_items)
      end

      private

      def config
        MyOps.module_config['myops-dasher']
      end

      def client
        @client ||= begin
          headers = {'X-Auth-Token' => config.api_key}
          MoonropeClient::Connection.new("dasher.tv", :headers => headers, :ssl => true)
        end
      end

    end
  end
end
