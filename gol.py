# i. Initialise an empty universe
# ii. Fill the universe with the seed
# iii. Calculate if the current cell survives to the next timestamps, based on its neighbours
# iv. Repeat this survival function(like step-iii) over all the cells in the universe neighbours.
# v. Repeat steps iii-iv for the desired number of generations.

import numpy as np
import matplotlib.pyplot as plt

import argparse
import time


# Class to create the Board object and redrawing of it
class Board(object):
    
    # Initialize the initial seed the engine class and the first iteration
    def __init__(self, size, seed = 'Random'):
        if seed == 'Random':
            self.state = np.random.randint(2, size = size)
        self.engine = Engine(self)
        self.iteration = 0

    # Pause the animation state to allow user to save image
    def _animation_sate(self, i):
        if i == 50:
            plt.pause(15)
            return False

    # Animate the game of life using matplotlip.pyplot
    def animate(self):
        i = self.iteration
        im = None
        plt.title("November")
        while True:
            if i == 0:
                plt.ion()
                
                # cmap was manually changed for each NFT, would like to automate in the future
                im = plt.imshow(self.state, vmin = 0, vmax = 2, cmap = 'gist_ncar')
            else:
                im.set_data(self.state)

            if self._animation_sate(i) == False:
                break

            i += 1
            self.engine.applyRules()
            
            # Print to console
            print('Life Cycle: {} Birth: {} Survive: {}'.format(i, self.engine.nBirth, self.engine.nSurvive))
            plt.pause(0.01)
            yield self  

# Engine that creates the logic of the game     
class Engine(object):
    def __init__(self, board):
        self.state = board.state
    
    # Check to see if there are neighbors around given cell and returns number of neighbors
    def countNeighbors(self):
        state = self.state
        n = (state[0:-2,0:-2] + state[0:-2,1:-1] + state[0:-2,2:] +
            state[1:-1,0:-2] + state[1:-1,2:] + state[2:,0:-2] +
            state[2:,1:-1] + state[2:,2:])
        return n
    
    # Apply the game logic to the given cell based on the number of neighbors around it
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

# Main function to run the game with animation
def main():
    ap = argparse.ArgumentParser(add_help = False) # Intilialize Argument Parser
    ap.add_argument('-h', '--height', help = 'Board Height', default = 256)
    ap.add_argument('-w', '--width', help = 'Board Width', default = 256)
    args = vars(ap.parse_args()) # Gather Arguments
    bHeight = int(args['height'])
    bWidth = int(args['width'])
    board = Board((bHeight,bWidth))
    for _ in board.animate():
        pass

if __name__ == '__main__':
    main()
