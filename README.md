# bluetoothctl-autoconnector
A tool for bluetoothctl to connect any device automatically.

## Usage
### Create a list
Add Bluetooth adapters’ MAC addresses and devices’ MAC addresses to `list` file.

Copy `list.sample` as `list`.

```shell
$ cp list.sample list
```

Then replace it with your own environment.

### Execute the script
Execute `autoconnector.sh` to connect all devices in `list` file. You need to pair and trust all devices before executing the script.

```shell
$ ./autoconnector.sh
```

Or, you can use crontab to connect all devices automatically. `cron.conf` in this repository attempts to connect the devices every minute if not connected.

```shell
$ crontab cron.conf
```
