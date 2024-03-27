from time import sleep, time as _t
t = lambda : int(_t())
import numpy as np
import pandas as pd
import pyautogui

class Brain:
    def __init__(self,inp,timestamp,a0='',a1=''):
        if (( len(a0)==0 ) and (len(a1) == 0)):
            self.A0 = np.random.randint(-1,2,size=(10,inp.shape[0]))
            self.A1 = np.random.randint(-1,2,size=(4,11))
        else:
            self.A0 = a0
            self.A1 = a1
        data0 = pd.DataFrame(self.A0,dtype=np.int8)
        data1 = pd.DataFrame(self.A1,dtype=np.int8)
        data0.to_csv(f"brains/{timestamp}_A0.csv",index=False)
        data1.to_csv(f"brains/{timestamp}_A1.csv",index=False)
    def eval(self,inp):
        z = np.tanh( ( self.A0 )@np.array( list(inp)+[1] ))
        z = np.exp(  ( self.A1 )@np.array( list(z)  +[1] ))
        sum_z = z.sum()
        z = z/z.sum()
        return np.argmax(z)

class BrainManager:
    def __init__(self):
        import os
        ll = os.listdir('brains')
        self.ll_a0s = list(filter(lambda x: 'A0' in x,ll))
        self.ll_a1s = list(filter(lambda x: 'A1' in x,ll))
        self.ll_scores = list(filter(lambda x: 'score' in x,ll))
        scores = self.ll_scores
        scores = list(map(lambda x: x[:-4].split('_'), scores))
        scores = list(map(lambda x: (int(x[0]),int(x[2])), scores))
        scores = sorted(scores,key=lambda x: -int(x[1]))
        scores = list(filter(lambda x: x[1]!=111111, scores))
        print(scores)
        self.ll_scores = list(map(lambda x: x[0],scores))
        self.ll_a0s = { int(fname[:-7]): pd.read_csv('brains/'+fname).values for fname in self.ll_a0s}
        self.ll_a1s = { int(fname[:-7]): pd.read_csv('brains/'+fname).values for fname in self.ll_a1s}
        ll = os.listdir('logs')
        self.logs = dict()
        drops = list()
        for fi in self.ll_scores:
            _ll = list(filter(lambda x: str(fi) in x, ll))
            if len(_ll)>=1:
                self.logs[fi] = pd.read_csv('logs/'+_ll[0])
            else:
                drops += [fi]
        self.ll_scores = list(filter(lambda x: not (x in drops), self.ll_scores))

    def gen_brains(self):
        top_scores = self.ll_scores #[:4]
        top_scores = top_scores[:3]
        parent_a0s = [ self.ll_a0s[ix] for ix in top_scores ]
        parent_a1s = [ self.ll_a1s[ix] for ix in top_scores ]

        child_a0s = list()
        child_a1s = list()

        for i,a00 in enumerate(parent_a0s):
            for j,a01 in enumerate(parent_a0s):
                if i>=j:
                    for _ in range(2): # each pair gets two offspring
                        tmp_a0 = np.where(np.random.randint(0,2)>0,a00,a01)
                        #mutate
                        tmp_a0 = np.where(np.random.randint(0,100)>90,tmp_a0,tmp_a0+np.random.randint(-1,2,size=tmp_a0.shape))
                        child_a0s += [ tmp_a0 ]
                        a10 = parent_a1s[i]
                        a11 = parent_a1s[j]
                        tmp_a1 = np.where(np.random.randint(0,2)>0,a10,a11)
                        #mutate
                        tmp_a1 = np.where(np.random.randint(0,100)>90,tmp_a1,tmp_a1+np.random.randint(-1,2,size=tmp_a1.shape))
                        child_a1s += [ tmp_a1 ]

        tmp = list(zip(child_a0s,child_a1s))
        # from random import shuffle
        # shuffle(tmp)
        return tmp

