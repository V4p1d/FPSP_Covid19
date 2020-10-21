import numpy as np
import numpy.matlib

from ..core import Agent

class FPSP(Agent):
    """ Fast Periodic Switching between high and low beta policy.
    
    Implementation of https://robertshorten.files.wordpress.com/2020/03/fpsr_title.pdf
    
    Agent returns 
        [0, ... suppression start]: beta_high
        [suppression_start, ..., switching_start): beta_low
        [switching_start, ..., END]: beta_high for steps_high followed by beta_low for steps_low steps.
    
    """
    def __init__(self, steps_high, steps_low, beta_high=1, beta_low=0, suppression_start=0, switching_start=0):
        self.beta_high = beta_high
        self.beta_low = beta_low
        self.steps_high = steps_high
        self.steps_low = steps_low
        self.suppression_start = suppression_start
        self.switching_start = switching_start
        
    def reset(self):
        self.steps = 0
        return self.beta()
        
    def step(self, x):
        switching_start = self._get_input(self.switching_start, x)
        steps_high = self._get_input(self.steps_high, x)
        steps_low = self._get_input(self.steps_low, x)
        
        y = self.beta(switching_start, steps_high, steps_low)
        
        self.steps += 1
        return y, 0, False, None
    
    def beta(self, 
            switching_start=0,
            steps_high=1, 
            steps_low=1):
        
        if self.steps >= switching_start:
            cycle_length = self.steps_high + self.steps_low
            cycle_step = np.maximum(0, self.steps-self.switching_start).astype(np.int32)
            cycle_step = np.mod(cycle_step, cycle_length)
            is_high_cycle = cycle_step < self.steps_high
            return self.beta_high if is_high_cycle else self.beta_low
        elif self.steps >= self.suppression_start:
            return self.beta_low
        else:
            return self.beta_high
        
            
class BatchFPSP(Agent):
    """ Fast Periodic Switching between high and low beta policy.
    
    Implementation of https://robertshorten.files.wordpress.com/2020/03/fpsr_title.pdf
    
    Agent returns 
        [0, ... suppression start]: beta_high
        [suppression_start, ..., switching_start): beta_low
        [switching_start, ..., END]: beta_high for steps_high followed by beta_low for steps_low steps.
    
    """
    def __init__(self, beta_high=1, beta_low=0, steps_high=1, steps_low=1, batch_size=1, suppression_start=0, switching_start=0):
        self.batch_size = batch_size
        self.beta_high = self._to_batch(beta_high)
        self.beta_low = self._to_batch(beta_low)
        self.steps_high = steps_high
        self.steps_low = steps_low
        self.suppression_start = suppression_start
        self.switching_start = switching_start
        
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
        self.cycle_length = None
        return self.beta_high
        
    def step(self, x):
        steps_high = self._to_batch(self._get_input(self.steps_high, x))
        steps_low = self._to_batch(self._get_input(self.steps_low, x))
        
        y = self.beta(steps_high, steps_low)
        self.steps += 1
        return y, 0, False, None
    
    def beta(self, steps_high, steps_low):
        is_phase_3 = self.steps >= self.switching_start
        is_phase_2 = (self.steps >= self.suppression_start) * (1-is_phase_3)
        is_phase_1 = (1-is_phase_3)*(1-is_phase_2)
        
        cycle_length = steps_high + steps_low
        cycle_step = np.maximum(0, (self.steps - self.switching_start)).astype(np.int32)
        cycle_step = np.mod(cycle_step, cycle_length)
        is_high_cycle = cycle_step < steps_high
        
        out = is_phase_1 * self.beta_high + \
              is_phase_2 * self.beta_low + \
              is_phase_3 * (is_high_cycle * self.beta_high + (1-is_high_cycle) * self.beta_low)
        return out
		
class BatchOuterLoopFPSP(Agent):
    """ 
    FPSP Outer supervisory loop - batch version.
    
    """
    def __init__(self, 
                 start=0, 
                 period=7, 
                 o =-1,
                 x_init=1,
                 x_min=0, 
                 x_max=7, 
                 alpha_x=0.4, 
                 alpha_y=0.0, 
                 batch_size=1):
        
        self.start = start
        self.period = period
        self.x_init = x_init
        self.x_min = x_min
        self.x_max = x_max
        self.alpha_x = alpha_x
        self.alpha_y = alpha_y
        self.batch_size = batch_size
        
        self.o = o # control signal
        
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
        self.steps = 0
        self.x = self._to_batch(self.x_init)
        self.o_k1 = np.zeros(self.batch_size)
        self.o_k = np.zeros(self.batch_size)
        return np.vstack([self.x, self.period-self.x]).T
    
    def step(self, x=None):
        o = self._to_batch(self._get_input(self.o, x)) # fetch observed signal
        self.o_k += o

        do_update_buffer = (np.mod(self.steps-self.start, self.period) == 0)
        do_update_x = do_update_buffer * (self.steps >= self.start)
        #print(self.steps, do_update_x*self.o_k/self.o_k1)
        x_ = self.x
        # increase duty cycle if observed infecteds is lower than in preceeding period
        cond_x = self.o_k < (1 - self.alpha_x) * self.o_k1
        # decrease duty cycle if observed infecteds is greater than in preceeding period
        cond_y = self.o_k > (1 + self.alpha_y) * self.o_k1
        x_ = do_update_x * (self.x + 1 * cond_x -1 * cond_y) + (1-do_update_x)*x_
        # saturate cast duty cycle to fixed bounds
        x_ = self.mid(self.x_min, x_, self.x_max)
        self.x = x_
        
        self.o_k1 = do_update_buffer * self.o_k + (1-do_update_buffer) * self.o_k1
        self.o_k = (1-do_update_buffer) * self.o_k
                
        self.steps += 1
        out = np.vstack([self.x, self.x_max-self.x]).T
        return out, 0, False, None
                
    
    @staticmethod
    def mid(a, b, c):
        cond_1 = b <= a
        cond_2 = b < c
        return cond_1 * a + (1-cond_1)*cond_2 * b + (1-cond_1)*(1-cond_2) * c