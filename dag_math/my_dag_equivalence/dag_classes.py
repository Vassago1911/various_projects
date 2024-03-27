from dataclasses import dataclass, astuple, asdict

import numpy as np

def gauss(A):
    if ( ( A.shape[0] == 0 ) or (A.shape[1] == 0) ):
        return A
    S,T = np.eye(A.shape[0]),np.eye(A.shape[1])
    assert (S@A == A).all() and (A@T == A).all()
    current_row_and_col_cleaned_up = False
    while not current_row_and_col_cleaned_up:
        if np.abs(A).max() > 1:
            min_a_ix = np.unravel_index(np.argmin(np.abs(np.where(A==0,A.max(),A)), axis=None), A.shape)
        else:
            min_a_ix = np.unravel_index(np.argmin(np.where(np.abs(A)==0,2,np.abs(A)), axis=None), A.shape)
        last_min = A[*min_a_ix]
        print(last_min)
        if A[*min_a_ix] == 0:
            # pure zero matrix, nothing left to do
            return A
        #A sortieren nach erst zeile, dann spalte, aber vor allem nach abs(k), ausser 0
        for _ in range(2):
            A = A[:,
                  np.argsort( np.where(A[0]==0, A.max()+1, abs(A[0]) ))
                 ]
            A = A[np.argsort( np.where(A[:,0]==0, A.max()+1, abs(A[:,0]) )),
                  :
                 ]
        for i,x in enumerate(A[0]):
            sgn = 1 if x>=0 else -1
            A[:,i] = -sgn*A[:,i]
        for i,row in enumerate(A):
            sgn = 1 if row[0]>=0 else -1
            A[i,:] = sgn*A[i,:]
        #jetzt sind alle relevanten spalten- und zeileneintraege nicht-negativ
        for i in range(1,A.shape[0]):
            if A[i,0] == 0:
                continue
            A[i,:] = A[i,:] - ( A[i,0]//A[0,0] )*A[0,:]
        for i in range(1,A.shape[1]):
            if A[0,i] == 0:
                continue
            A[:,i] = A[:,i] - ( A[0,i]//A[0,0] )*A[:,0]
        # check if only pivot nonzero
        current_row_and_col_cleaned_up = \
            (A[1:,0] == 0).all() and (A[0,1:] == 0).all()
        # check if A[0,0] divides everything A[1:,1:]
        pivot_divides_submatrix = \
        ( ( A[1:,1:] % A[0,0] ) == 0 ).all()
        if current_row_and_col_cleaned_up \
            and not pivot_divides_submatrix:
            current_row_and_col_cleaned_up = False
            nonzero_mod_ix = \
            np.unravel_index(
                np.argmax(np.abs(A[1:,1:]%A[0,0]),
                    axis=None),
                A.shape)
            rel_row, rel_col = nonzero_mod_ix
            rel_row = rel_row + 1
            rel_col = rel_col + 1
            A[0,:] = A[0,:] + A[rel_row,:]
    #rows and cols cleaned up
    A[1:,1:] = gauss(A[1:,1:])
    return A

class dag:
    @staticmethod
    def zero():
        return dag()
    @staticmethod
    def one():
        return dag.delta(0)
    @staticmethod
    def sphere(n:int):
        if n<0:
            print('not defined')
            return dag()
        edge_list = [(1,1)]
        s0 = dag()
        s0.add_edges(edge_list)
        if n==0:
            return s0
        else:
           k = 0
           s = s0
           while k < n:
              k = k + 1
              s=s.suspend()
           return s
    @staticmethod
    def delta(n:int):
        if n<0:
            if n<-1:
               print('not defined')
            return dag()
        d0 = dag()
        d0.add_edges([(0,0)])
        if n==0:
            return d0
        d = d0
        for _ in range(n):
            d = d.cone()
        return d
    @staticmethod
    def disk(n:int):
        if n<1:
            print('not defined')
            return dag()
        return dag.sphere(n-1).cone()
    def __init__(self):
        self.vertices = []
        self.edge_list = []
        self.flags = dict()
    def add_edge(self,i,j):
        N = max(i,j)
        if N+1 > len(self.vertices):
            self.vertices = list(range(N+1)) #vertices = {0,..,N}
        assert i in self.vertices
        assert j in self.vertices
        if i>=j:
            return
        if (i,j) not in self.edge_list:
            self.edge_list = self.edge_list + [ (i,j) ]
        self.flags = dict()
        self.flags[0] = [ (i,) for i in sorted(self.vertices)]
        self.flags[1] = sorted(self.edge_list)
        for k in range(2,8):
            if len( self.flags[k-1] ) == 0:
                break
            self.flags[k] = list()
            for flag in self.flags[k-1]:
                for v in self.vertices:
                    if v > max(flag) \
                   and all([ (f,v) in self.edge_list for f in flag ]) \
                   and tuple(sorted(flag)+[v,]) not in self.flags[k]:
                        self.flags[k] = sorted(self.flags[k]+[tuple(sorted(flag)+[v,])])
    def add_edges(self,ijs):
        for i,j in ijs:
            self.add_edge(i,j)
    def __repr__(self):
        return f"V={tuple(sorted(self.vertices))}\nE={tuple(sorted(self.edge_list, key=lambda x: (x[1],x[0])))}\n"
    def cone(self):
        cone_edge_list = self.edge_list + [ (v,len(self.vertices)) for v in self.vertices ]
        cone_dag = dag()
        cone_dag.add_edges(cone_edge_list)
        return cone_dag
    def suspend(self):
        suspend_edge_list = self.edge_list + [ (v,len(self.vertices)) for v in self.vertices ] + [ (v,len(self.vertices)+1) for v in self.vertices ]
        suspend_dag = dag()
        suspend_dag.add_edges(suspend_edge_list)
        return suspend_dag
    def __add__(self,other):
        return dag_vertex_map.sum(self,other)
    def __mul__(self,other):
        return dag_vertex_map.product(self,other)

import numpy as np

class chain_complex:
    # chcx = (d0,d1,d2,..,dn) st dk_1 circ dk = 0 forall k
    def __init__(self,g:dag):
        self.dimensions = dict()
        self.boundaries = list()
        def d(source_basis,target_basis):
            def bdy(flag,target_basis):
                tmp = []
                for i in range(len(flag)-1,-1,-1):
                    sgn = (-1)**i
                    bdy_part = tuple(flag[:i]+flag[i+1:])
                    ix = target_basis.index(bdy_part)
                    tmp = tmp + [ (sgn,ix) ]
                return tmp
            A = np.zeros((len(source_basis),len(target_basis))).astype("int8")
            for i,s in enumerate(source_basis):
                for sgn, ix in bdy(s,target_basis):
                    A[i,ix] = sgn
            return A
        flags = [ z[1] for z in list({ k:g.flags[k] for k in g.flags if len(g.flags[k])>0 }.items())]
        self.dimensions = [len(f) for f in flags]
        self.bases = flags
        homological_pairings = list(zip(flags[1:],flags[:-1]))
        for source_basis,target_basis in homological_pairings:
            self.boundaries = self.boundaries + [d(source_basis,target_basis)]
        self.boundaries = self.boundaries[::-1]
        all_zero_compositions = True
        for b1,b2 in list(zip(self.boundaries[:-1],self.boundaries[1:])):
            all_zero_compositions = all_zero_compositions and ( 0 == np.abs(b1@b2).max() )
            assert all_zero_compositions
        self.coboundaries = [ d.T for d in self.boundaries[::-1] ]
        for b1,b2 in list(zip(self.coboundaries[:-1],self.coboundaries[1:])):
            all_zero_compositions = all_zero_compositions and ( 0 == np.abs(b1@b2).max() )
            assert all_zero_compositions
    def cleanup_boundaries(self):
        self.normal_bases = self.bases
        # homologically: come from highest dim, go down, and do:
        #     source-basis -> source-basis' s.t. upper triangular boundary
        #     target-basis -> target-basis' s.t. only diagonal entries non-zero
        # repeat
        #self.normal_boundaries = coupled_gauss(self.boundaries)
        # cohomologically: come from lowest dim, go up, and do:
        #     source-basis -> source-basis' s.t. upper triangular boundary
        #     target-basis -> target-basis' s.t. only diagonal entries non-zero
        # repeat
        # since, however gaussian process is dualisable, we can just transpose
        # the homological resolution
        #self.normal_coboundaries = [ d.T for d in self.normal_boundaries[::-1] ]

class dag_vertex_map:
    @staticmethod
    def sum(summand1:dag,summand2:dag):
        @dataclass
        class Sum:
            i1: dag_vertex_map
            i2: dag_vertex_map
            swap: dag_vertex_map
            swap_back: dag_vertex_map
        tmp = dag()
        tmp.vertices = summand1.vertices
        tmp.edge_list = summand1.edge_list
        V = len(tmp.vertices)
        new_edges = [ (V+i,V+i) for i in summand2.vertices ]
        new_edges = new_edges + [ (V+i,V+j) for i,j in summand2.edge_list ]
        tmp.add_edges(new_edges)
        sum_ = tmp

        tmp = dag()
        tmp.vertices = summand2.vertices
        tmp.edge_list = summand2.edge_list
        V = len(tmp.vertices)
        new_edges = [ (V+i,V+i) for i in summand1.vertices ]
        new_edges = new_edges + [ (V+i,V+j) for i,j in summand1.edge_list ]
        tmp.add_edges(new_edges)
        tw_sum = tmp

        # construct both canonical inclusions
        # and the twist, which implicitly include the summands and sums
        i1 = dag_vertex_map(summand1,sum_)
        for v in summand1.vertices:
            i1.add_map_edge(v,v)
        assert i1.is_graph_hom

        i2 = dag_vertex_map(summand2,sum_)
        for v in summand2.vertices:
            i2.add_map_edge(v,len(summand1.vertices)+v)
        assert i2.is_graph_hom

        swap = dag_vertex_map(sum_,tw_sum)
        for v in summand1.vertices:
            swap.add_map_edge(v,len(summand2.vertices)+v)
        for v in summand2.vertices:
            swap.add_map_edge(v+len(summand1.vertices),v)
        assert swap.is_graph_hom

        swap_back = dag_vertex_map(tw_sum,sum_)
        for v in summand2.vertices:
            swap_back.add_map_edge(v,len(summand1.vertices)+v)
        for v in summand1.vertices:
            swap_back.add_map_edge(v+len(summand2.vertices),v)
        assert swap_back.is_graph_hom

        return i1.target
        return Sum(i1,i2,swap,swap_back)
    @staticmethod
    def product(factor1:dag,factor2:dag):
        def omega(n:int,m:int):
            return lambda i,j: i*m + j
        def omega_inverse(n:int,m:int):
            return lambda   k: ( k//m, k%m )
        def omega_bar(n:int,m:int):
            return lambda i,j: i + j*m
        def omega_bar_inverse(n:int,m:int):
            return lambda   k: ( k%m, k//m )
        N,M = 7,5
        assert list(range(N*M)) == [ omega(N,M)( *omega_inverse(N,M)(k) ) for k in range(N*M) ]
        assert list(range(N*M)) == [ omega_bar(N,M)( *omega_bar_inverse(N,M)(k) ) for k in range(N*M) ]
        assert list(range(N*M)) == [ omega_bar(N,M)( *omega_bar_inverse(N,M)(
            omega_bar(N,M)(*omega_bar_inverse(N,M)(k)) ) ) for k in range(N*M) ]
        assert list(range(N*M)) == [ omega(N,M)( *omega_inverse(N,M)(
            omega(N,M)(*omega_inverse(N,M)(k)) ) ) for k in range(N*M) ]
        # these assertions should be enough to prove both are bijections
        #, if they weren't, we'd not just sort entries wrong, we'd lose them possibly
        @dataclass
        class Product:
            p1: dag_vertex_map
            p2: dag_vertex_map
            swap: dag_vertex_map
            swap_back: dag_vertex_map

        def _prod(fac1,fac2):
            N,M = len(fac1.vertices),len(fac2.vertices)

            tmp = dag()
            tmp.add_edge( N*M-1, N*M-1 )

            for v in fac1.vertices:
                for w in fac2.vertices:
                    tmp.add_edge( omega(N,M)(v,w),omega(N,M)(v,w) )
            for v in fac1.vertices:
                for i,j in fac2.edge_list:
                    tmp.add_edge( omega(N,M)(v,i),omega(N,M)(v,j) )
            for i,j in fac1.edge_list:
                for v in fac2.vertices:
                    tmp.add_edge( omega(N,M)(i,v),omega(N,M)(j,v) )
            for i1,j1 in fac1.edge_list:
                for i2,j2 in fac2.edge_list:
                    tmp.add_edge(omega(N,M)(i1,i2),omega(N,M)(j1,j2))
            return tmp

        product = _prod(factor1,factor2)
        tw_product = _prod(factor2,factor1)

        return product
        print(product)
        #print(tw_product)

        # # construct both canonical projections
        # # and the twist, which implicitly include the summands and sums
        # i1 = dag_vertex_map(summand1,sum_)

        # assert i1.is_graph_hom

        # i2 = dag_vertex_map(summand2,sum_)

        # assert i2.is_graph_hom

        # swap = dag_vertex_map(sum_,tw_sum)

        # assert swap.is_graph_hom

        # swap_back = dag_vertex_map(tw_sum,sum_)

        # assert swap_back.is_graph_hom

        # return Product(p1,p2,swap,swap_back)
    @staticmethod
    def initial_map(target:dag):
        tmp = dag_vertex_map(dag(),target)
        assert tmp.is_graph_hom
        return tmp
    @staticmethod
    def terminal_map(source:dag):
        tmp = dag_vertex_map(source,dag.delta(0))
        edge_list = [ (v,0) for v in source.vertices ]
        tmp.add_map_edges(edge_list)
        assert tmp.is_graph_hom
        return tmp
    def __init__(self,source:dag,target:dag):
        self.source = source
        self.target = target
        self.map_edge_list = []
    def add_map_edge(self,i,j):
        if (i,j) in self.map_edge_list:
            return
        if ( ( i in self.source.vertices ) and ( j in self.target.vertices ) ):
            self.map_edge_list = self.map_edge_list + [(i,j)]
            self.map_edge_list = sorted(self.map_edge_list,key=lambda x: (x[0],x[1]))
    def add_map_edges(self,ijs):
        for i,j in ijs:
            self.add_map_edge(i,j)
    @property
    def is_vertex_map(self):
        def count_edges_with_source(i):
            return sum([ 1 for k in self.map_edge_list if k[0]==i ])
        unique_t_per_s = all([ 1==count_edges_with_source(i) for i in self.source.vertices ])
        return unique_t_per_s
    @property
    def is_graph_hom(self):
        if not self.is_vertex_map:
            return False
        # now we have for each source vertex a target vertex, so
        # we just need to check the edge relations
        map_dict = dict(self.map_edge_list)
        hom = lambda x: map_dict[x]
        source_edges = self.source.edge_list
        # only need to check edges that remain edges, collapsing onto a node is always hom
        transformed_edges = [ (hom(i),hom(j))  for i,j in source_edges if hom(i)!=hom(j) ]
        target_edges = self.target.edge_list
        # all transformed i!=j edges exist in target => graph hom!
        is_hom = all([ (i,j) in target_edges for i,j in transformed_edges ])
        return is_hom
    @property
    def is_isomorphism(self):
        def count_fibre_size(j):
            return sum([ 1 for k in self.map_edge_list if k[1]==j ])
        if len(self.source.vertices) != len(self.target.vertices):
            return False
        if not self.is_graph_hom:
            return False
        unique_s_per_t = all([1==count_fibre_size(j) for j in self.target.vertices])
        if not unique_s_per_t:
            return False
        # now bijection is guaranteed, just not that the inverse thing is a hom
        inverse_candidate = dag_vertex_map(self.target,self.source)
        for i,j in self.map_edge_list:
            inverse_candidate.add_map_edge(j,i)
        if inverse_candidate.is_graph_hom:
            return True
        return False
    @property
    def invert(self):
        if not self.is_isomorphism:
            print('not defined')
            return dag_vertex_map()
        inverse_candidate = dag_vertex_map(self.target,self.source)
        for i,j in self.map_edge_list:
            inverse_candidate.add_map_edge(j,i)
        assert inverse_candidate.is_graph_hom
        return inverse_candidate
    @property
    def hom(self):
        try:
            assert self.is_graph_hom
            map_dict = dict(self.map_edge_list)
            self.homo = lambda x: map_dict[x]
        except:
            print("not the underlying graph of a graph hom")
    def __repr__(self):
        source_str = f"{self.source.vertices} {self.source.edge_list}"
        target_str = f"{self.target.vertices} {self.target.edge_list}"
        hom_str = f"{self.map_edge_list}"
        return f"   source: {source_str}\n   target: {target_str}\nhom_edges: {hom_str}"
    # def equaliser(self,other)
    # def coequaliser(self,other)
    # def suspend(self)
    # def cone(self)
    # def sqcup(self,other)
    # def times(self,other)


s0 = dag(); s0.add_edge(1,1) # == add nodes up to 1, but not an edge

s1 = s0.suspend()

i01 = dag_vertex_map(s0,s1)
i01.add_map_edges([(0,1),(1,2)])

I = dag.delta(1)

M = dag()
M.add_edge(7,7)
edges = \
[(0,2),
 (0,4),
 (0,7),
 (1,3),

 (1,5),
 (1,6),
 (2,4),
 (2,5),

 (2,6),
 (3,4),
 (3,5),
 (3,7),
 
 (4,6),
 (5,6),
 (5,7),
]

M.add_edges(edges)