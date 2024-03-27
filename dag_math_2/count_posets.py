def total_order(n:int):
    return set([ (i,j) for i in range(n+1) for j in range(n+1) if i<j ])

def gen_subsets(S:set[int])->set[set[int]]:
    #print(S)
    k = len(S)
    if k==0:
        return ((),)
    if k>=1:
        res = set()
        for s in S:
            S_s = set(S).copy()
            S_s.discard(s)
            tmp = gen_subsets(S_s)
            tmp = tuple(sorted(set( map(lambda t: tuple(sorted(t)), list(tmp)+list(map(lambda x: tuple( [s,]+list(x) ) ,tmp))  )    )))
            res = res.union( tmp )
        res = sorted(res, key = lambda x: ( len(x),x ) )
        return res

def subsets_of_total_order(n:int):
    N_order = total_order(n)
    all_subsets = gen_subsets(list(N_order))
    return all_subsets

def transitive_subsets_of_total_order(n:int):
    def is_transitive(c):
        if len(c)<=1:
            return True
        vertices = sorted(set(list(map(lambda x: x[0],c ))+list(map(lambda x: x[1],c ))))
        for v in sorted(vertices):
            for _,w in filter(lambda x: x[0]==v, c):
                for _,y in filter(lambda x: x[0]==w, c):
                    if not ( (v,y) in c ):
                        return False
        # found no contradicting edge
        return True
    candidates = subsets_of_total_order(n)
    return sorted( c for c in candidates if is_transitive(c) )

test = transitive_subsets_of_total_order(4)