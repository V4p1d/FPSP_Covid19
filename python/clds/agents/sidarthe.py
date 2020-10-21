import gym

import numpy as np
import numpy.matlib

from ..core import Agent

# S: Susceptibles
# I : (infected) asymptomatic, infected, undetected
# D: (detected) asymptomatic, infected, detected
# A: (ailing) symptomatic, infected, undetected
# R: (recognized) symptomatic, infected, detected
# T: (threatened) acutely symptomatoc, infected, detected
# H: (healed)
# E: (extinct)

class BatchSIDARTHE(Agent):
    def __init__(self,
                 s0, # initial state
                 N,
                 batch_size=1,
                 alpha=0.57, # contagion from I
                 beta=0.011, # contagion from D
                 gamma=0.456, # contagion from A
                 delta=0.011, # contagion from R
                 epsilon=0.171, # diagnosis
                 zeta=0.125, # developing symptoms while undiagnosed
                 eta=0.125, # developing symptoms after diagnosis
                 theta=0.371, # diagnosis after symptoms
                 kappa=0.017, # A -> H
                 h=0.034, # I -> H
                 mu=0.012, # A -> T
                 nu=0.027, # R -> T
                 xi=0.017, # R -> H
                 rho=0.034, # D -> H
                 sigma=0.017, # T-> H
                 tau=0.003, # T -> E
                 round_state=False, 
                 step_size=0.01):
        
        """Class for SIDARTHE dynamics of the environment
        https://arxiv.org/abs/2003.09861

        Parameters
        ----------
        
        N (int, default=10000): the total siwe of the population
        round_state(bool): round state to nearest integer after each step.

        Attributes
        ----------
        observation_space (gym.spaces.Box, shape=(3,)): at each step, the
            environment only returns the true values S, I, R
        action_space (gym.spaces.Box, shape=(1)): the value beta

        #TODO necessary to wrap gym.Env?

        """
    
        self.batch_size = batch_size  
        self.s0 = s0
        self.N = self._to_batch(N)
        assert (np.sum(self.s0) == self.N).all()
        
        self.alpha = self._to_batch(alpha)
        self.beta = self._to_batch(beta)
        self.gamma = self._to_batch(gamma)
        self.delta = self._to_batch(delta)
        self.epsilon = self._to_batch(epsilon)
        self.zeta = self._to_batch(zeta)
        self.eta = self._to_batch(eta)
        self.theta = self._to_batch(theta)
        self.kappa = self._to_batch(kappa)
        self.h = self._to_batch(h)
        self.mu = self._to_batch(mu)
        self.nu = self._to_batch(nu)
        self.xi = self._to_batch(xi)
        self.rho = self._to_batch(rho)
        self.sigma = self._to_batch(sigma)
        self.tau = self._to_batch(tau)
        
        self.round_state = round_state
        self.step_size = step_size

        self.observation_space = gym.spaces.Box(
            0, np.inf, shape=(4,), dtype=np.float64)  # check dtype
        self.action_space = gym.spaces.Box(
            0, np.inf, shape=(1,), dtype=np.float64)

    def reset(self):
        """returns initial state (s0,  i0, r0)"""
        self.state = self._to_batch(self.s0, (8,))
        if self.round_state:
            self.state = self._pround(self.state)

        return self.state

    def step(self, action=None):
        """performs integration step"""
        
        alpha = self._to_batch(self._get_input(self.alpha, action))
        beta = self._to_batch(self._get_input(self.beta, action))
        gamma = self._to_batch(self._get_input(self.gamma, action))
        delta = self._to_batch(self._get_input(self.delta, action))
        
        self.state = self.euler_step(self.state, 
                                     dt=1, 
                                     alpha=alpha,
                                     beta=beta, 
                                     gamma=gamma, 
                                     delta=delta)
        if self.round_state:
            self.state = self._pround(self.state)
            
        return self.state, 0, False, None

    @staticmethod
    def _pround(x):
        dx = np.random.uniform(size=x.shape) < (x-x.astype(np.int32))
        return x + dx
        
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
    
    def euler_step(self, X, dt, alpha, beta, gamma, delta):
        
        X_ = np.array(X)
        n_steps = int(1/self.step_size)
        for _ in range(n_steps):
            dxdt = self._ode(X_, 
                             dt/n_steps, 
                             self.N, 
                             alpha,
                             beta,
                             gamma,
                             delta,
                             self.epsilon,
                             self.zeta,
                             self.eta,
                             self.theta,
                             self.kappa,
                             self.h,
                             self.mu,
                             self.nu,
                             self.xi,
                             self.rho,
                             self.sigma,
                             self.tau)
            X_ = X_ + dxdt
        return X_

    @staticmethod
    def _ode(Y, dt, N,
             alpha,
             beta, 
             gamma, 
             delta, 
             epsilon, 
             zeta,
             eta, 
             theta,
             kappa,
             h,
             mu,
             nu,
             xi,
             rho,
             sigma,
             tau):
        """Y = (S, I, R)^T """
        keys = ['S', 'I', 'D', 'A', 'R', 'T', 'H', 'E']
        S, I, D, A, R, T, H, E = [Y[:,i] for i in range(8)]
        
        newly_infected = (alpha*I + beta*D + gamma*A + delta*R)
        dS = -S/N * newly_infected
        dI = S/N * newly_infected - (epsilon + zeta + h)*I
        dD = epsilon*I - (eta + rho)*D
        dA = zeta*I - (theta + mu + kappa)*A
        dR = eta*D + theta*A - (nu + xi)*R
        dT = mu*A + nu*R - (sigma + tau)*T
        dH = h*I + rho*D + kappa*A + xi*R + sigma*T
        dE = tau*T

        return np.array([dS, dI, dD, dA, dR, dT, dH, dE]).T * dt
    
    def R0(self, x):
        alpha = self._to_batch(self._get_input(self.alpha, x))
        beta = self._to_batch(self._get_input(self.beta, x))
        gamma = self._to_batch(self._get_input(self.gamma, x))
        delta = self._to_batch(self._get_input(self.delta, x))
        r1 = self.epsilon + self.zeta + self.h
        r2 = self.eta + self.rho
        r3 = self.theta + self.mu + self.kappa
        r4 = self.nu + self.xi
        r5 = self.sigma + self.tau
        
        r0 = alpha / r1
        r0 += beta * self.epsilon / (r1 * r2)
        r0 += gamma * self.zeta / (r1 * r3)
        r0 += delta * self.eta * self.epsilon / (r1 * r2 * r4)
        r0 += delta * self.zeta * self.theta / (r1 * r3 * r4)
        return r0
    
    def render(self, mode='human'):
        pass

    def close(self):
        pass
