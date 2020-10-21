import numpy as np

from ..core import Agent
            
class BatchLockdown(Agent):
    """ Lockdown policy.
    
    Agent returns 
        [0, ... suppression start]: beta_high
        [suppression_start, ..., suppression_end): beta_low
        [suppression_end, ..., END]: beta_high
    """
    def __init__(self, beta_high=1, beta_low=0, batch_size=1, suppression_start=0, suppression_end=None):
        self.batch_size = batch_size
        self.beta_high = self._to_batch(beta_high)
        self.beta_low = self._to_batch(beta_low)
        self.suppression_start = suppression_start
        self.suppression_end = suppression_end
        
    # variable should have shape (batch, ) + shape
    def _to_batch(self, x, shape=()):
        # return placeholder key or callable
        if isinstance(x, str) or callable(x):
            return x
        
        x_arr = np.array(x)
        target_shape = (self.batch_size, ) + shape

        if x_arr.shape == target_shape:
            return x_arr
        elif (x_arr.shape == shape):
            return np.matlib.repmat(x_arr.reshape(shape), self.batch_size,1).reshape(target_shape)
        elif len(x_arr.shape) > 0 and x_arr.shape[0] == target_shape:
            return x_arr.reshape(target_shape)
        else:
            print("Warning: unable to convert to target shape", x, target_shape)
            return x
        
    def reset(self):
        self.steps = 1
        return self.beta_high
        
    def step(self, x):
        y = self.beta_high
        if (self.steps >= self.suppression_start):
            y = self.beta_low
        if (self.suppression_end is not None) and (self.steps >= self.suppression_end):
            y = self.beta_high
        self.steps += 1
        return y, 0, False, None