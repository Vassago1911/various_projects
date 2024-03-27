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

def based_gauss(A,S=[],T=[]):
    if ( ( A.shape[0] == 0 ) or (A.shape[1] == 0) ):
        return A,S,T
    if len(S)==0 or len(T)==0:
        S,T = np.eye(A.shape[0]),np.eye(A.shape[1])
    assert (S@A == A).all() and (A@T == A).all()
    current_row_and_col_cleaned_up = False
    while not current_row_and_col_cleaned_up:
        if np.abs(A).max() > 1:
            min_a_ix = np.unravel_index(np.argmin(np.abs(np.where(A==0,A.max(),A)), axis=None), A.shape)
        else:
            min_a_ix = np.unravel_index(np.argmin(np.where(np.abs(A)==0,2,np.abs(A)), axis=None), A.shape)
        last_min = A[*min_a_ix]
        #print(last_min)
        if A[*min_a_ix] == 0:
            # pure zero matrix, nothing left to do
            return A,S,T
        #A sortieren nach erst zeile, dann spalte, aber vor allem nach abs(k), ausser 0
        for _ in range(2):
            sort_cols = np.argsort( np.where(A[0]==0, A.max()+1, abs(A[0]) ))
            sort_cols_inv = [ list(sort_cols).index(i) for i in range(len(sort_cols)) ]
            A = A[:,sort_cols]
            sort_rows = np.argsort( np.where(A[:,0]==0, A.max()+1, abs(A[:,0]) ))
            sort_rows_inv = [ list(sort_rows).index(i) for i in range(len(sort_rows)) ]
            A = A[sort_rows,:]
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
    A[1:,1:],S[1:,1:],T[1:,1:] = based_gauss(A[1:,1:],S[1:,1:],T[1:,1:])
    return A,S,T

def eij(i,j,scale,n):
    tmp = np.eye(n)
    tmp[i,j] = scale
    return tmp

def inv_eij(i,j,scale,n):
    tmp = np.eye(n)
    tmp[i,j] = -scale
    return tmp

def sdt_split(A):
    P,Q = np.eye(A.shape[0],dtype=int),np.eye(A.shape[1],dtype=int)
    offset = 0
    #A sortieren nach erst zeile, dann spalte, aber vor allem nach abs(k), ausser 0
    for _ in range(2):
        min_i,min_j = np.unravel_index(np.argmin(np.where(np.abs(A)==0,np.abs(A).max(),np.abs(A))),A.shape)
        sort_rows = np.argsort( np.where(A[:,min_j]==0, A.max()+1, abs(A[:,min_j]) ))
        sort_rows_inv = [ list(sort_rows).index(i) for i in range(len(sort_rows)) ]
        A = A[sort_rows,:]
        p = np.zeros((A.shape[0],A.shape[0]),int)
        for i,row in enumerate(sort_rows):
            p[i,row]=1
        P = P@p
        min_i,min_j = np.unravel_index(np.argmin(np.where(np.abs(A)==0,np.abs(A).max(),np.abs(A))),A.shape)
        sort_cols = np.argsort( np.where(A[min_i]==0, A.max()+1, abs(A[min_i]) ))
        sort_cols_inv = [ list(sort_cols).index(i) for i in range(len(sort_cols)) ]
        A = A[:,sort_cols] #
        p = np.zeros((A.shape[1],A.shape[1]),int)
        for i,col in enumerate(sort_cols_inv):
            p[i,col]=1
        Q = p@Q

    S,T = np.eye(A.shape[0],dtype=int),np.eye(A.shape[1],dtype=int)
    S_,T_ = np.eye(A.shape[0],dtype=int),np.eye(A.shape[1],dtype=int)

    pivot_row = A[0]
    pivot = pivot_row[0]
    for i in range(1,A.shape[0]):
        S = S@eij(i,0,-((A[i][0])//pivot),A.shape[0])
        S_ = S_@eij(i,0,((A[i][0])//pivot),A.shape[0])
        A[i] = A[i] - ((A[i][0])//pivot)*pivot_row

    pivot_col = A[:,0]
    pivot = pivot_col[0]
    for i in range(1,A.shape[1]):
        T = T@eij(0,i,-((A[0][i])//pivot),A.shape[1])
        T_ = T_@eij(0,i,((A[0][i])//pivot),A.shape[1])
        A[:,i] = A[:,i] - ((A[0][i])//pivot)*pivot_col

    return S_,S,P,A,Q,T,T_

A = 3*np.random.randint(1,9,size=(4,6)) - 6*np.random.randint(1,9,size=(4,6))
s0_\
,s0\
,p0\
,a0\
,q0\
,t0\
,t0_ = sdt_split(A)
s1_\
,s1\
,p1\
,a1\
,q1\
,t1\
,t1_ = sdt_split(a0[1:,1:])