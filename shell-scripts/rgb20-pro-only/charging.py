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
batt_status = "/sys/class/power_supply/battery/status"
red_led = "/sys/class/leds/Red LED/brightness"
green_led = "/sys/class/leds/Green LED/brightness"

while(True):
        with open(batt_status, "r") as file:
                for line in file:
                    if 'Charging' in line:
                        f = open(green_led, "w")
                        f.write("1")
                        f.close()
                        if int(open(batt_life, "r").read()) <= 89:
                           f = open(red_led, "w")
                           f.write("1")
                           f.close()
                        else:
                           f = open(red_led, "w")
                           f.write("0")
                           f.close()
                        time.sleep(3)
                    else:
                        f = open(green_led, "w")
                        f.write("0")
                        f.close()
                        f = open(red_led, "w")
                        f.write("0")
                        f.close()
                        time.sleep(3)
