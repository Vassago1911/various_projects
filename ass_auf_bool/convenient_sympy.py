import sympy

for ch in ["a","b","c","d","x","y","z"]:
    for i in range(10):
        for j in range(10):
            exec(f"{ch}{i}{j}=sympy.symbols('{ch}{i}{j}')")

for ch in ["A","B","C","D","X","Y","Z"]:
    for z in range(2,10):
        for s in range(2,10):
            lchar = ch.lower()
            rows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}" for j in range(s) ])  +"]"   for i in range(z) ])
            drows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}"  if i==j else "0" for j in range(s) ])  +"]"   for i in range(z) ])
            trows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}"  if i<=j else "0" for j in range(s) ])  +"]"   for i in range(z) ])
            strows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}"  if i<j else "0"  for j in range(s)])  +"]"   for i in range(z) ])
            lrows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}"  if i>=j else "0" for j in range(s) ])  +"]"   for i in range(z) ])
            slrows = ",".join( [ "["+ ",".join([ f"{lchar}{i}{j}"  if i>j else "0"  for j in range(s)])  +"]"   for i in range(z) ])
            for mat_sym,rows in zip(["","T","ST","L","SL","D"],[rows,trows,strows,lrows,slrows,drows]):
                matstr = f"{mat_sym}{ch}{z}{s}="+"sympy.Matrix(["+rows+"])"
                exec(matstr)