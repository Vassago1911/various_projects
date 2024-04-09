#Z[{0,1}] crings

class Zmult:
    def __init__(self,type:int=0):
        match type:
            case 0: # and
                self.mu = lambda k,l,m,n: (k*m+k*n+l*m,l*n)
                self.unit = (0,1)
            case 1: # or
                self.mu = lambda k,l,m,n: (k*m,k*n+l*m+l*n)
                self.unit = (1,0)
            case 2: # xor
                self.mu = lambda k,l,m,n: (k*m+l*n,k*n+l*m)
                self.unit = (1,0)
            case _: # not \circ xor
                self.mu = lambda k,l,m,n: (k*n+l*m,k*m+l*n)
                self.unit = (0,1)
        test_range = [ (k,l) for k in range(-6,6) for l in range(-6,6) ]
        ass_test_range = [tuple(list(x)+list(y)+list(z)) for x in test_range for y in test_range for z in test_range ]
        ass12 = lambda a,b,c,d,e,f: self.mu(a,b,*self.mu(c,d,e,f))
        ass21 = lambda a,b,c,d,e,f: self.mu(*self.mu(a,b,c,d),e,f)
        assert all([ ass12(*a)==ass21(*a) for a in ass_test_range ]), "mu not associative, wtf!?"
        comm_test_range = [tuple(list(x)+list(y)) for x in test_range for y in test_range]
        comm_pred = lambda a,b,c,d: self.mu(a,b,c,d)==self.mu(c,d,a,b)
        assert all([ comm_pred(*t) for t in comm_test_range ]), "mu not commutative, wtf?"
        assert all([ self.mu(*self.unit,*x)==x for x in test_range]), "mu not left-unital, wtf?"
        assert all([ self.mu(*x,*self.unit)==x for x in test_range]), "mu not right-unital, wtf?"

Rand = Zmult(type=0)
Ror = Zmult(type=1)
Rxor = Zmult(type=2)
Rnxor = Zmult(type=3)

unit_test_range = [ (k,l) for k in range(-6,6) for l in range(-6,6) ]

for R in [Rand,Ror,Rxor,Rnxor]:
    mu = R.mu
    nms = sorted([ mu(*x,*x)[0]**2+mu(*x,*x)[1]**2 for x in unit_test_range ])
    print(nms)