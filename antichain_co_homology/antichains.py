class antichain_to_homology_transformer:
    def __init__(self,antichain:list[tuple]):
        ptl_achain = sorted(antichain, key = lambda x: (-len(x),x))
        # make any sub-poset of p_fin(N) into an antichain
        achain = [ s for s in ptl_achain if all( [ not set(s).issubset(set(t)) for t in ptl_achain if s!=t ] ) ]
        self.antichain = achain
    def _gen_scx(self):
        def flags_from_max_flags(mflags):
            def powerset(iterable):
                from itertools import chain, combinations
                "powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
                s = list(iterable)
                return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))
            fl = mflags.copy()
            all_flags = mflags.copy()
            for flag in mflags:
                contained_flags = powerset(flag)
                all_flags += contained_flags
                all_flags = sorted(set(all_flags),key=lambda x: (-len(x),x))
            return all_flags
        self._scx = flags_from_max_flags( self.antichain )
    @property
    def scx(self):
        try:
            return self._scx
        except:
            self._gen_scx()
            return self._scx
    @property
    def h(self):
        try:
            return self._h
        except:
            import numpy as np
            def sub_d(s_flags,t_flags):
                from sympy import Matrix
                if len(s_flags)==0:
                    return ()
                if len(t_flags)==0:
                    #kill them all! :D
                    return Matrix(tuple(len(s_flags)*[0]))
                assert len(s_flags)>0
                assert len(t_flags)>0
                A = np.zeros((len(t_flags),len(s_flags)),dtype=np.int8)
                for i,s in enumerate(s_flags):
                    for j in range(len(s)):
                        sign = (-1)**j; b = tuple(sorted(set(list(s[:j])+list(s[j+1:]))))
                        A[t_flags.index(b),i] = sign
                return Matrix(A)
            scx = self.scx
            max_dim = max(map(len,scx))
            ds = list()
            for i in range(max_dim,-2,-1):
                scx_n = sorted(set(filter(lambda x: len(x)==(i+1), scx)),key=lambda x: (-len(x),x))
                scx_n_1 = sorted(set(filter(lambda x: len(x)==i, scx)),key=lambda x: (-len(x),x))
                ds += [sub_d(scx_n,scx_n_1)]
            ds = dict(reversed(list(enumerate( reversed(ds)))))
            for i in ds.keys():
                if (i-1) in ds.keys():
                    if ( len(ds[i])>0 ) and (len(ds[i-1])>1):
                        assert abs(np.array( ds[i-1]*ds[i] )).max() == 0, "not boundaries"
            ds = { k-1: ds[k] for k in ds.keys() }
            #h_ds = dict()
            import numpy as np
            for k in ds.keys():
                if k-1 in ds.keys():
                    P,I = ds[k-1],ds[k]
                    if P and I:
                        assert abs(np.array(P*I)).max() == 0
            h_ds = dict()
            from sympy import Matrix
            from sympy.matrices.normalforms import smith_normal_form as _snf
            def snf(A):
                d = _snf(A)
                #by guarantee, only elements are diagonal, non-zero by injective B->Z input
                d = np.array(d)
                res = []
                for i in range(min(d.shape)):
                    if abs(d[i,i]) not in (0,1):
                        res+=[abs(d[i,i])]
                if len(res)==0:
                    return ""
                return "+".join([f"Z/{r}Z" for r in res])
            for k in ds.keys():
                try:
                    z = Matrix(np.hstack(ds[k].nullspace()))
                except:
                    z = 0
                try:
                    b = Matrix(np.hstack(ds[k+1].columnspace()))
                except:
                    b = 0
                if ( z==0 ):
                    h_ds[k] = 0
                else:
                    if ( b==0 ):
                        h_ds[k] = f"Z^{min(z.shape)}" if min(z.shape) > 1 else ("Z" if min(z.shape)==1 else "")
                    elif (b==z):
                        h_ds[k] = "0"
                    else:
                        t = z.solve(b)
                        assert t.rank()==min(t.shape), "t not mono, broken"
                        free_rk = min(z.shape) - t.rank()
                        if len(snf(t))>0:
                            if free_rk>0:
                                if free_rk>1:
                                    h_ds[k] = (f"Z^{free_rk}", snf(t))
                                else:
                                    h_ds[k] = ("Z", snf(t))
                            else:
                                h_ds[k] = snf(t)
                        elif free_rk>0:
                            if free_rk>1:
                                h_ds[k] = f"Z^{free_rk}"
                            else:
                                h_ds[k] = "Z"
                        else:
                            h_ds[k] = 0
            del h_ds[-1]
            K = max(h_ds.keys())
            #delete top helper 0
            if not h_ds[K]:
                del h_ds[K]
            # h[0] always free => h_ds[0] == free_rk
            pi_0_count = str(int(h_ds[0])+1)
            h_ds[0] = "Z" if (pi_0_count == "1") else f"Z^{pi_0_count}"
            #i.e. ds defines a chain complex, or cochain complex in transposed
            self._h = h_ds
            self._h = {k:self._h[k] for k in sorted(self._h.keys())}
            return self._h
    @property
    def co_h(self):
        try:
            return self._co_h
        except:
            import numpy as np
            def sub_d(s_flags,t_flags):
                from sympy import Matrix
                if len(s_flags)==0:
                    return ()
                if len(t_flags)==0:
                    #kill them all! :D
                    return Matrix(tuple(len(s_flags)*[0]))
                assert len(s_flags)>0
                assert len(t_flags)>0
                A = np.zeros((len(t_flags),len(s_flags)),dtype=np.int8)
                for i,s in enumerate(s_flags):
                    for j in range(len(s)):
                        sign = (-1)**j; b = tuple(sorted(set(list(s[:j])+list(s[j+1:]))))
                        A[t_flags.index(b),i] = sign
                return Matrix(A)
            scx = self.scx
            max_dim = max(map(len,scx))
            ds = list()
            for i in range(max_dim,-2,-1):
                scx_n = sorted(set(filter(lambda x: len(x)==(i+1), scx)),key=lambda x: (-len(x),x))
                scx_n_1 = sorted(set(filter(lambda x: len(x)==i, scx)),key=lambda x: (-len(x),x))
                ds += [sub_d(scx_n,scx_n_1)]
            ds = dict(reversed(list(enumerate( reversed(ds)))))
            for i in ds.keys():
                if (i-1) in ds.keys():
                    if ( len(ds[i])>0 ) and (len(ds[i-1])>1):
                        assert abs(np.array( ds[i-1]*ds[i] )).max() == 0, "not boundaries"
            ds = { k-2: ds[k].T if len(ds[k])>0 else ds[k] for k in ds.keys()  }
            del ds[-1]; del ds[-2]
            max_k = max(ds.keys())
            from sympy import Matrix; from numpy import zeros
            ds[max_k] = Matrix(zeros((1,ds[max_k-1].shape[0])))

            import numpy as np; from sympy import Matrix; from sympy.matrices.normalforms import smith_normal_form as snf
            co_h = dict()
            co_h[0] = ( len(ds[0].nullspace()), [])
            for n in ds.keys():
                if n==0:
                    continue
                z,b = Matrix(np.hstack(ds[n].nullspace())),Matrix(np.hstack(ds[n-1].columnspace()))
                t = snf(z.solve(b))
                t = np.array(t)
                free_rk = max(t.shape) - min(t.shape)
                tor = list()
                for i in range(min(t.shape)):
                    if abs(t[i,i]) > 1:
                        tor += [abs(t[i,i])]
                    if abs(t[i,i]) == 0:
                        free_rk+=1
                co_h[n] = (free_rk,tor)

            new_coh = { k:co_h[k] for k in sorted(co_h.keys()) }

            coh_str = dict()
            for k in new_coh.keys():
                rk = new_coh[k][0]
                tors = new_coh[k][1]
                free_str = "0" if rk==0 else ("Z" if rk ==1 else f"Z^{rk}")
                tor_str = "+".join( [f"Z/{k}Z" for k in tors] )
                if free_str != "0":
                    tot_str = free_str
                    if len(tor_str)>0:
                        tot_str = tot_str+"+"+tor_str
                else:
                    tot_str = tor_str
                tot_str = 0 if len(tot_str)==0 else tot_str
                coh_str[k] = tot_str
            return coh_str
