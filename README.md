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
I am using this tool on Ubuntu on Raspberry Pi, and I am using my Raspberry Pi for Bluetooth receiver and Bluetooth audio mixer.

I always put in my Bluetooth headphone even though I don’t listen to music. Sometimes I’m listening something on iPhone and at other times I’m listening something on MacBook or TV.

I strongly believe it’s hassle to switch Bluetooth connections every time I change the devices playing sounds. Then I came up with a good idea.

I connect all devices that play sounds with Raspberry Pi as audio profile (A2DP) instead of my Bluetooth headphone, mix up the sounds, and transmit them to my Bluetooth headphone. And then, yay! Congratulations! I can now listen to sounds played on iPhone, MacBook and TV at the same time without switching Bluetooth connections.

This system is awesome for me, but the devices that play sounds not always connects with Raspberry Pi. I take my iPhone outside, then it disconnects from Raspberry Pi. MacBook sleeps or shutdowns, then it disconnects from Raspberry Pi in the same way. So I wanted to keep connecting them with Raspberry Pi even if they disconnect from it. That’s why I make this tool.
