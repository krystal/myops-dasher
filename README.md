# MyOps Dasher

This module will update a Dasher screen to contain a list of current issues using the Service Status square-type in Dasher. Once installed, each time something is triggered for a collection, the screen will be refreshed with the latest information.

## Installation

Add `myops-dasher` plus required configuration to your MyOps configuration file at `/opt/myops/config/myops.yml`.

```yaml
modules:
  -
    name: myops-dasher
    config:
      api_key: abc123abc123abc123abc
      screen: main
      square: status
```

Once, you've done this you can update the modules the application and restart it.

```
$ myops update-modules
$ myops restart
```
