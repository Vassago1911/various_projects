#TODO: alle abbildungen konstruieren war wohl schon unsinn fuer s1**(s1.subdivision)
# also: homologie! kann von 2: s1.subdivision -> s1 zeigen, dass es nicht nullhomotop
# ist!

class dag:
    def __init__(self):
        self.nodes = list()
        self.edges = list()
        self.annotations = dict()
    def add_vertex(self,n:int)->None:
        self.add_edge(n,n)
    def add_vertices(self,ns:list[int])->None:
        for n in ns:
            self.add_vertex(n)
    def add_edges(self,es:list[tuple[int,int]])->None:
        for e,f in es:
            self.add_edge(e,f)
    def add_edge(self,n:int,m:int)->None:
        try:
            del self._flags
        except:
            pass
        #k,l=n,m # <= mapping spaces, do we have if backward edge, then forward edge?
        k,l = (n,m) if n<=m else (m,n)
        self.edges += [(k,l)]
        self.edges = sorted(set(self.edges))
        nodes = sorted(set( list(map(lambda x: x[0],self.edges)) + list(map(lambda x: x[1],self.edges)) ))
        self.nodes = nodes
        self.edges = sorted(set(list(self.edges)+list(map(lambda x: (x,x),self.nodes))))
    def __repr__(self):
        edge_str_map = lambda x: '_'.join(list(map(str,x)))
        node_str = 'vertices: '+' '.join(list(map(str,self.nodes)))+'\n'
        edges = list(filter(lambda x: x[0]!=x[1],self.edges))
        edge_str = 'edges: '+' '.join(list(map(edge_str_map,edges)))+'\n'
        flags = self.max_flags
        flags_str = 'max_flags: '+' '.join(list(map(edge_str_map,flags)))+'\n'
        annotations = self.annotations
        annotations_str = "\n"
        if len(annotations)>0:
            annotations_str += "annotations: "+str(annotations)
        return flags_str
        return node_str+edge_str+flags_str+annotations_str
    def __neg__(self):
        vertices = self.node_list
        max_V = max(vertices)
        new_edge_list = list(map(lambda x: (max_V - x[1],max_V - x[0]), self.edge_list))
        tmp = dag()
        tmp.add_edges(new_edge_list)
        return tmp
    # def __add__(self,other):
    #     tmp = dag()
    #     g_edges = self.edges
    #     h_edges = other.edges
    #     for g0,g1 in g_edges:
    #         tmp.add_edge(2*g0,2*g1)
    #     for h0,h1 in h_edges:
    #         tmp.add_edge(2*h0+1,2*h1+1)
    #     return tmp
    def __add__(self,other):
        #finite style just makes more sense here
        tmp = dag()
        g_edges = self.full_edge_list
        h_edges = other.full_edge_list
        #print(g_edges,h_edges)
        max_g = max(max(map(lambda x: x[0],g_edges)),max(map(lambda x: x[1],g_edges)))
        for g0,g1 in g_edges:
            tmp.add_edge(g0,g1)
        for h0,h1 in h_edges:
            tmp.add_edge(max_g+1+h0,max_g+1+h1)
        return tmp
    # def __mul__(self,other):
    #     def omega_pi(n,m):
    #         if n<=m:
    #             return m*(m+1)+n
    #         return n*n+m
    #     tmp = dag()
    #     g_edges = self.edges
    #     h_edges = other.edges
    #     for g0,g1 in g_edges:
    #         for h0,h1 in h_edges:
    #             tmp.add_edge(omega_pi(g0,h0),omega_pi(g1,h1))
    #     return tmp
    def __mul__(self,other):
        _omega = lambda N,M,k,l: k*(M+1)+l
        _omega_pi = lambda N,M: (lambda k,l: _omega(N,M,k,l))
        N,M = max(self.node_list),max(other.node_list)
        omega_pi = _omega_pi(N,M)
        tmp = dag()
        tmp_annotation = dict()
        helper_annotation = dict() if len(self.annotations)==0 else self.annotations
        for e,f in self.full_edge_list:
            for g,h in other.full_edge_list:
                if (e,g)==(f,h):
                    if len(helper_annotation)==0:
                        tmp_annotation[omega_pi(e,g)] = (e,g)
                    else:
                        v = helper_annotation[e]
                        tmp_annotation[omega_pi(e,g)] = (*v,g)
                tmp.add_edge(omega_pi(e,g),omega_pi(f,h))
        tmp.annotations = tmp_annotation
        return tmp
    def __rshift__(self,other):
        g = self.compressed; h = other.compressed
        g_edges = g.full_edge_list
        max_g = max(max(map(lambda x: x[0],g_edges)),max(map(lambda x: x[1],g_edges)))
        tmp = g+h
        for gv in g.nodes:
            for hv in h.nodes:
                tmp.add_edge(gv,hv+1+max_g)
        return tmp
    @property
    def suspension(self):
        tmp = dag()
        max_node = max(self.nodes)
        for g0,g1 in self.edges:
            tmp.add_edge(g0,g1)
            tmp.add_edge(g0,max_node+1)
            tmp.add_edge(g1,max_node+1)
            tmp.add_edge(g0,max_node+2)
            tmp.add_edge(g1,max_node+2)
        return tmp
    @property
    def node_list(self):
        return [x for (x,y) in self.edges if x==y]
    @property
    def edge_list(self):
        return [(x,y) for (x,y) in self.edges if x!=y]
    @property
    def full_edge_list(self):
        return [(v,v) for v in self.node_list]+self.edge_list
    def __le__(self,other):
        nodes_subset = set(self.node_list).issubset(set(other.node_list))
        edges_subset = set(self.edge_list).issubset(set(other.edge_list))
        subset = nodes_subset and edges_subset
        return subset

    def __ge__(self,other):
        return other <= self

    def __lt__(self,other):
        return ( self <= other ) and ( len(self.edge_list) < len(other.edge_list) )

    def __gt__(self,other):
        return other < self

    def __eq__(self,other):
        return (( self <= other ) and ( self >= other))

    #kind of works, vertices are maps by definition
    #but we miss homotopies which go "the wrong way": I**I has vertices 0 1 2 and edges 01 02 12 10 21
    #so, we shall only use monotonic edges intentionally, so we include into all homotopies, but we are
    #faaaaar to strong for X**I to be a path object, not flabby enough
    def __pow__(self,other):
        # a bijection N x N -> N
        def omega_pi(n,m):
            if n<=m:
                return m*(m+1)+n
            return n*n+m
        # a bijection N x N x .. x N (len(n) factors) -> N
        def right_ass_omega_pi(n:list[int]):
            if len(n)==0:
                return 0
            if len(n)==1:
                return n[0]
            return omega_pi(n[0],right_ass_omega_pi(n[1:]))
        def fin_tuples(_source:int,_target:int)->list[list[int]]:
            if _source == 0:
                return [[]]
            res = []
            for i in range(_target):
                for t in fin_tuples(_source-1,_target):
                    res.append(tuple([i]+list(t)))
            return res
        # we will not even start, if self and other are not compressed, otherwise this will explode
        source,target=other.compressed,self.compressed
        s,t = source,target
        max_S, max_T = max(s.node_list), max(t.node_list)
        assert all([(i,i) in s.edges for i in range(max_S+1)])
        assert all([(i,i) in t.edges for i in range(max_T+1)])
        # now we know s and t are each minimal, so starting with all |s| tuples in range(max_T+1) is still expensive
        # but minimised
        vertex_candidates = fin_tuples(max_S+1,max_T+1)
        real_vertices = dict()
        tuple_to_map = lambda x: ( lambda ix: x[ix] )
        tmp = dag()
        source_edges = sorted(set(s.full_edge_list))
        target_edges = set(t.full_edge_list)
        for v in vertex_candidates:
            vmap = tuple_to_map(v)
            range_edges = set([ (vmap(e),vmap(f))  for e,f in source_edges ])
            if range_edges.issubset(target_edges):
                v_ix = right_ass_omega_pi(v)
                tmp.add_vertex(right_ass_omega_pi(v))
                real_vertices[v_ix] = v
        for v in tmp.node_list:
            for w in tmp.node_list:
                vmap = tuple_to_map(real_vertices[v])
                wmap = tuple_to_map(real_vertices[w])
                have_edge = all([ (vmap(e),wmap(f)) in t.full_edge_list for (e,f) in s.edge_list ])
                if have_edge:
                    #assert v<=w  # <- MEEEH
                    tmp.add_edge(v,w)
        tmp2 = dag()
        reduction = dict( list( map(lambda x: (x[1],x[0]), enumerate(tmp.node_list)) ) )
        for v in tmp.node_list:
            for _,w in list(filter(lambda x: (x[0]==v), tmp.full_edge_list)):
                tmp2.add_edge(reduction[v],reduction[w])
            for w,_ in list(filter(lambda x: x[1]==v, tmp.full_edge_list)):
                tmp2.add_edge(reduction[w],reduction[v])
        def is_flag_collapsible(t:list[int])->bool:
            flags = target.flags
            flags[0] = list(map(lambda x: (x,), target.node_list))
            candidate_flag = tuple(sorted(set(t)))
            if len(candidate_flag)==1:
                return True
            try:
                flags = flags[len(candidate_flag)-1]
            except:
                # we can't guarantee collapsibility here
                return False
            #print(candidate_flag,len(candidate_flag),flags)
            return candidate_flag in flags
        for v in tmp.node_list:
            tupv = real_vertices[v]
            if not is_flag_collapsible(tupv):
                tmp2.annotations[reduction[v]] = tupv
        return tmp2
    @property
    def flags(self):
        self._flags = dict()
        self._flags[0] = sorted(set(list(map(lambda x: (x[0],),self.edges))+list(map(lambda x: (x[1],),self.edges))))
        self._flags[1] = sorted(set(filter(lambda x: x[0]!=x[1], self.edges)))
        res = [1]; N=2
        while len(res)>0:
            self._flags[N]=list()
            for flag in self._flags[N-1]:
                for v in self._flags[0]:
                    node = v[0]
                    edge_test = all([ (((x,node) in self.edges) and (x!=node)) for x in flag ])
                    if edge_test:
                        self._flags[N] += [(*flag,node)]
            self._flags[N]=sorted(set(self._flags[N]))
            res = self._flags[N]
            N+=1
        return self._flags
    @property
    def max_flags(self):
        flags = set( sum( [ self.flags[k] for k in self.flags if k>=2 ], start=[]) + self.full_edge_list )
        max_flags = []
        for flag in flags:
            found_superset = False
            for test_flag in flags:
                if (len(test_flag)<len(flag)) or (test_flag == flag):
                    found_superset = False
                    continue
                if set(flag).issubset(set(test_flag)):
                    #flag not maximal, because test_flag > flag
                    found_superset = True
                    break
            if not found_superset:
                max_flags += [flag]
        return sorted(max_flags,key = lambda x: (len(x),x))
    #FIX: sehr langsam .. komm ich iwie um die 2**n'ness rum?
    @property
    def subdivision(self):
        def sd_coods(flag):
            return sum(list(map(lambda x: 2**x, flag)))-1
        tmp = dag()
        flags = self.flags
        flags[0] = list(map(lambda x: (x,), self.node_list))

        #the edges are the ones that note subset
        #relations between flags
        #the nodes specifically correspond to the identity of each existing flag
        flags0, flags1 = flags, flags
        for n in flags0.keys():
            for m in flags1.keys():
                for flag0 in flags0[n]:
                    for flag1 in flags1[m]:
                        #print(flag0,flag1)
                        #print(set(flag0).issubset(set(flag1)))
                        if set(flag0).issubset(set(flag1)):
                            #print(flag0,flag1)
                            s0 = sd_coods(flag0)
                            s1 = sd_coods(flag1)
                            #print("adding edge ",s0,s1)
                            tmp.add_edge(s0,s1)
        return tmp.compressed
    @property
    def compressed(self):
        max_N = max( self.node_list )
        vertex_dict = dict(list(map(lambda x: (x[1],x[0]),list(enumerate(self.node_list)))))
        tmp = dag()
        for e,f in self.edges:
            tmp.add_edge(vertex_dict[e],vertex_dict[f])
        return tmp
    @classmethod
    def discrete(cls,n:int=0):
        tmp = dag()
        for i in range(n+1):
            tmp.add_vertex(i)
        return tmp
    @classmethod
    def delta(cls,n:int=0):
        tmp = dag()
        tmp.add_vertex(0)
        for i in range(n+1):
            for j in range(i+1,n+1):
                tmp.add_edge(i,j)
        return tmp
    @classmethod
    def circle(cls,subdiv:int=0):
        tmp = dag()
        tmp.add_vertices([0,1])
        tmp = tmp.suspension
        if ( subdiv == 0 ):
            return tmp
        #TODO: return circle on 2*subdiv vertices
        return tmp
    @classmethod
    def sphere(cls,n:int=0):
        tmp = dag()
        tmp.add_vertices([0,1])
        for _ in range(n):
            tmp = tmp.suspension
        return tmp
    @classmethod
    def zig_zag(cls,n:int=0):
        tmp = dag()
        tmp.add_edge(*(0,1))
        for _ in range(n):
            tmp = tmp.subdivision
        tmp = tmp.compressed
        return tmp
    @classmethod
    def spine(cls,n:int=0):
        tmp=dag()
        if n==0:
            return tmp # no nodes, no edges, initial object
        for i in range(n+1):
            tmp.add_vertex(i)
        for i in range(n):
            tmp.add_edge(i,i+1)
        return tmp
    @classmethod
    def torus(cls,n:int=0):
        if n == 0:
            return dag()
        tmp = dag.discrete(0)
        for i in range(n):
            tmp = tmp*(dag.sphere(1))
        return tmp
    @classmethod
    def closed_spine(cls,n:int=0):
        tmp = cls.spine(n)
        tmp.add_edge(0,n+1)
        return tmp
    @property
    def boundary_maps(self):
        def flag_boundary(flag):
            res = dict()
            for i,_ in enumerate(flag):
                bdy_chain = flag[:i]+flag[i+1:]
                res[bdy_chain]=(-1)**i
            return res
        flags = self.flags
        all_flags = sum([flags[n] for n in flags.keys()],start=[]) + [(),]
        N_max = max(list(flags.keys()))
        ds = dict()
        for i in range(N_max,-1,-1):
            sources = flags[i]
            #target = flags[i-1] if i-1 >= 0 else [(),]
            ds[i]=dict()
            for s in sources:
                tmp = flag_boundary(s)
                reix_tmp = dict()
                for k in sorted(tmp.keys()):
                    reix_tmp[all_flags.index(k)]=tmp[k]
                ds[i][all_flags.index(s)] = reix_tmp

        dds = dict()
        for i in ds.keys():
            dds[i]=dict()
            for s in ds[i].keys():
                dds[i][s]=dict()
                for k in sorted(ds[i][s].keys()):
                    dds[i][s][k]=ds[i][s][k]
        return dds
    @property
    def tot_matrix_bdy(self):
        def mat_sum(A,B):
            import numpy as np
            if len(A)==0:
                return B
            if len(B)==0:
                return A
            if len(A[0])==0:
                return B
            if len(B[0])==0:
                return A
            n,m = len(A)+len(B),len(A[0])+len(B[0])
            Z = np.zeros((n,m),dtype=np.int8)
            Z[:len(A),:len(A[0])] = A
            Z[len(A):,len(A[0]):] = B
            return Z
        bdies = self.boundary_maps
        N = len(bdies)
        ds = list()
        for ix in range(N):
            bdy = bdies[ix]
            s_key_cds = dict(zip( sorted(set([ k for k in bdy ]+[ kk for k in bdy for kk in bdy[k] ])),range(10**6)))
            n = len(s_key_cds)
            import numpy as np
            A = np.zeros((n,n),dtype=np.int8)
            for s_ix in bdy.keys():
                t_vs = bdy[s_ix]
                for t_ix in t_vs.keys():
                    i,j = s_key_cds[s_ix],s_key_cds[t_ix]
                    A[i,j] = t_vs[t_ix]
            ds += [A]
        d_tot = []
        for d in ds:
            d_tot = mat_sum(d_tot,d)
        d = d_tot
        assert d.shape[0]==d.shape[1]
        assert (d@d).max() == 0
        return d_tot
    @property
    def tot_bdy(self):
        # a strictly lower triangular matrix representing all boundary maps simultaneously
        # the cycles can be calculated as its kernel, the boundaries as its image, and eventually the
        # degrees recovered to make it into the dimension-graded homology we expect
        # so ziemlich das gegenteil von diagonalisierbar: eigenwerte sind alle null wegen d^2 = 0, aber eigenraum hat dim 1 wegen augmentation
        flags = self.flags
        flags[-1] = [(),]
        flag_list = sorted(sum([flags[k] for k in flags.keys()],start=[]),key = lambda x: (-len(x),x))
        import numpy as np
        A = np.zeros((len(flag_list),len(flag_list)),dtype=np.int8)
        for i,flag in enumerate(flag_list):
            for j in range(len(flag)):
                sign = (-1)**j; bdj = tuple(sorted(flag[:j]+flag[j+1:]))
                if flag_list.count(bdj)==0:
                    continue
                assert flag_list.count(bdj)==1
                t_ix = flag_list.index(bdj)
                A[t_ix,i] = sign
        assert (A@A).max()==0
        return A


#sieht deterministisch aus, aber bin out of date
s1 = dag.sphere(1).compressed
s11 = dag.sphere(1).subdivision.compressed
g = (s1+s11).compressed
s1_max = max(s1.nodes)+1

g.add_edge(0,4); g.add_edge(0,7); g.add_edge(0,10)
g.add_edge(1,5); g.add_edge(1,8); g.add_edge(1,11)
g.add_edge(2,6); g.add_edge(2,7); g.add_edge(2,8)
g.add_edge(3,9); g.add_edge(3,10); g.add_edge(3,11)
#assert matrix bdy squares to zero
d = g.tot_matrix_bdy
print(g)