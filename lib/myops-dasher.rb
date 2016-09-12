class MyOpsDasher < ::Rails::Railtie
  initializer 'myops.dasher.initialize' do
    require 'my_ops/notifiers/dasher'
  end
end
