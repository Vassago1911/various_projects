def omega_pi(nm:tuple[int,int])->int:
    n,m=nm
    Mx,mi=max(n,m),min(n,m)
    if n<=m:
        return Mx*Mx+m+mi
    if m<n:
        return Mx*Mx+mi
    assert 1==0, "error, we should never get here!"

def varphi_pi(n:int)->tuple[int,int]:
    k=int(n**.5)
    ix = n - k*k - k
    if ix < 0:
        return (k,ix+k)
    return (ix,k)

test_range = sorted([ (n,m) for n in range(10**3,6*10**3) for m in range(1*10**3,6*10**3) ])
mapped_range = set(map(omega_pi,test_range))
test_range_back = sorted(set(map(varphi_pi,mapped_range)))
mapped_range2 = set(map(omega_pi,test_range_back))
assert len(test_range)==len(mapped_range)
assert len(test_range_back)==len(mapped_range)
assert len(mapped_range2)==len(test_range_back)