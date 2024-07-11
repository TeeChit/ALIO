#!/vendor/bin/sh

USB_UPDATE_FLAG="/sys/kernel/usb_update"
log -p e -t USB_UPDATE "start check to reboot to usb update mode"
while true
do
	if [ -e  $USB_UPDATE_FLAG ]; then
		log -p e -t USB_UPDATE "try to reboot to usb update mode"
		setprop sys.powerctl reboot,usbupdate
		sleep 5
	fi
	sleep 1
done