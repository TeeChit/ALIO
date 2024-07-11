#!/vendor/bin/sh
SENSOR_ACCESS=$1
echo "set sensor registry access"
if [ $SENSOR_ACCESS = "system" ]; then
	chown -R $SENSOR_ACCESS:$SENSOR_ACCESS /mnt/vendor/persist/sensors/
elif [ $SENSOR_ACCESS = "root" ]; then
	chown -R $SENSOR_ACCESS:$SENSOR_ACCESS /mnt/vendor/persist/sensors/registry/registry/
fi
