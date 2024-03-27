from time import sleep, time as _t
stamp = lambda : f"{int(_t())}"
import numpy as np
import pyautogui

from dataclasses import dataclass

@dataclass
class MyBox:
    left:int
    top:int
    width:int
    height:int

@dataclass
class TileStats:
    T:int
    L_t:int
    Z:int
    O:int
    Z_t:int
    L:int
    I:int

@dataclass
class Scores:
    lines:int
    level:int
    score:int
    tile_stats:TileStats
    grid_fill:str
    time:int

class Sensor:
    def __init__(self):
        import mss
        self.sct = mss.mss()
        self.monitor = self.sct.monitors[1]
        import imageio.v3 as iio
        self.numbers = [ iio.imread(f"sensor_stamps/{i}_tocrop.png").min(axis=2) for i in range(10)]
        self._max_numbers_x = max([a.shape[0] for a in self.numbers])
        self._max_numbers_y = max([a.shape[1] for a in self.numbers])

    def min_dist_to_numbers(self,a:np.array):
        tmp_min_ix = 0
        tmp_min = self.numbers[0]
        curr_min = 10**8

        for i,number in enumerate(self.numbers):
            ix_min,iy_min = min(number.shape[0],a.shape[0]),min(number.shape[1],a.shape[1])
            number_tmp = number[-ix_min:,-iy_min:]
            a_tmp = a[-ix_min:,-iy_min:]
            assert a_tmp.shape == number_tmp.shape
            d = np.abs(a_tmp - number_tmp).sum()
            #print(i, d)
            if curr_min >= d:
                curr_min = d
                tmp_min = number
                tmp_min_ix = i

        #TODO / FIX: 0 wird als 3 erkannt, wenn zu weit unten, 3 als 8
        tmp_min_ix = 0 if tmp_min_ix==3 else tmp_min_ix
        tmp_min_ix = 1 if tmp_min_ix==7 else tmp_min_ix
        tmp_min_ix = 3 if tmp_min_ix==8 else tmp_min_ix

        return tmp_min_ix

    def read_label_positions(self):
        score_label = "sensor_stamps/score_label.png"
        self.score_pos = list(pyautogui.locateAllOnScreen(score_label))[0]

        level_label = "sensor_stamps/level_label.png"
        self.level_pos = list(pyautogui.locateAllOnScreen(level_label))[0]

        lines_label = "sensor_stamps/lines_label.png"
        self.lines_pos = list(pyautogui.locateAllOnScreen(lines_label))[0]
        self.cell_width = int(self.lines_pos.width/6)+1
        self.cell_height = int(self.lines_pos.height)

        statistics_label = "sensor_stamps/statistics_label.png"
        self.statistics_pos = list(pyautogui.locateAllOnScreen(statistics_label))[0]

        self.number_cell_positions = \
        [ MyBox(top=self.lines_pos.top,
                left=self.lines_pos.left+self.lines_pos.width+i*self.cell_width,
                width=self.cell_width,
                height=self.cell_height) for i in range(3) ]  + \
        [ MyBox(    top=self.level_pos.top+self.level_pos.height
                ,  left=self.level_pos.left+2*self.cell_width+i*self.cell_width-4
                , width=self.cell_width
                ,height=self.cell_height
                ) for i in range(2) ] + \
        [ MyBox( top=self.statistics_pos.top+self.statistics_pos.height+int(1.8*self.cell_height)+int(1.8*j*self.cell_height)
            , left=self.statistics_pos.left+self.statistics_pos.width//2+i*self.cell_width
            , width=self.cell_width
            , height=self.cell_height
            ) for j in range(7) for i in range(3) ] + \
        [ MyBox(top=self.score_pos.top+self.score_pos.height,
                left=self.score_pos.left+i*self.cell_width,
                width=self.cell_width,
                height=self.cell_height ) for i in range(6) ]

        game_top_boundary = "sensor_stamps/game_area_boundary.png"
        self.game_pos = list(pyautogui.locateAllOnScreen(game_top_boundary))[0]

        self.game_cell_width = self.game_pos.width//2+3
        self.game_cell_height = self.game_pos.height//2+4
        self.game_cell_positions = \
        [ [MyBox(left=self.game_pos.left+(1+i)*self.game_cell_width
            ,top=self.game_pos.top+(1+j)*self.game_cell_height
            ,width=self.game_cell_width,height=self.game_cell_height)
            for i in range(10)]
            for j in range(20)
        ]

    def grab_stats(self):
        a = np.array(self.sct.grab(self.monitor).pixels)
        for pos in self.number_cell_positions + sum(self.game_cell_positions,start=[]):
            x,y,w,h=pos.left,pos.top,pos.width,pos.height
            for i in range(6):
                for j in range(6):
                    a[j+y        -400,i+x:i+x+w,:] = (192,0,96)
                    a[j+y+h      -400,i+x:i+x+w,:] = (192,0,96)
                    a[j+y-400:y+h-400,i+x      ,:] = (192,0,96)
                    a[j+y-400:y+h-400,i+x+w    ,:] = (192,0,96)

        self.number_cells = list()
        for pos in self.number_cell_positions:
            x,y,w,h=pos.left,pos.top-400,pos.width,pos.height
            self.number_cells += [ a[y:y+h,x:x+w,:].min(axis=2) ]#greyscale

        self.identified_numbers = list()
        for number in self.number_cells:
            self.identified_numbers += [ self.min_dist_to_numbers(number) ]

        self.lines_part,self.identified_numbers = self.identified_numbers[:3],self.identified_numbers[3:]
        self.level_part,self.identified_numbers = self.identified_numbers[:2],self.identified_numbers[2:]
        self.score_part,self.identified_numbers = self.identified_numbers[-6:],self.identified_numbers[:-6]
        self.T_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.L_t_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.Z_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.O_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.Z_t_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.L_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]
        self.I_part,self.identified_numbers  = self.identified_numbers[:3],self.identified_numbers[3:]

        lines = int(''.join(list(map(str,self.lines_part))))
        level = int(''.join(list(map(str,self.level_part))))
        score = int(''.join(list(map(str,self.score_part))))
        T = int(''.join(list(map(str,self.T_part))))
        L_t = int(''.join(list(map(str,self.L_t_part))))
        Z = int(''.join(list(map(str,self.Z_part))))
        O = int(''.join(list(map(str,self.O_part))))
        Z_t = int(''.join(list(map(str,self.Z_t_part))))
        L = int(''.join(list(map(str,self.L_part))))
        I = int(''.join(list(map(str,self.I_part))))

        tilestats = TileStats(T=T,L_t=L_t,Z=Z,O=O,Z_t=Z_t,L=L,I=I)

        rows = list()
        for i,row in enumerate(self.game_cell_positions):
            row_tmp = list()
            for j,cell in enumerate(row):
                x,y,w,h = cell.left, cell.top, cell.width, cell.height
                x,y=x+w//2,y+h//2
                row_tmp += [ a[y-400,x] ]
            rows += [row_tmp]

        b = np.zeros((20,10),dtype=np.uint8)

        rows2 = list()
        for i,row in enumerate(rows):
            row_tmp = list()
            for j,color in enumerate(row):
                clr = np.array([0,0,0]) if (( color[0]<=75) and (color[1]<=75) and (color[2]<=5) ) else color
                if clr.max() <= 10:
                    b[i,j] = 0
                else:
                    b[i,j] = 1
                row_tmp += [ clr ]
            rows2 += [row_tmp]

        z = b.reshape(-1)
        assert np.abs(z.reshape(20,-1) - b).max() < 1e-4
        z = list(z)
        z = ''.join(list(map(str,z)))

        scores = Scores(lines=lines,level=level,score=score,tile_stats=tilestats,grid_fill=z,time=int(_t()))

        z_back = np.array(list(map(int, list(scores.grid_fill)))).reshape(20,-1)
        assert np.abs(z_back - b).max() < 1e-4

        return scores

    def enter_game(self):
        def _ensure_focus(coods=tuple[int,int])->None:
            pyautogui.moveTo(*coods)
            pyautogui.mouseDown()
            sleep(.5)
            pyautogui.mouseUp()
        a_type_label = 'sensor_stamps/a-type.png'
        sleep(1)
        for _ in range(2):
            #assert we're on a-type level select screen
            in_atype_screen = list(pyautogui.locateAllOnScreen(a_type_label))
            assert len(list(in_atype_screen))==1, "wrong screen?"

        SCREEN_COODS = (in_atype_screen[0].left,in_atype_screen[0].top)
        ensure_focus = lambda : _ensure_focus(SCREEN_COODS)
        ensure_focus()
        #in a-type menu / a-type menu loading
        sleep(.5)
        #assume level 0 selected
        pyautogui.keyDown('enter')
        sleep(.1)
        pyautogui.keyUp('enter')
        #game entered

        sleep(.5)
        #game start
        pyautogui.keyDown('enter')
        sleep(.1)
        pyautogui.keyUp('enter')
        #game started
        ensure_focus()

        self.read_label_positions()
        sleep(.1)

    def game_active(self)->bool:
        game_over_label = "sensor_stamps/GameOver.png"
        try:
            gol = list(pyautogui.locateAllOnScreen(game_over_label))
            #print(gol[0])
            return False
        except Exception as e:
            return True

if __name__ == "__main__":
    def show(a:np.array):
        import matplotlib.pyplot as plt; plt.imshow(a); plt.show()
    sensor = Sensor()
    sensor.read_label_positions()
    a=sensor.grab_stats()
    print(a)