#s1
bx = antichain_to_homology_transformer([(0,2),(0,3),(1,2),(1,3)])
#<1s
#print(bx.h)

#s2
cx = antichain_to_homology_transformer([(0,2,4),(0,2,5),(0,3,4),(0,3,5),(1,2,4),(1,2,5),(1,3,4),(1,3,5)])
#<1s
#print(cx.h)

#rp2
dx = antichain_to_homology_transformer([(0,1,5),(1,2,5),(2,5,6),(0,2,6),(0,1,6),(1,4,6),(1,2,4),(0,2,4),(0,4,5),(4,5,6)])
#<1s
#print(dx.h)

#t3
ex = antichain_to_homology_transformer([(0,2,10,42),(0,2,10,58),(0,2,14,46),(0,2,14,62),(0,2,34,42),(0,2,34,46),(0,2,50,58),(0,2,50,62),(0,3,11,43),(0,3,11,59),(0,3,15,47),(0,3,15,63),(0,3,35,43),(0,3,35,47),(0,3,51,59),(0,3,51,63),(0,8,10,42),(0,8,10,58),(0,8,11,43),(0,8,11,59),(0,8,40,42),(0,8,40,43),(0,8,56,58),(0,8,56,59),(0,12,14,46),(0,12,14,62),(0,12,15,47),(0,12,15,63),(0,12,44,46),(0,12,44,47),(0,12,60,62),(0,12,60,63),(0,32,34,42),(0,32,34,46),(0,32,35,43),(0,32,35,47),(0,32,40,42),(0,32,40,43),(0,32,44,46),(0,32,44,47),(0,48,50,58),(0,48,50,62),(0,48,51,59),(0,48,51,63),(0,48,56,58),(0,48,56,59),(0,48,60,62),(0,48,60,63),(1,2,10,42),(1,2,10,58),(1,2,14,46),(1,2,14,62),(1,2,34,42),(1,2,34,46),(1,2,50,58),(1,2,50,62),(1,3,11,43),(1,3,11,59),(1,3,15,47),(1,3,15,63),(1,3,35,43),(1,3,35,47),(1,3,51,59),(1,3,51,63),(1,9,10,42),(1,9,10,58),(1,9,11,43),(1,9,11,59),(1,9,41,42),(1,9,41,43),(1,9,57,58),(1,9,57,59),(1,13,14,46),(1,13,14,62),(1,13,15,47),(1,13,15,63),(1,13,45,46),(1,13,45,47),(1,13,61,62),(1,13,61,63),(1,33,34,42),(1,33,34,46),(1,33,35,43),(1,33,35,47),(1,33,41,42),(1,33,41,43),(1,33,45,46),(1,33,45,47),(1,49,50,58),(1,49,50,62),(1,49,51,59),(1,49,51,63),(1,49,57,58),(1,49,57,59),(1,49,61,62),(1,49,61,63),(4,6,10,42),(4,6,10,58),(4,6,14,46),(4,6,14,62),(4,6,38,42),(4,6,38,46),(4,6,54,58),(4,6,54,62),(4,7,11,43),(4,7,11,59),(4,7,15,47),(4,7,15,63),(4,7,39,43),(4,7,39,47),(4,7,55,59),(4,7,55,63),(4,8,10,42),(4,8,10,58),(4,8,11,43),(4,8,11,59),(4,8,40,42),(4,8,40,43),(4,8,56,58),(4,8,56,59),(4,12,14,46),(4,12,14,62),(4,12,15,47),(4,12,15,63),(4,12,44,46),(4,12,44,47),(4,12,60,62),(4,12,60,63),(4,36,38,42),(4,36,38,46),(4,36,39,43),(4,36,39,47),(4,36,40,42),(4,36,40,43),(4,36,44,46),(4,36,44,47),(4,52,54,58),(4,52,54,62),(4,52,55,59),(4,52,55,63),(4,52,56,58),(4,52,56,59),(4,52,60,62),(4,52,60,63),(5,6,10,42),(5,6,10,58),(5,6,14,46),(5,6,14,62),(5,6,38,42),(5,6,38,46),(5,6,54,58),(5,6,54,62),(5,7,11,43),(5,7,11,59),(5,7,15,47),(5,7,15,63),(5,7,39,43),(5,7,39,47),(5,7,55,59),(5,7,55,63),(5,9,10,42),(5,9,10,58),(5,9,11,43),(5,9,11,59),(5,9,41,42),(5,9,41,43),(5,9,57,58),(5,9,57,59),(5,13,14,46),(5,13,14,62),(5,13,15,47),(5,13,15,63),(5,13,45,46),(5,13,45,47),(5,13,61,62),(5,13,61,63),(5,37,38,42),(5,37,38,46),(5,37,39,43),(5,37,39,47),(5,37,41,42),(5,37,41,43),(5,37,45,46),(5,37,45,47),(5,53,54,58),(5,53,54,62),(5,53,55,59),(5,53,55,63),(5,53,57,58),(5,53,57,59),(5,53,61,62),(5,53,61,63),(16,18,26,42),(16,18,26,58),(16,18,30,46),(16,18,30,62),(16,18,34,42),(16,18,34,46),(16,18,50,58),(16,18,50,62),(16,19,27,43),(16,19,27,59),(16,19,31,47),(16,19,31,63),(16,19,35,43),(16,19,35,47),(16,19,51,59),(16,19,51,63),(16,24,26,42),(16,24,26,58),(16,24,27,43),(16,24,27,59),(16,24,40,42),(16,24,40,43),(16,24,56,58),(16,24,56,59),(16,28,30,46),(16,28,30,62),(16,28,31,47),(16,28,31,63),(16,28,44,46),(16,28,44,47),(16,28,60,62),(16,28,60,63),(16,32,34,42),(16,32,34,46),(16,32,35,43),(16,32,35,47),(16,32,40,42),(16,32,40,43),(16,32,44,46),(16,32,44,47),(16,48,50,58),(16,48,50,62),(16,48,51,59),(16,48,51,63),(16,48,56,58),(16,48,56,59),(16,48,60,62),(16,48,60,63),(17,18,26,42),(17,18,26,58),(17,18,30,46),(17,18,30,62),(17,18,34,42),(17,18,34,46),(17,18,50,58),(17,18,50,62),(17,19,27,43),(17,19,27,59),(17,19,31,47),(17,19,31,63),(17,19,35,43),(17,19,35,47),(17,19,51,59),(17,19,51,63),(17,25,26,42),(17,25,26,58),(17,25,27,43),(17,25,27,59),(17,25,41,42),(17,25,41,43),(17,25,57,58),(17,25,57,59),(17,29,30,46),(17,29,30,62),(17,29,31,47),(17,29,31,63),(17,29,45,46),(17,29,45,47),(17,29,61,62),(17,29,61,63),(17,33,34,42),(17,33,34,46),(17,33,35,43),(17,33,35,47),(17,33,41,42),(17,33,41,43),(17,33,45,46),(17,33,45,47),(17,49,50,58),(17,49,50,62),(17,49,51,59),(17,49,51,63),(17,49,57,58),(17,49,57,59),(17,49,61,62),(17,49,61,63),(20,22,26,42),(20,22,26,58),(20,22,30,46),(20,22,30,62),(20,22,38,42),(20,22,38,46),(20,22,54,58),(20,22,54,62),(20,23,27,43),(20,23,27,59),(20,23,31,47),(20,23,31,63),(20,23,39,43),(20,23,39,47),(20,23,55,59),(20,23,55,63),(20,24,26,42),(20,24,26,58),(20,24,27,43),(20,24,27,59),(20,24,40,42),(20,24,40,43),(20,24,56,58),(20,24,56,59),(20,28,30,46),(20,28,30,62),(20,28,31,47),(20,28,31,63),(20,28,44,46),(20,28,44,47),(20,28,60,62),(20,28,60,63),(20,36,38,42),(20,36,38,46),(20,36,39,43),(20,36,39,47),(20,36,40,42),(20,36,40,43),(20,36,44,46),(20,36,44,47),(20,52,54,58),(20,52,54,62),(20,52,55,59),(20,52,55,63),(20,52,56,58),(20,52,56,59),(20,52,60,62),(20,52,60,63),(21,22,26,42),(21,22,26,58),(21,22,30,46),(21,22,30,62),(21,22,38,42),(21,22,38,46),(21,22,54,58),(21,22,54,62),(21,23,27,43),(21,23,27,59),(21,23,31,47),(21,23,31,63),(21,23,39,43),(21,23,39,47),(21,23,55,59),(21,23,55,63),(21,25,26,42),(21,25,26,58),(21,25,27,43),(21,25,27,59),(21,25,41,42),(21,25,41,43),(21,25,57,58),(21,25,57,59),(21,29,30,46),(21,29,30,62),(21,29,31,47),(21,29,31,63),(21,29,45,46),(21,29,45,47),(21,29,61,62),(21,29,61,63),(21,37,38,42),(21,37,38,46),(21,37,39,43),(21,37,39,47),(21,37,41,42),(21,37,41,43),(21,37,45,46),(21,37,45,47),(21,53,54,58),(21,53,54,62),(21,53,55,59),(21,53,55,63),(21,53,57,58),(21,53,57,59),(21,53,61,62),(21,53,61,63)])
#3min 18s
#print(ex.h)
#print(ex.co_h)

