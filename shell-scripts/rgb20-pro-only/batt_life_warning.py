#!/usr/bin/env python3

##################################################################
# Created by Christian Haitian.                                  #
# Python script to turn the Red LED on                           #
# when charge level left is below or equal to 20 percent         #
# Red LED will flash when the charge level is below or           #
# equal to 10 percent.                                           #
##################################################################

import time

batt_life = "/sys/class/power_supply/battery/capacity"
red_led = "/sys/class/leds/Red LED/brightness"

while(True):
        if int(open(batt_life, "r").read()) <= 10:
                if int(open(red_led, "r").read()) == 0:
                        f = open(red_led, "w")
                        f.write("1")
                        f.close()
                        time.sleep(1)
                else:
                        f = open(red_led, "w")
                        f.write("0")
                        f.close()
                        time.sleep(1)

        elif int(open(batt_life, "r").read()) <= 20:
                if int(open(red_led, "r").read()) == 0:
                        f = open(red_led, "w")
                        f.write("1")
                        f.close()
                        time.sleep(30)
        else:
                if int(open(red_led, "r").read()) == 1:
                        f = open(red_led, "w")
                        f.write("0")
                        f.close()
                        time.sleep(30)
                else:
                        time.sleep(30)
