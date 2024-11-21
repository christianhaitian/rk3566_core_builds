#!/usr/bin/env python3

##################################################################
# Created by Christian Haitian.                                  #
# Python script to turn the Green LED on                         #
# while charging and off when not charging                       #
# Red LED will also turn on while charging                       #
# if battery is less than 90 percent                             #
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
