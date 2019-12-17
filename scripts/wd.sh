#!/bin/bash
echo 1 > /sys/devices/virtual/hwmon/hwmon5/pwm1_enable
echo 1 > /sys/devices/virtual/hwmon/hwmon5/pwm2_enable
echo 254 > /sys/devices/virtual/hwmon/hwmon5/pwm1
echo 254 > /sys/devices/virtual/hwmon/hwmon5/pwm2
