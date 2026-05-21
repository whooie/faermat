import Faermat.Decomp

namespace Faermat

/- Matrix set/get round-tripping ----------------------------------------------/

axiom Matrix.get_set_eq [Matrix.Ops a]
    (m : Matrix a) (i j : Nat)
    (hi : i < m.nrows) (hj : j < m.ncols)
    (v : a) :
    (m.set i j v).get? i j = some v

axiom Matrix.get_set_ne [Matrix.Ops a]
    (m : Matrix a) (i j i' j' : Nat)
    (v : a)
    (hne : (i, j) != (i', j')) :
    (m.set i j v).get? i' j' = m.get? i' j'

/- Vector set/get round-tripping ----------------------------------------------/

axiom Vector.get_set_eq [Vector.Ops a]
    (v : Vector a) (i : Nat)
    (hi : i < v.len) (val : a) :
    (v.set i val).get? i = some val

axiom Vector.get_set_ne [Vector.Ops a]
    (v : Vector a) (i i' : Nat) (val : a)
    (hne : i != i') :
    (v.set i val).get? i' = v.get? i'

/- Matrix construction sizes --------------------------------------------------/

axiom Matrix.nrows_zeros [Matrix.Ops a] (nr nc : Nat) :
    (Matrix.zeros (a := a) nr nc).nrows = nr

axiom Matrix.ncols_zeros [Matrix.Ops a] (nr nc : Nat) :
    (Matrix.zeros (a := a) nr nc).ncols = nc

axiom Matrix.nrows_identity [Matrix.Ops a] (n : Nat) :
    (Matrix.identity (a := a) n).nrows = n

axiom Matrix.ncols_identity [Matrix.Ops a] (n : Nat) :
    (Matrix.identity (a := a) n).ncols = n

axiom Matrix.nrows_full [Matrix.Ops a] (nr nc : Nat) (v : a) :
    (Matrix.full nr nc v).nrows = nr

axiom Matrix.ncols_full [Matrix.Ops a] (nr nc : Nat) (v : a) :
    (Matrix.full nr nc v).ncols = nc

axiom Matrix.nrows_fromDiag [Matrix.Ops a] (data : Array a) :
    (Matrix.fromDiag data).nrows = data.size

axiom Matrix.ncols_fromDiag [Matrix.Ops a] (data : Array a) :
    (Matrix.fromDiag data).ncols = data.size

axiom Matrix.nrows_fromFn [Matrix.Ops a]
    (nr nc : Nat) (f : Nat -> Nat -> a) :
    (Matrix.fromFn nr nc f).nrows = nr

axiom Matrix.ncols_fromFn [Matrix.Ops a]
    (nr nc : Nat) (f : Nat -> Nat -> a) :
    (Matrix.fromFn nr nc f).ncols = nc

axiom Matrix.nrows_ofArray [Matrix.Ops a]
    (nr nc : Nat) (data : Array a) (m : Matrix a)
    (h : Matrix.ofArray nr nc data = some m) :
    m.nrows = nr

axiom Matrix.ncols_ofArray [Matrix.Ops a]
    (nr nc : Nat) (data : Array a) (m : Matrix a)
    (h : Matrix.ofArray nr nc data = some m) :
    m.ncols = nc

axiom Matrix.nrows_ofRowArray [Matrix.Ops a]
    (nr nc : Nat) (data : Array a) (m : Matrix a)
    (h : Matrix.ofRowArray nr nc data = some m) :
    m.nrows = nr

axiom Matrix.ncols_ofRowArray [Matrix.Ops a]
    (nr nc : Nat) (data : Array a) (m : Matrix a)
    (h : Matrix.ofRowArray nr nc data = some m) :
    m.ncols = nc

/- Vector construction sizes --------------------------------------------------/

axiom Vector.len_zeros [Vector.Ops a] (n : Nat) :
    (Vector.zeros (a := a) n).len = n

axiom Vector.len_full [Vector.Ops a] (n : Nat) (v : a) :
    (Vector.full n v).len = n

axiom Vector.len_fromFn [Vector.Ops a]
    (n : Nat) (f : Nat -> a) :
    (Vector.fromFn n f).len = n

axiom Vector.len_ofArray [Vector.Ops a]
    (data : Array a) (v : Vector a)
    (h : Vector.ofArray data = some v) :
    v.len = data.size

/- Matrix unary operation sizes -----------------------------------------------/

axiom Matrix.nrows_transpose [Matrix.Ops a] (m : Matrix a) :
    m.transpose.nrows = m.ncols

axiom Matrix.ncols_transpose [Matrix.Ops a] (m : Matrix a) :
    m.transpose.ncols = m.nrows

axiom Matrix.nrows_adjoint [Matrix.Ops a] (m : Matrix a) :
    m.adjoint.nrows = m.ncols

axiom Matrix.ncols_adjoint [Matrix.Ops a] (m : Matrix a) :
    m.adjoint.ncols = m.nrows

axiom Matrix.nrows_materialize [Matrix.Ops a] (m : Matrix a) :
    m.materialize.nrows = m.nrows

axiom Matrix.ncols_materialize [Matrix.Ops a] (m : Matrix a) :
    m.materialize.ncols = m.ncols

axiom Matrix.nrows_neg [Matrix.Ops a] (m : Matrix a) :
    (-m).nrows = m.nrows

axiom Matrix.ncols_neg [Matrix.Ops a] (m : Matrix a) :
    (-m).ncols = m.ncols

axiom Matrix.nrows_set [Matrix.Ops a]
    (m : Matrix a) (i j : Nat) (v : a) :
    (m.set i j v).nrows = m.nrows

axiom Matrix.ncols_set [Matrix.Ops a]
    (m : Matrix a) (i j : Nat) (v : a) :
    (m.set i j v).ncols = m.ncols

/- Vector unary operation sizes -----------------------------------------------/

axiom Vector.len_neg [Vector.Ops a] (v : Vector a) :
    (-v).len = v.len

axiom Vector.len_set [Vector.Ops a]
    (v : Vector a) (i : Nat) (val : a) :
    (v.set i val).len = v.len

/- Matrix binary operation sizes ----------------------------------------------/

axiom Matrix.nrows_add [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.nrows = b.nrows) :
    (a' + b).nrows = a'.nrows

axiom Matrix.ncols_add [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.ncols = b.ncols) :
    (a' + b).ncols = a'.ncols

axiom Matrix.nrows_sub [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.nrows = b.nrows) :
    (a' - b).nrows = a'.nrows

axiom Matrix.ncols_sub [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.ncols = b.ncols) :
    (a' - b).ncols = a'.ncols

axiom Matrix.nrows_mul [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.ncols = b.nrows) :
    (a' * b).nrows = a'.nrows

axiom Matrix.ncols_mul [Matrix.Ops a] (a' b : Matrix a)
    (h : a'.ncols = b.nrows) :
    (a' * b).ncols = b.ncols

axiom Matrix.nrows_scale [Matrix.Ops a] (s : a) (m : Matrix a) :
    (s * m).nrows = m.nrows

axiom Matrix.ncols_scale [Matrix.Ops a] (s : a) (m : Matrix a) :
    (s * m).ncols = m.ncols

/- Vector binary operation sizes ----------------------------------------------/

axiom Vector.len_add [Vector.Ops a] (va vb : Vector a)
    (h : va.len = vb.len) :
    (va + vb).len = va.len

axiom Vector.len_sub [Vector.Ops a] (va vb : Vector a)
    (h : va.len = vb.len) :
    (va - vb).len = va.len

axiom Vector.len_scale [Vector.Ops a] (s : a) (v : Vector a) :
    (s * v).len = v.len

/- Matrix-vector product size -------------------------------------------------/

axiom Vector.len_matVecMul [Vector.Ops a] [Matrix.Ops a]
    (m : Matrix a) (v : Vector a) :
    (m * v).len = m.nrows

/- Matrix view sizes ----------------------------------------------------------/

axiom Matrix.nrows_submatrix [Matrix.Ops a]
    (m : Matrix a) (rs cs nr nc : Nat) (sub : Matrix a)
    (h : m.submatrix rs cs nr nc = some sub) :
    sub.nrows = nr

axiom Matrix.ncols_submatrix [Matrix.Ops a]
    (m : Matrix a) (rs cs nr nc : Nat) (sub : Matrix a)
    (h : m.submatrix rs cs nr nc = some sub) :
    sub.ncols = nc

axiom Matrix.nrows_row [Matrix.Ops a]
    (m : Matrix a) (i : Nat) (r : Matrix a)
    (h : m.row i = some r) :
    r.nrows = 1

axiom Matrix.ncols_row [Matrix.Ops a]
    (m : Matrix a) (i : Nat) (r : Matrix a)
    (h : m.row i = some r) :
    r.ncols = m.ncols

axiom Matrix.nrows_col [Matrix.Ops a]
    (m : Matrix a) (j : Nat) (c : Matrix a)
    (h : m.col j = some c) :
    c.nrows = m.nrows

axiom Matrix.ncols_col [Matrix.Ops a]
    (m : Matrix a) (j : Nat) (c : Matrix a)
    (h : m.col j = some c) :
    c.ncols = 1

/- Kronecker product sizes ----------------------------------------------------/

axiom Matrix.nrows_kron [Matrix.Ops a] (a' b : Matrix a) :
    (a'.kron b).nrows = a'.nrows * b.nrows

axiom Matrix.ncols_kron [Matrix.Ops a] (a' b : Matrix a) :
    (a'.kron b).ncols = a'.ncols * b.ncols

/- Reshape sizes --------------------------------------------------------------/

axiom Matrix.nrows_reshape [Matrix.Ops a]
    (m : Matrix a) (nr nc : Nat) (r : Matrix a)
    (h : m.reshape nr nc = some r) :
    r.nrows = nr

axiom Matrix.ncols_reshape [Matrix.Ops a]
    (m : Matrix a) (nr nc : Nat) (r : Matrix a)
    (h : m.reshape nr nc = some r) :
    r.ncols = nc

/- IsSquare preservation ------------------------------------------------------/

axiom Matrix.IsSquare_identity [Matrix.Ops a] (n : Nat) :
    Matrix.IsSquare (Matrix.identity (a := a) n)

axiom Matrix.IsSquare_fromDiag [Matrix.Ops a] (data : Array a) :
    Matrix.IsSquare (Matrix.fromDiag data)

axiom Matrix.IsSquare_transpose [Matrix.Ops a] (m : Matrix a)
    (h : Matrix.IsSquare m) :
    Matrix.IsSquare m.transpose

axiom Matrix.IsSquare_adjoint [Matrix.Ops a] (m : Matrix a)
    (h : Matrix.IsSquare m) :
    Matrix.IsSquare m.adjoint

axiom Matrix.IsSquare_kron [Matrix.Ops a] (a' b : Matrix a)
    (ha : Matrix.IsSquare a') (hb : Matrix.IsSquare b) :
    Matrix.IsSquare (a'.kron b)

axiom Matrix.IsSquare_set [Matrix.Ops a]
    (m : Matrix a) (i j : Nat) (v : a)
    (h : Matrix.IsSquare m) :
    Matrix.IsSquare (m.set i j v)

axiom Matrix.IsSquare_neg [Matrix.Ops a] (m : Matrix a)
    (h : Matrix.IsSquare m) :
    Matrix.IsSquare (-m)

axiom Matrix.IsSquare_add [Matrix.Ops a] (a' b : Matrix a)
    (ha : Matrix.IsSquare a')
    (hr : a'.nrows = b.nrows) (hc : a'.ncols = b.ncols) :
    Matrix.IsSquare (a' + b)

axiom Matrix.IsSquare_sub [Matrix.Ops a] (a' b : Matrix a)
    (ha : Matrix.IsSquare a')
    (hr : a'.nrows = b.nrows) (hc : a'.ncols = b.ncols) :
    Matrix.IsSquare (a' - b)

axiom Matrix.IsSquare_mul [Matrix.Ops a] (a' b : Matrix a)
    (ha : Matrix.IsSquare a')
    (h : a'.ncols = b.nrows) (hb : Matrix.IsSquare b) :
    Matrix.IsSquare (a' * b)

axiom Matrix.IsSquare_expm [Matrix.HasExpm a] [Matrix.Ops a]
    (m : Matrix a) (r : Matrix a)
    (h : m.expm = some r) :
    Matrix.IsSquare r

axiom Matrix.IsSquare_sqrtm [Matrix.HasSqrtm a c] [Matrix.Ops c]
    (m : Matrix a) (r : Matrix c)
    (h : m.sqrtm = some r) :
    Matrix.IsSquare r

axiom Matrix.IsSquare_logm [Matrix.HasLogm a c] [Matrix.Ops c]
    (m : Matrix a) (r : Matrix c)
    (h : m.logm = some r) :
    Matrix.IsSquare r

/- powm sizes -----------------------------------------------------------------/

axiom Matrix.nrows_powm [Matrix.Ops a]
    (m : Matrix a) (n : Nat)
    (h : Matrix.IsSquare m) :
    (m ^ n).nrows = m.nrows

axiom Matrix.ncols_powm [Matrix.Ops a]
    (m : Matrix a) (n : Nat)
    (h : Matrix.IsSquare m) :
    (m ^ n).ncols = m.ncols

/- Decomposition factor sizes -------------------------------------------------/

-- LU

axiom LU.nrows_L [LU.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (LU.new m).L.nrows = m.nrows

axiom LU.ncols_L [LU.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (LU.new m).L.ncols = Nat.min m.nrows m.ncols

axiom LU.nrows_U [LU.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (LU.new m).U.nrows = Nat.min m.nrows m.ncols

axiom LU.ncols_U [LU.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (LU.new m).U.ncols = m.ncols

-- QR

axiom QR.nrows_Q [QR.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (QR.new m).Q.nrows = m.nrows

axiom QR.ncols_Q [QR.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (QR.new m).Q.ncols = Nat.min m.nrows m.ncols

axiom QR.nrows_R [QR.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (QR.new m).R.nrows = Nat.min m.nrows m.ncols

axiom QR.ncols_R [QR.Ops a] [Matrix.Ops a]
    (m : Matrix a) :
    (QR.new m).R.ncols = m.ncols

-- Cholesky

axiom Cholesky.nrows_L [Cholesky.Ops a] [Matrix.Ops a]
    (m : Matrix a) (chol : Cholesky a)
    (h : Cholesky.new m = some chol) :
    chol.L.nrows = m.nrows

axiom Cholesky.ncols_L [Cholesky.Ops a] [Matrix.Ops a]
    (m : Matrix a) (chol : Cholesky a)
    (h : Cholesky.new m = some chol) :
    chol.L.ncols = m.ncols

-- SVD

axiom SVD.nrows_U [SVD.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (svd : SVD a)
    (h : SVD.new m = some svd) :
    svd.U.nrows = m.nrows

axiom SVD.ncols_U [SVD.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (svd : SVD a)
    (h : SVD.new m = some svd) :
    svd.U.ncols = Nat.min m.nrows m.ncols

axiom SVD.nrows_V [SVD.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (svd : SVD a)
    (h : SVD.new m = some svd) :
    svd.V.nrows = m.ncols

axiom SVD.ncols_V [SVD.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (svd : SVD a)
    (h : SVD.new m = some svd) :
    svd.V.ncols = Nat.min m.nrows m.ncols

axiom SVD.size_singularValues [SVD.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (svd : SVD a)
    (h : SVD.new m = some svd) :
    svd.singularValues.size = Nat.min m.nrows m.ncols

-- SelfAdjointEigen

axiom SelfAdjointEigen.nrows_eigenvectors
    [SelfAdjointEigen.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (evd : SelfAdjointEigen a)
    (h : SelfAdjointEigen.new m = some evd) :
    evd.eigenvectors.nrows = m.nrows

axiom SelfAdjointEigen.ncols_eigenvectors
    [SelfAdjointEigen.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (evd : SelfAdjointEigen a)
    (h : SelfAdjointEigen.new m = some evd) :
    evd.eigenvectors.ncols = m.ncols

axiom SelfAdjointEigen.size_eigenvalues
    [SelfAdjointEigen.Ops a r] [Matrix.Ops a]
    (m : Matrix a) (evd : SelfAdjointEigen a)
    (h : SelfAdjointEigen.new m = some evd) :
    evd.eigenvalues.size = m.nrows

-- Eigen

axiom Eigen.nrows_eigenvectors
    [Eigen.Ops a c] [Matrix.Ops a] [Matrix.Ops c]
    (m : Matrix a) (evd : Eigen a)
    (h : Eigen.new m = some evd) :
    evd.eigenvectors.nrows = m.nrows

axiom Eigen.ncols_eigenvectors
    [Eigen.Ops a c] [Matrix.Ops a] [Matrix.Ops c]
    (m : Matrix a) (evd : Eigen a)
    (h : Eigen.new m = some evd) :
    evd.eigenvectors.ncols = m.nrows

axiom Eigen.size_eigenvalues
    [Eigen.Ops a c] [Matrix.Ops a]
    (m : Matrix a) (evd : Eigen a)
    (h : Eigen.new m = some evd) :
    evd.eigenvalues.size = m.nrows

end Faermat
