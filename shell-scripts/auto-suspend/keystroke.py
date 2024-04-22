#!/usr/bin/env python3
from evdev import uinput, ecodes as e
import time

with uinput.UInput() as ui:
    ui.write(e.EV_KEY, e.KEY_LEFTSHIFT, 1)
    time.sleep(0.11)
    ui.syn()