#dag_rp2
fx = antichain_to_homology_transformer([(0,1,5),(0,1,7),(0,3,5),(0,3,7),(1,2,4),(1,2,6),(1,4,7),(1,5,6),(2,3,5),(2,3,7),(2,4,5),(2,6,7),(4,5,6),(4,6,7)])

#t2
gx = antichain_to_homology_transformer([(0,2,10),(0,2,14),(0,3,11),(0,3,15),(0,8,10),(0,8,11),(0,12,14),(0,12,15),(1,2,10),(1,2,14),(1,3,11),(1,3,15),(1,9,10),(1,9,11),(1,13,14),(1,13,15),(4,6,10),(4,6,14),(4,7,11),(4,7,15),(4,8,10),(4,8,11),(4,12,14),(4,12,15),(5,6,10),(5,6,14),(5,7,11),(5,7,15),(5,9,10),(5,9,11),(5,13,14),(5,13,15)])

#s3
hx = antichain_to_homology_transformer([(0,2,4,6),(0,2,4,7),(0,2,5,6),(0,2,5,7),(0,3,4,6),(0,3,4,7),(0,3,5,6),(0,3,5,7),(1,2,4,6),(1,2,4,7),(1,2,5,6),(1,2,5,7),(1,3,4,6),(1,3,4,7),(1,3,5,6),(1,3,5,7)])