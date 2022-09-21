## Installation
TBA

## Usage
### Create an alias file
At first, you need to create an alias file called `~/.marlin_aliases`, and add your Bluetooth device address and device alias paired like this:

```shell
# ~/.marlin_aliases

XX:XX:XX:XX:XX:XX iPhone
YY:YY:YY:YY:YY:YY MacBook
ZZ:ZZ:ZZ:ZZ:ZZ:ZZ Oculus Quest
```

A portion of alias can be set whatever you like so that you can be easy to understand what device is later.

### Register
This subcommand pairs your Bluetooth device to your Linux device.

```shell
marlin register iPhone
```

Your iPhone should be paired to your Linux device like Raspberry Pi after performing the command above.

### Connect
This subcommand connects your Bluetooth device with your Linux device.

```shell
marlin connect iPhone
```

Your iPhone should be connected to your Linux device.

The `connect` subcommand is not a marlin's one, but in that case, it is passed to `bluetoothctl` command as is. For the same reason, you can also use `disconnect`, `remove`, etc.

For details on the command list of `bluetoothctl`, refer to [here (for English readers)](https://www.makeuseof.com/manage-bluetooth-linux-with-bluetoothctl/) or [here (for Japanese readers)](https://zenn.dev/noraworld/articles/bluetoothctl-commands).

### List
This subcommand shows all the devices you paired.

```shell
marlin list
```

### Alias
This subcommand shows all the aliases you set in `~/.marlin_aliases`.

```shell
marlin alias
```

### Info
This subcommand shows a specific device's information.

```shell
marlin info iPhone
```

### Others
There are more it can do for you. To see all the usages, use the `--help` option.

```shell
marlin --help
```











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

Use `./autoconnector.sh -h` for more information.

## Register crontab
```shell
$ ./setup.sh
```
crontab will execute `autoconnector.sh` every minute. This will reconnect paired Bluetooth devices automatically even if they disconnect from a computer, and keep connecting them.

## Motivation for making this tool
I’m using this tool on Ubuntu on Raspberry Pi, and I’m using my Raspberry Pi as Bluetooth audio receiver and mixer.

I always put in my Bluetooth headphone even though I don’t listen anything. Sometimes I’m listening something on iPhone and at other times I’m listening something on MacBook or TV.

I strongly think it’s hassle to switch Bluetooth connections every time I change the devices playing sounds. Then I came up with a good idea.

I connect all devices that play sounds with Raspberry Pi as audio profile (A2DP) instead of my Bluetooth headphone, mix up the sounds on Raspberry Pi, and transmit them to my Bluetooth headphone. And then, yay! Congratulations! I can now listen to sounds played on iPhone, MacBook and TV at the same time without switching Bluetooth connections.

This system is awesome for me, but the devices that play sounds are not always connecting with Raspberry Pi. I take my iPhone outside, then it disconnects from Raspberry Pi. MacBook sleeps or shutdowns, then it disconnects from Raspberry Pi in the same way. So I wanted to reconnect them with Raspberry Pi automatically when they is connectable even if they disconnect from it, and keep connecting. That’s why I made this tool.

## Troubleshooting
### Failed to create secure directory
#### Problem
An error occurs like this.
```
Failed to create secure directory (/run/user/1000/pulse/): No such file or directory
```

#### Solution
Restart PulseAudio daemon and system.
```shell
systemctl --user restart pulseaudio
sudo reboot
```
