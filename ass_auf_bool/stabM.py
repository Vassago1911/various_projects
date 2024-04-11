import sympy; import numpy as np;

class stable_matrix(sympy.Matrix):
    def stab(self,k:int):
        M = self
        tmp = sympy.Matrix(np.zeros((M.shape[0]+k,M.shape[1]+k)))
        for i in range(min(M.shape[0]+k,M.shape[1]+k)):
            tmp[i,i] = 1
        tmp[:M.shape[0],:M.shape[1]]=M
        return tmp
    def __mul__(self,other):
        if self.shape[1]==other.shape[0]:
            res = sympy.Matrix.__mul__(self,other)
        if self.shape[1]<other.shape[0]:
            k = other.shape[0]-self.shape[1]
            stabs = self.stab(k)
            res = sympy.Matrix.__mul__(stabs,other)
        if self.shape[1]>other.shape[0]:
            k = -other.shape[0]+self.shape[1]
            stabs = other.stab(k)
            res = sympy.Matrix.__mul__(self,stabs)
        return stable_matrix(res)
    @classmethod
    def eij(cls,i,j,k=1):
        assert i>=0
        assert j>=0
        assert i!=j
        n = max(i,j)+1
        M = sympy.eye(n)
        M[i,j]=k
        return stable_matrix(M)
    @classmethod
    def tij(cls,i,j):
        assert i>=0
        assert j>=0
        assert i!=j
        n = max(i,j)+1
        M = sympy.zeros(n,n)
        for k in range(n):
            if k not in [i,j]:
                M[k,k]=1
        M[i,j]=1; M[j,i]=1
        assert (M**2==sympy.eye(n))
        return stable_matrix(M)
    @classmethod
    def ui(cls,i,u=-1):
        assert i>=0
        n = i+1
        M = sympy.eye(n)
        M[i,i]=u
        return stable_matrix(M)

eij = stable_matrix.eij
tij = stable_matrix.tij
ui = stable_matrix.ui

A = stable_matrix(np.random.randint(0,5,(5,7)))