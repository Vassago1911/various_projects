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
        comm_test_range = [tuple(list(x)+list(y)) for x in test_range for y in test_range]
        comm_pred = lambda a,b,c,d: self.mu(a,b,c,d)==self.mu(c,d,a,b)
        assert all([ self.mu(*self.unit,*x)==x for x in test_range]), "mu not left-unital, wtf?"
        assert all([ self.mu(*x,*self.unit)==x for x in test_range]), "mu not right-unital, wtf?"
        assert all([ ass12(*a)==ass21(*a) for a in ass_test_range ]), "mu not associative, wtf!?"
        assert all([ comm_pred(*t) for t in comm_test_range ]), "mu not commutative, wtf?"
        #check distr? TODO: find all units with a solid argument

Rand = Zmult(type=0)
Ror = Zmult(type=1)
Rxor = Zmult(type=2)
Rnxor = Zmult(type=3)

unit_test_range = [ (k,l) for k in range(-6,6) for l in range(-6,6) ]

for R in [Rand,Ror,Rxor,Rnxor]:
    mu = R.mu
    nms = sorted([ mu(*x,*x)[0]**2+mu(*x,*x)[1]**2 for x in unit_test_range ])
    #print(nms)

def mand(a:tuple[int,int]=(0,0),b:tuple[int,int]=(0,0))->tuple[int,int]:
    k,l = a; m,n = b
    res = (k*m+l*m+k*n,l*n)
    return tuple(map(sympy.expand,res))
def mxor(a:tuple[int,int]=(0,0),b:tuple[int,int]=(0,0))->tuple[int,int]:
    k,l = a; m,n = b
    res = (k*m+l*n,l*m+k*n)
    return tuple(map(sympy.expand,res))
def mnxor(a:tuple[int,int]=(0,0),b:tuple[int,int]=(0,0))->tuple[int,int]:
    k,l = a; m,n = b
    res = (l*m+k*n,k*m+l*n)
    return tuple(map(sympy.expand,res))
def mor(a:tuple[int,int]=(0,0),b:tuple[int,int]=(0,0))->tuple[int,int]:
    k,l = a; m,n = b
    res = (k*m,l*n+l*m+k*n)
    return tuple(map(sympy.expand,res))

umand = (0,1)

umxor = (1,0)
umor  = (1,0)

umnxor =(0,1)

import sympy
x,y = sympy.symbols("x y")
x0,x1,y0,y1,z0,z1 = sympy.symbols("x0 x1 y0 y1 z0 z1")
a,b,c = (x0,x1),(y0,y1),(z0,z1)

for mu,u in zip([mand,mxor,mnxor,mor],[umand,umxor,umnxor,umor]):
    assert (x,y) == mu(u,(x,y))
    assert (x,y) == mu((x,y),u)

for mu,lbl in zip([mand,mxor,mnxor,mor],["mand","umxor","umnxor","umor"]):
    #print(lbl)
    try:
        assert mu(mu(a,b),c) == mu(a,mu(b,c)), f"{mu(mu(a,b),c)}!={mu(a,mu(b,c))}"
        #print("associative!!")
    except:
        assert "non-associative mu found, code broken"
        #print("not associative!!")