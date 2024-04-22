#!/usr/bin/env python3
#Adapted from https://stackoverflow.com/a/66867816
from inputs import get_gamepad
import math
import os
from subprocess import check_output
import threading
import time

class Controller(object):

    def __init__(self):

        self.LeftJoystickY = 0
        self.LeftJoystickX = 0
        self.RightJoystickY = 0
        self.RightJoystickX = 0
        self.LeftTrigger = 0
        self.RightTrigger = 0
        self.LeftBumper = 0
        self.RightBumper = 0
        self.A = 0
        self.X = 0
        self.Y = 0
        self.B = 0
        self.LeftThumb = 0
        self.RightThumb = 0
        self.Back = 0
        self.Start = 0
        self.LeftDPad = 0
        self.RightDPad = 0
        self.UpDPad = 0
        self.DownDPad = 0
        self.BtnMode = 0

        self._monitor_thread = threading.Thread(target=self._monitor_controller, args=())
        self._monitor_thread.daemon = True
        self._monitor_thread.start()


    def read(self): # return the buttons/triggers that you care about in this methode
        lx = self.LeftJoystickX
        ly = self.LeftJoystickY
        rx = self.RightJoystickX
        ry = self.RightJoystickY
        a = self.A
        b = self.B
        x = self.X
        y = self.Y
        rb = self.RightBumper
        lb = self.LeftBumper
        rt = self.RightTrigger
        lt = self.LeftTrigger
        thumbr = self.LeftThumb
        thumbl = self.RightThumb
        up = self.UpDPad
        down = self.DownDPad
        left = self.LeftDPad
        right = self.RightDPad
        select = self.Back
        start = self.Start
        mode = self.BtnMode
        return [lx, ly, rx, ry, a, b, x, y, rb, lb, rt, lt, thumbr, thumbl, up, down, left, right, select, start, mode]


    def _monitor_controller(self):
        while True:
            events = get_gamepad()
            for event in events:
                if event.code == 'ABS_Y':
                    if event.state > 500 or event.state < -500:
                      self.LeftJoystickY = 1
                    else:
                      self.LeftJoystickY = 0
                elif event.code == 'ABS_X':
                    if event.state > 500 or event.state < -500:
                      self.LeftJoystickX = 1
                    else:
                      self.LeftJoystickX = 0
                elif event.code == 'ABS_RY':
                    if event.state > 500 or event.state < -500:
                      self.RightJoystickY = 1
                    else:
                      self.RightJoystickY = 0
                elif event.code == 'ABS_RX':
                    if event.state > 500 or event.state < -500:
                      self.RightJoystickX = 1
                    else:
                      self.RightJoystickX = 0
                elif event.code == 'BTN_TL2':
                    self.LeftTrigger = event.state
                elif event.code == 'BTN_TR2':
                    self.RightTrigger = event.state
                elif event.code == 'BTN_TL':
                    self.LeftBumper = event.state
                elif event.code == 'BTN_TR':
                    self.RightBumper = event.state
                elif event.code == 'BTN_SOUTH':
                    self.A = event.state
                elif event.code == 'BTN_NORTH':
                    self.Y = event.state
                elif event.code == 'BTN_WEST':
                    self.X = event.state
                elif event.code == 'BTN_EAST':
                    self.B = event.state
                elif event.code == 'BTN_THUMBL':
                    self.LeftThumb = event.state
                elif event.code == 'BTN_THUMBR':
                    self.RightThumb = event.state
                elif event.code == 'BTN_SELECT' or event.code == 'BTN_TRIGGER_HAPPY5':
                    self.Back = event.state
                elif event.code == 'BTN_START' or event.code == 'BTN_TRIGGER_HAPPY6':
                    self.Start = event.state
                elif event.code == 'BTN_MODE':
                    self.BtnMode = event.state
                elif event.code == 'BTN_TRIGGER_HAPPY1' or event.code == 'BTN_DPAD_LEFT':
                    self.LeftDPad = event.state
                elif event.code == 'BTN_TRIGGER_HAPPY2' or event.code == 'BTN_DPAD_RIGHT':
                    self.RightDPad = event.state
                elif event.code == 'BTN_TRIGGER_HAPPY3' or event.code == 'BTN_DPAD_UP':
                    self.UpDPad = event.state
                elif event.code == 'BTN_TRIGGER_HAPPY4' or event.code == 'BTN_DPAD_DOWN':
                    self.DownDPad = event.state

def runcmd(cmd, *args, **kw):
    check_output(cmd, *args, **kw)

if __name__ == '__main__':
    try:
      value = open('/home/ark/.config/.TIMEOUT','r')
      Tvalue = int(value.read())
      value.close()
    except:
      Tvalue = 30

    joy = Controller()
    # Adapted from https://stackoverflow.com/a/34056236
    while True:
       timer = Tvalue * 60 * 10 # minutes times 60 seconds times 10 to account for sleep time of the loop
       while timer > 0:
            time.sleep(0.1) # don't sleep for a full second or else the sleep time frame will be off
            timer -= 1
            #print("Time left is " + str(timer))
            if 1 in joy.read():
                  timer = Tvalue * 60 * 10
       #print("Times up!") # called when time is zero and while loop is exited
       ChgStatus = open('/sys/devices/platform/rockchip-system-monitor/subsystem/devices/rk817-charger/power_supply/ac/status','r',encoding='utf-8')
       if "Charging" not in ChgStatus.readline() and "Nothing" in check_output("/usr/local/bin/processcheck.sh", text=True):
          print("Going into suspend mode now") # called when time is zero and while loop is exited
          # send a left shift key in case ES is on the screen and the screen is blank to turn it on before sleeping
          runcmd("sudo /usr/local/bin/keystroke.py || true", shell=True)
          runcmd("sudo /bin/systemctl suspend || true", shell=True)
          time.sleep(5)
       ChgStatus.close()
