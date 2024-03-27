import pyautogui
from time import sleep

def mdn():
    pyautogui.MouseDown()
    sleep(.5)
    pyautogui.MouseUp()

def find_wormhole()->tuple[int,int]:
    wormhole_png = 'wormhole_max_zoomed_out.png'
    current_cood = (400,1560)
    pyautogui.moveTo(*current_cood)
    pyautogui.click()
    pyautogui.scroll(-2048)
    sleep(1)
    return tuple(pyautogui.locateCenterOnScreen(wormhole_png,confidence=.95))

r_probe = (1735,1560)
ur_probe = (1500,1200)
u_probe = (1100,1100)
ul_probe = (700,1200)
l_probe = (370,1560)
dl_probe = (700,1920)
d_probe = (1100,2020)
dr_probe = (1500,1920)

probe_coods = [r_probe,ur_probe,u_probe,ul_probe,l_probe,dl_probe,d_probe,dr_probe]

wormhole_coods = find_wormhole()
pyautogui.moveTo(*wormhole_coods)
sleep(1)
for x,y in probe_coods:
    pyautogui.moveTo(x,y)
    sleep(.5)

# in essence: kann pyautogui heutzutage, but let's try tetris first :D