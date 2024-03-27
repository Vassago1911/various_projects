
nonzero_standard_set = lambda n: sorted(range(1,n+1))
zero_standard_set = lambda n: sorted(range(n))

standard_set = zero_standard_set

def theta(k:int,l:int):
    p1 = [ ( j - min(standard_set(k)) )*len(standard_set(l)) + i
           for j in standard_set(k) for i in standard_set(l) ]
    p2 = [ ( i - min(standard_set(k)) )*len(standard_set(k)) + j
           for j in standard_set(k) for i in standard_set(l) ]
    assert len(p1)==len(p2)
    assert len(p1)==k*l
    trsl1 = dict(zip(p1,p2))
    swapper1 = lambda x: trsl1[x]
    trsl2 = dict(zip(p2,p1))
    swapper2 = lambda x: trsl2[x]
    test1 = all([ swapper1(v) == p2[k]  for k,v in enumerate(p1) ])
    test2 = all([ swapper2(v) == p1[k]  for k,v in enumerate(p2) ])
    test3 = all([ swapper2(swapper1(v)) == v for v in p1 ])
    test4 = all([ swapper1(swapper2(v)) == v for v in p2 ])
    assert test1 and test2 and test3 and test4
    return [ p1, p2, swapper1, swapper2 ]

def theta_zero(k,l):
    p1 = [ ( j - min(standard_set(k)) )*len(standard_set(l)) + i
           for j in standard_set(k) for i in standard_set(l) ]
    p2 = [ ( i - min(standard_set(k)) )*len(standard_set(k)) + j
           for j in standard_set(k) for i in standard_set(l) ]
    swap1 = lambda z: \
        (( z // len(standard_set(l)) ) + min(standard_set(k))) \
      + len(standard_set(k)) * \
          ( ( z % len(standard_set(l)) ) - min(standard_set(k)) )
    swap2 = lambda z: \
        (( z // len(standard_set(k)) ) + min(standard_set(l))) \
      + len(standard_set(l)) * \
          ( ( z % len(standard_set(k)) ) - min(standard_set(l)) )
    test1 = all([ swap1(v) == p2[k]  for k,v in enumerate(p1) ])
    test2 = all([ swap2(v) == p1[k]  for k,v in enumerate(p2) ])
    test3 = all([ swap2(swap1(v)) == v for v in p1 ])
    test4 = all([ swap1(swap2(v)) == v for v in p2 ])
    assert test1 and test2 and test3 and test4
    return [p1,p2,swap1]

p1, p2, swap1, swap2 = theta(5,7)

print(p1)
print(p2)

p1, p2, swap = theta_zero(5,7)
print(p1)
print(p2)
