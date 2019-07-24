# Qualcomm LTE
Get my LTE Modem working


## 1. Hardware
The main problem was to use this modem which is a Qualcomm MDM9200, but is an OEM modem and is not recognized by Linux Kernel module.

If you are in the same situation, lsusb and usb-devices command are your friend, then the thing is to bind the correct driver to the right device :

```
# rc.local LTE Modem Custom
#
modprobe qmi_wwan
echo "0408 ea24" > /sys/bus/usb/drivers/qmi_wwan/new_id
echo "3-1:1.2" > /sys/bus/usb/drivers/qmi_wwan/unbind
echo "3-1:1.3" > /sys/bus/usb/drivers/qmi_wwan/unbind
echo "3-1:1.3" > /sys/bus/usb/drivers/qmi_wwan/bind
#
modprobe option
echo "0408 ea24" > /sys/bus/usb-serial/drivers/option1/new_id
#
```

1) Load the driver QMI
2) Say to the Linux module to load this driver against this particular device identified by its VID/PID
3) Because the linux driver does not load correctly for this device and subdevices 0-3. Lets unbind sub 2 and 3
4) Just bind device 3 which is the right one who has to get qmi_wwan capabilities
5) Load option driver
6) Bind option driver to the device, it will fill up all remaining subdevice, which is correct.

It will give the following result :

```
[   26.360930] usbcore: registered new interface driver cdc_wdm
[   26.375129] usbcore: registered new interface driver qmi_wwan
[   26.379096] qmi_wwan: probe of 3-1:1.0 failed with error -22
[   26.381149] qmi_wwan: probe of 3-1:1.1 failed with error -22
[   26.383477] qmi_wwan 3-1:1.2: cdc-wdm0: USB WDM device
[   26.384573] qmi_wwan 3-1:1.2 wwan0: register 'qmi_wwan' at usb-1c1b000.usb-1, WWAN/QMI device, ea:74:09:b8:f6:26
[   26.389879] qmi_wwan 3-1:1.3: cdc-wdm1: USB WDM device
[   26.391286] qmi_wwan 3-1:1.3 wwan1: register 'qmi_wwan' at usb-1c1b000.usb-1, WWAN/QMI device, ea:74:09:b8:f6:26
[   26.394398] qmi_wwan 3-1:1.2 wwan0: unregister 'qmi_wwan' usb-1c1b000.usb-1, WWAN/QMI device
[   26.417865] qmi_wwan 3-1:1.3 wwan1: unregister 'qmi_wwan' usb-1c1b000.usb-1, WWAN/QMI device
[   26.468041] qmi_wwan 3-1:1.3: cdc-wdm0: USB WDM device
[   26.469233] qmi_wwan 3-1:1.3 wwan0: register 'qmi_wwan' at usb-1c1b000.usb-1, WWAN/QMI device, ea:74:09:b8:f6:26
[   26.487117] usbcore: registered new interface driver usbserial_generic
[   26.487204] usbserial: USB Serial support registered for generic
[   26.510503] usbcore: registered new interface driver option
[   26.510585] usbserial: USB Serial support registered for GSM modem (1-port)
[   26.519928] option 3-1:1.0: GSM modem (1-port) converter detected
[   26.523713] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB0
[   26.524219] option 3-1:1.1: GSM modem (1-port) converter detected
[   26.529936] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB1
[   26.530406] option 3-1:1.2: GSM modem (1-port) converter detected
[   26.531751] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB2'
```

Some QMI Cli command to help check the modem status :
```
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-ids
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-revision
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-model
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-manufacturer
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --get-wwan-iface
qmicli --device=/dev/cdc-wdm0 --get-expected-data-format
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --wda-get-data-format
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-get-operating-mode
#
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --nas-get-signal-strength
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --nas-get-signal-info
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --nas-get-home-network
#
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-uim-verify-pin=PIN,0000
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --uim-get-card-status
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --nas-get-system-selection-preference
qmicli --device=/dev/cdc-wdm0 --device-open-proxy --dms-uim-set-pin-protection=PIN,enable,0000
```

If all, or most of all are working then the modem is recognized as it should and we can go further :
```
mmcli -L      # List recognized modem
mmcli -m 0    # Give detailed information about modem index 0
```
The lines above to check if the modem is corectly seen by the system.

If OK, just play around the NetworkManager to create a new connection profile. It should be easy as the modem is correctly detected.

```
nmcli connection edit type gsm con-name "My GPRS Connection"
nmcli> print
nmcli> set connection.interface-name cdc-wdm0                   # "Primary Port" when doing mmcli -m 0 
nmcli> set gsm.pin 0000
nmcli> set connection.autoconnect yes
nmcli> set gsm.apn bestone.com
```

The connection is now created ans in autoconnect mode so it should already be is state connected :
```
nmcli conn show                                   # Display connection status
nmcli conn up "My GPRS Connection"                # Activate connection (if not autoconnect mode)
nmcli conn down "My GPRS Connection"              # Disable connection
```
```
mmcli -b 0    # Give detailed information about bearer index 0 (Ip information, LTE network, etc...)
```

## 2. Software, Security and Routing
Then, as my project is to make this modem working on a small OrangePi zero, and to connect it to my home network I will add a part of well known IP forwarding and IPTables.

sysctl.conf
```

```

iptables IPV4 ruleset
```

```

iptables IPV6 is dropping all. Will see IPV6 later.


## 3. Monitoring system and LTE


