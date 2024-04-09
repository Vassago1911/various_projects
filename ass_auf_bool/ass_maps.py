bl = set([0,1])
blxblxbl = [ (x,y,z) for x in bl for y in bl for z in bl ]

def powerset(iterable):
    from itertools import chain, combinations
    s = list(iterable).copy()
    res = list(chain.from_iterable(combinations(s,r) for r in range(len(s)+1) )).copy()
    return res

rels_blxblxbl = powerset(blxblxbl)

# map => forall (x,y) exists unique z in target st f(x,y)=z makes sense => nur subsets der maechtigkeit == target koennen ueberhaupt
# abbildungen werden

cand_maps = [ subs for subs in rels_blxblxbl if len(subs)==len(bl)**2 ]
# 70 remaining

def is_map(s):
    #note in particular s = [] is the unique identity map of the empty set in this world
    arguments_only = list(map(lambda x: x[:-1] , s))
    # for each source element exists unique target =>
    # each has one and only one target => iff (len(set(s))==len(set(arguments_only)))
    return len(set(s))==len(set(arguments_only))

def is_binary_map(s):
    if not is_map(s):
        return False
    # i.e. we already know s is a map, now we need a first component, a second component, and the targets to
    # be a subset of the first and second component, in addition first comp and second comp have to be
    # equal sets for a map S x S -> S
    try:
        s0 = set(map(lambda x: x[0],s))
        s1 = set(map(lambda x: x[1],s))
        ts = set(map(lambda x: x[2],s))
        return (s0==s1) and (ts.issubset(s0))
    except:
        # failed in the projections, e.g. x[2] does not exist -> not binary
        # if even x[1] does not exist for some x in s, it's not even a map
        return False

maps = [ mp for mp in cand_maps if is_binary_map(mp) ]

def is_associative(mp):
    assert is_binary_map(mp), "not binary, can't be (endo)associative SxSxS->S"
    s_mp = set(map(lambda x: x[0],mp))
    ass3_source = [ (s0,s1,s2) for s0 in s_mp for s1 in s_mp for s2 in s_mp ]
    mp_dict = dict(map(lambda x: (x[:-1],x[-1]),mp) )
    b = lambda x,y: mp_dict[(x,y)]
    #because binary, we have (x,b(y,z)) in mp_dict.keys()
    b21 = lambda x,y,z: b(x,b(y,z))
    b12 = lambda x,y,z: b(b(x,y),z)
    return all([ b21(*a)==b12(*a)  for a in ass3_source ])

ass_maps = [ mp for mp in maps if is_associative(mp) ]