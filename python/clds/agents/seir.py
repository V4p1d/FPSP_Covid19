import numpy as np

from ..core import Agent

class SerialSEIR(Agent):
    def __init__(self, 
                 ei, 
                 ir, 
                 N=1e7, 
                 e0=0,
                 i0=500/6,
                 R0=2.78,
                 max_steps=1000,
                 dt=1):
        """
        SEIR agent with arbitrarily distributed transition delays between E->I and I->R.
        
        Args
        ----
		ei (np.array): distribution of delays with which E transitions to I, discretized at k*dt, where 0 <= k <= max_steps/dt
		ir (np.array): distribution of delays with which I transitions to R, discretized at k*dt, where 0 <= k <= max_steps/dt
		N (float): population size.
		e0 (float): initial number of exposed.
		i0 (float): initial number of infectious.
		R0 (float): average number of individuals infected per infectious.
		max_steps (int): maximum number of simulation steps.
		dt (float): length of substep. In each step, 1/dt substeps of (internal) simulation are performed before latest state is returned.
		
        """
        self.ei = ei
        self.ir = ir
        self.N = N
        self.e0 = e0
        self.i0 = i0
        self.R0 = R0
        self.max_steps = max_steps
        self.dt = dt
        
        survival_ir = (1-np.cumsum(self.ir))
        self.psi = survival_ir/survival_ir.sum() # distribution of infectious contact delay after becoming infectious
    
    def reset(self):
        
        # initial condition
        self.s = np.array([
            self.N - self.e0 - self.i0,
            self.e0,
            self.i0,
            0])
        self.substep = 0
        
        # init pre-scheduled contacts, incubations and recoveries
        self.n_contacts = np.zeros(shape=int(self.max_steps/self.dt + self.psi.shape[0])+1)
        self.e2i = np.zeros(shape=int(self.max_steps/self.dt + self.ei.shape[0])+1)
        self.i2r = np.zeros(shape=int(self.max_steps/self.dt + self.ir.shape[0])+1)
        # pre-populate transition schedules
        s, e, i, r = self.s
        self.n_contacts[0:self.psi.shape[0]] = i * self.psi # when do infectious spread from i0?
        self.i2r[0:self.ir.shape[0]] = i * self.ir # when do i0 recover?
        self.e2i[1:1+self.ei.shape[0]] = e * self.ei # when do e0 exposed become infectious?
        
        return self.s
    
    def step(self, x=None):
        if self.substep > self.max_steps/self.dt:
            return self.s, 0, True, none
        
        R0 = self._get_input(self.R0, x)
        n_steps = int(1/self.dt)
        for _ in range(n_steps):
            self._substep(R0)

        return self.s, 0, False, None
    
    def _substep(self, R0):
        self.substep += 1
        t = self.substep
        s, e, i, r = self.s
        
        s2e = self.n_contacts[t-1] * s/self.N * R0
        self.e2i[t:t+self.ei.shape[0]] = self.e2i[t:t+self.ei.shape[0]] + s2e * self.ei
        e2i = self.e2i[t]
        self.n_contacts[t:t+self.psi.shape[0]] = self.n_contacts[t:t+self.psi.shape[0]] + e2i * self.psi # when do newyly infectious infect others?
        self.i2r[t:t+self.ir.shape[0]] = self.i2r[t:t+self.ir.shape[0]] + e2i * self.ir # when do newly infectious recover?
        i2r = self.i2r[t]
        
        
        self.s = np.array([ 
            s - s2e,
            e + s2e - e2i,
            i + e2i - i2r,
            r + i2r
        ])