class Bot:
    def __init__(self):
        from sensor_class import Sensor
        import musicalbeeps
        self.outputs = {'turn_tile':'ctrlleft','rush_tile':'down','move_left':'left','move_right':'right'}
        self.sleep_limit = .05
        self.sensor = Sensor()
        self.player = musicalbeeps.Player(volume=.3,mute_output=False)

    def turn(self,time:float=0):
        pyautogui.keyDown(self.outputs['turn_tile'])
        sleep(.01)
        pyautogui.keyUp(self.outputs['turn_tile'])

    def rush_down(self,time:float=0):
        if time < .01:
            time = self.sleep_limit
        pyautogui.keyDown(self.outputs['rush_tile'])
        sleep(3*time)
        pyautogui.keyUp(self.outputs['rush_tile'])

    def move_left(self,time:float=0):
        if time < .01:
            time = self.sleep_limit
        pyautogui.keyDown(self.outputs['move_left'])
        sleep(time)
        pyautogui.keyUp(self.outputs['move_left'])

    def move_right(self,time:float=0):
        if time < .01:
            time = self.sleep_limit
        pyautogui.keyDown(self.outputs['move_right'])
        sleep(time)
        pyautogui.keyUp(self.outputs['move_right'])

    def want_next_play(self,time_limit_hit,score,lines,grid)->bool:
        self.core_moves(score,lines,grid)
        return (not time_limit_hit())

    @property
    def stats(self):
        return self.sensor.grab_stats()

    def get_stats(self,fname:str):
        import os
        import pandas as pd
        stats = self.sensor.grab_stats()
        if (fname in os.listdir('logs')):
            data = pd.read_csv('logs/'+fname)
            data = pd.concat([data,
                pd.DataFrame.from_records(
                [
                {
                "timestamp":stats.time,
                "level":stats.level,
                "lines":stats.lines,
                "score":stats.score,
                "stats_T":stats.tile_stats.T,
                "stats_L_t":stats.tile_stats.L_t,
                "stats_Z":stats.tile_stats.Z,
                "stats_O":stats.tile_stats.O,
                "stats_Z_t":stats.tile_stats.Z_t,
                "stats_L":stats.tile_stats.L,
                "stats_I":stats.tile_stats.I,
                "grid_fill":stats.grid_fill
                }
                ]
                )
                ])
        else:
            data = pd.DataFrame.from_records(
                [
                {
                "timestamp":stats.time,
                "level":stats.level,
                "lines":stats.lines,
                "score":stats.score,
                "stats_T":stats.tile_stats.T,
                "stats_L_t":stats.tile_stats.L_t,
                "stats_Z":stats.tile_stats.Z,
                "stats_O":stats.tile_stats.O,
                "stats_Z_t":stats.tile_stats.Z_t,
                "stats_L":stats.tile_stats.L,
                "stats_I":stats.tile_stats.I,
                "grid_fill":stats.grid_fill
                }
                ]
                )
        #print('saving log to '+fname)
        data.to_csv('logs/'+fname,index=False)
        return stats

    def gen_brain(self,timestamp):
        self._brain = Brain(self._grid,timestamp)

    def make_brain(self,timestamp,a0,a1):
        self._brain = Brain(self._grid,timestamp,a0,a1)

    def brain(self,score,lines,grid)->tuple[int,float]:
        self._grid = np.array(list(grid.reshape(-1))+[score,lines])
        return (self._brain.eval(self._grid),.1)

    #TODO: bleibt im congratulations screen haengen
    def routine(self,rounds:int=2048,LIMIT:int=3600):
        # routine HELPERS
        def kill_game():
            while self.sensor.game_active():
                pyautogui.keyDown('down')
                sleep(.5)
            pyautogui.keyUp('down')
            if (not self.sensor.game_active()):
                print('game killed, exiting')
                self.exit_game_over()
        def _time_limit_hit(start:int)->bool:
            current = t()
            return ((current - start) > LIMIT)
        start = t()
        time_limit_hit = lambda : _time_limit_hit(start)
        # routine HELPERS end
        bm = BrainManager()
        brains = bm.gen_brains()

        # BOT ROUTINE
        for i in range(rounds):
            print(f"ROUND {i} started at time {t()}")
            last_t, this_t = t(), t()
            ROUND_LIMIT_s = 10 #10s can do 100 score, let's see bots do that
            round_start = this_t
            acc = this_t - last_t
            fname = f'time_{this_t}_round_{i:02d}.csv'
            current_score = 0
            current_lines = 0
            current_grid = 20*10*'0'
            current_grid = np.array(list(map(int,list(current_grid)))).reshape(20,-1)
            self._grid = np.array( list( current_grid.reshape(-1) ) + 3*[1] )
            print(f"{len(brains)} fresh brains left")
            if len(brains)==0:
                print("out of brains, quitting")
                break
                self.gen_brain(this_t)
            else:
                current_brain = brains.pop()
                self.make_brain(this_t,current_brain[0],current_brain[1])
            brain_t = this_t
            self.sensor.enter_game()
            round_start = t()
            while self.sensor.game_active():
                last_t = this_t
                this_t = t()
                # acc += this_t - last_t
                # if acc > 1:
                #     acc -= 1
                stats = self.get_stats(fname)
                # input information, but not explicitly for optimisation
                current_score = max(current_score,stats.score)
                current_lines = max(current_lines,stats.lines)
                current_grid = np.array(list(map(int,list(stats.grid_fill)))).reshape(20,-1)

                if (not self.want_next_play(time_limit_hit,current_score,current_lines,current_grid)):
                    break
                if ( (t() - round_start) > ROUND_LIMIT_s ):
                    print('round limit hit, killing round')
                    break
            with open(f"brains/{brain_t}_score_{current_score}.csv",'w') as fi:
                print(f"finished with score {current_score}")
                fi.write(f"{current_score}")
            if time_limit_hit():
                break
            if (not self.sensor.game_active()):
                print('game over found')
                self.exit_game_over()
            else:
                kill_game()
        # BOT ROUTINE over

        # BOT END -> time limit xor round limit
        if time_limit_hit():
            self.player.play_note('A4',.5)
            stats = self.get_stats(fname)
            print('time limit hit, killing the game')
            print(f"limit hit at time {t()}")
            kill_game()
            print(f"exited at time {t()}")
        else:
            self.player.play_note('C4',.5)
            print('round limit hit, killing game')
            print(f"exited at time {t()}")
        # DONE

    def exit_game_over(self):
        #game over, enter
        sleep(.25)
        pyautogui.keyDown('enter')
        sleep(.1)
        pyautogui.keyUp('enter')

    def core_moves(self,score,lines,grid):
        match self.brain(score,lines,grid):
            case (0,t):
                #sometimes we miss a "game over" screen
                #sleep(t)
                if self.sensor.game_active():
                    self.turn()
            case (1,t):
                self.move_left(t)
            case (2,t):
                self.move_right(t)
            case (3,t):
                self.rush_down(t)