# bluetoothctl-autoconnector
A tool for bluetoothctl to connect all/any devices automatically.

## Standalone
bluetoothctl attempts to connect all paired Bluetooth devices only once.
```shell
$ ./autoconnector.sh
```

It can also attempt to connect only specific devices.
```shell
$ ./autoconnector.sh -f <MAPPING_LIST_FILE>
```
For details on how to write a mapping list file, see `list.sample`.

## Register crontab
```shell
$ ./setup.sh
```
crontab will execute `autoconnector.sh` every minute. This will reconnect to paired Bluetooth devices automatically even if they disconnect from a computer, and keep connecting them.
