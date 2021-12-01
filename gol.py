# i. Initialise an empty universe
# ii. Fill the universe with the seed
# iii. Calculate if the current cell survives to the next timestamps, based on its neighbours
# iv. Repeat this survival function(like step-iii) over all the cells in the universe neighbours.
# v. Repeat steps iii-iv for the desired number of generations.

import numpy as np
import matplotlib.pyplot as plt

import argparse
import time



class Board(object):
    def __init__(self, size, seed = 'Random'):
        if seed == 'Random':
            self.state = np.random.randint(2, size = size)
        self.engine = Engine(self)
        self.iteration = 0

    # def _save_image(self, image):
    #     print(image)
    #     # image.savefig('NFT.png')

    # def _get_scene(self, plot):
    #     image = plot
    #     return False, image

    def _animation_sate(self, i):
        if i == 50:
            plt.pause(15)
            return False

    def animate(self):
        i = self.iteration
        im = None
        plt.title("November")
        while True:
            if i == 0:
                plt.ion()
                im = plt.imshow(self.state, vmin = 0, vmax = 2, cmap = 'gist_ncar')
            else:
                im.set_data(self.state)

            if self._animation_sate(i) == False:
                break

            i += 1
            self.engine.applyRules()
            
            print('Life Cycle: {} Birth: {} Survive: {}'.format(i, self.engine.nBirth, self.engine.nSurvive))
            plt.pause(0.01)
            yield self  

        # image = self._get_scene(im)
        # self._save_image(image)

class Engine(object):
    def __init__(self, board):
        self.state = board.state
    
    def countNeighbors(self):
        state = self.state
        n = (state[0:-2,0:-2] + state[0:-2,1:-1] + state[0:-2,2:] +
            state[1:-1,0:-2] + state[1:-1,2:] + state[2:,0:-2] +
            state[2:,1:-1] + state[2:,2:])
        return n
    
    def applyRules(self):
        n = self.countNeighbors()
        state = self.state
        birth = (n == 3) & (state[1:-1,1:-1] == 0)
        survive = ((n == 2) | (n == 3)) & (state[1:-1,1:-1] == 1)
        state[...] = 0
        state[1:-1,1:-1][birth | survive] = 1
        nBirth = np.sum(birth)
        self.nBirth = nBirth
        nSurvive = np.sum(survive)
        self.nSurvive = nSurvive
        return state

def main():
    ap = argparse.ArgumentParser(add_help = False) # Intilialize Argument Parser
    ap.add_argument('-h', '--height', help = 'Board Height', default = 256)
    ap.add_argument('-w', '--width', help = 'Board Width', default = 256)
    args = vars(ap.parse_args()) # Gather Arguments
    bHeight = int(args['height'])
    bWidth = int(args['width'])
    board = Board((bHeight,bWidth))
    for _ in board.animate():
        print(_)
        pass

if __name__ == '__main__':
    main()