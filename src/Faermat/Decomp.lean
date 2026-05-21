import Faermat.Matrix
import Faermat.Vector
import Numplex

namespace Faermat

/- LU decomposition (partial pivoting) ----------------------------------------/

opaque LU.Nonempty : NonemptyType
def LU (_a : Type) : Type := LU.Nonempty.type
instance : Nonempty (LU a) := LU.Nonempty.property

namespace LU

-- FFI: new
@[extern "faermat_mat_lu_f64"]
private opaque luF64 : @& Matrix Float -> LU Float
@[extern "faermat_mat_lu_f32"]
private opaque luF32 : @& Matrix Float32 -> LU Float32
@[extern "faermat_mat_lu_c64"]
private opaque luC64 : @& Matrix Numplex.C64 -> LU Numplex.C64
@[extern "faermat_mat_lu_c32"]
private opaque luC32 : @& Matrix Numplex.C32 -> LU Numplex.C32

-- FFI: solve (matrix)
@[extern "faermat_lu_solve_f64"]
private opaque solveMatF64 : @& LU Float -> @& Matrix Float -> Matrix Float
@[extern "faermat_lu_solve_f32"]
private opaque solveMatF32 :
    @& LU Float32 -> @& Matrix Float32 -> Matrix Float32
@[extern "faermat_lu_solve_c64"]
private opaque solveMatC64 :
    @& LU Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_lu_solve_c32"]
private opaque solveMatC32 :
    @& LU Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

-- FFI: solve (vector)
@[extern "faermat_lu_solve_vec_f64"]
private opaque solveVecF64 : @& LU Float -> @& Vector Float -> Vector Float
@[extern "faermat_lu_solve_vec_f32"]
private opaque solveVecF32 :
    @& LU Float32 -> @& Vector Float32 -> Vector Float32
@[extern "faermat_lu_solve_vec_c64"]
private opaque solveVecC64 :
    @& LU Numplex.C64 -> @& Vector Numplex.C64 -> Vector Numplex.C64
@[extern "faermat_lu_solve_vec_c32"]
private opaque solveVecC32 :
    @& LU Numplex.C32 -> @& Vector Numplex.C32 -> Vector Numplex.C32

-- FFI: inverse
@[extern "faermat_lu_inverse_f64"]
private opaque inverseF64 : @& LU Float -> Matrix Float
@[extern "faermat_lu_inverse_f32"]
private opaque inverseF32 : @& LU Float32 -> Matrix Float32
@[extern "faermat_lu_inverse_c64"]
private opaque inverseC64 : @& LU Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_lu_inverse_c32"]
private opaque inverseC32 : @& LU Numplex.C32 -> Matrix Numplex.C32

-- FFI: L factor
@[extern "faermat_lu_L_f64"]
private opaque lFactorF64 : @& LU Float -> Matrix Float
@[extern "faermat_lu_L_f32"]
private opaque lFactorF32 : @& LU Float32 -> Matrix Float32
@[extern "faermat_lu_L_c64"]
private opaque lFactorC64 : @& LU Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_lu_L_c32"]
private opaque lFactorC32 : @& LU Numplex.C32 -> Matrix Numplex.C32

-- FFI: U factor
@[extern "faermat_lu_U_f64"]
private opaque uFactorF64 : @& LU Float -> Matrix Float
@[extern "faermat_lu_U_f32"]
private opaque uFactorF32 : @& LU Float32 -> Matrix Float32
@[extern "faermat_lu_U_c64"]
private opaque uFactorC64 : @& LU Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_lu_U_c32"]
private opaque uFactorC32 : @& LU Numplex.C32 -> Matrix Numplex.C32

-- Ops typeclass
class Ops (a : Type) where
  new : Matrix a -> LU a
  solve : LU a -> Matrix a -> Matrix a
  solveVec : LU a -> Vector a -> Vector a
  inverse : LU a -> Matrix a
  lFactor : LU a -> Matrix a
  uFactor : LU a -> Matrix a

instance : Ops Float where
  new := luF64
  solve := solveMatF64
  solveVec := solveVecF64
  inverse := inverseF64
  lFactor := lFactorF64
  uFactor := uFactorF64

instance : Ops Float32 where
  new := luF32
  solve := solveMatF32
  solveVec := solveVecF32
  inverse := inverseF32
  lFactor := lFactorF32
  uFactor := uFactorF32

instance : Ops Numplex.C64 where
  new := luC64
  solve := solveMatC64
  solveVec := solveVecC64
  inverse := inverseC64
  lFactor := lFactorC64
  uFactor := uFactorC64

instance : Ops Numplex.C32 where
  new := luC32
  solve := solveMatC32
  solveVec := solveVecC32
  inverse := inverseC32
  lFactor := lFactorC32
  uFactor := uFactorC32

/--
Compute the LU decomposition with partial pivoting.
-/
def new [Ops a] (m : Matrix a) : LU a :=
  Ops.new m

/--
Solve `A x = b` where `A` was decomposed.
-/
def solve [Ops a] (lu : LU a) (b : Matrix a) : Matrix a :=
  Ops.solve lu b

/--
Solve `A x = b` where `b` is a vector.
-/
def solveVec [Ops a] (lu : LU a) (b : Vector a) : Vector a :=
  Ops.solveVec lu b

/--
Compute the inverse of the decomposed matrix.
-/
def inverse [Ops a] (lu : LU a) : Matrix a :=
  Ops.inverse lu

/--
Extract the L factor.
-/
def L [Ops a] (lu : LU a) : Matrix a :=
  Ops.lFactor lu

/--
Extract the U factor.
-/
def U [Ops a] (lu : LU a) : Matrix a :=
  Ops.uFactor lu

end LU

/- QR decomposition -----------------------------------------------------------/

opaque QR.Nonempty : NonemptyType
def QR (_a : Type) : Type := QR.Nonempty.type
instance : Nonempty (QR a) := QR.Nonempty.property

namespace QR

-- FFI: new
@[extern "faermat_mat_qr_f64"]
private opaque qrF64 : @& Matrix Float -> QR Float
@[extern "faermat_mat_qr_f32"]
private opaque qrF32 : @& Matrix Float32 -> QR Float32
@[extern "faermat_mat_qr_c64"]
private opaque qrC64 : @& Matrix Numplex.C64 -> QR Numplex.C64
@[extern "faermat_mat_qr_c32"]
private opaque qrC32 : @& Matrix Numplex.C32 -> QR Numplex.C32

-- FFI: Q factor
@[extern "faermat_qr_Q_f64"]
private opaque qFactorF64 : @& QR Float -> Matrix Float
@[extern "faermat_qr_Q_f32"]
private opaque qFactorF32 : @& QR Float32 -> Matrix Float32
@[extern "faermat_qr_Q_c64"]
private opaque qFactorC64 : @& QR Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_qr_Q_c32"]
private opaque qFactorC32 : @& QR Numplex.C32 -> Matrix Numplex.C32

-- FFI: R factor
@[extern "faermat_qr_R_f64"]
private opaque rFactorF64 : @& QR Float -> Matrix Float
@[extern "faermat_qr_R_f32"]
private opaque rFactorF32 : @& QR Float32 -> Matrix Float32
@[extern "faermat_qr_R_c64"]
private opaque rFactorC64 : @& QR Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_qr_R_c32"]
private opaque rFactorC32 : @& QR Numplex.C32 -> Matrix Numplex.C32

-- FFI: solve
@[extern "faermat_qr_solve_f64"]
private opaque solveF64 : @& QR Float -> @& Matrix Float -> Matrix Float
@[extern "faermat_qr_solve_f32"]
private opaque solveF32 : @& QR Float32 -> @& Matrix Float32 -> Matrix Float32
@[extern "faermat_qr_solve_c64"]
private opaque solveC64 :
    @& QR Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_qr_solve_c32"]
private opaque solveC32 :
    @& QR Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

-- FFI: solve least squares
@[extern "faermat_qr_solve_lstsq_f64"]
private opaque solveLstsqF64 : @& QR Float -> @& Matrix Float -> Matrix Float
@[extern "faermat_qr_solve_lstsq_f32"]
private opaque solveLstsqF32 :
    @& QR Float32 -> @& Matrix Float32 -> Matrix Float32
@[extern "faermat_qr_solve_lstsq_c64"]
private opaque solveLstsqC64 :
    @& QR Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_qr_solve_lstsq_c32"]
private opaque solveLstsqC32 :
    @& QR Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

-- Ops typeclass
class Ops (a : Type) where
  new : Matrix a -> QR a
  qFactor : QR a -> Matrix a
  rFactor : QR a -> Matrix a
  solve : QR a -> Matrix a -> Matrix a
  solveLstsq : QR a -> Matrix a -> Matrix a

instance : Ops Float where
  new := qrF64
  qFactor := qFactorF64
  rFactor := rFactorF64
  solve := solveF64
  solveLstsq := solveLstsqF64

instance : Ops Float32 where
  new := qrF32
  qFactor := qFactorF32
  rFactor := rFactorF32
  solve := solveF32
  solveLstsq := solveLstsqF32

instance : Ops Numplex.C64 where
  new := qrC64
  qFactor := qFactorC64
  rFactor := rFactorC64
  solve := solveC64
  solveLstsq := solveLstsqC64

instance : Ops Numplex.C32 where
  new := qrC32
  qFactor := qFactorC32
  rFactor := rFactorC32
  solve := solveC32
  solveLstsq := solveLstsqC32

/--
Compute the QR decomposition.
-/
def new [Ops a] (m : Matrix a) : QR a :=
  Ops.new m

/--
Extract the thin Q factor.
-/
def Q [Ops a] (qr : QR a) : Matrix a :=
  Ops.qFactor qr

/--
Extract the thin R factor.
-/
def R [Ops a] (qr : QR a) : Matrix a :=
  Ops.rFactor qr

/--
Solve `A x = b` (square systems).
-/
def solve [Ops a] (qr : QR a) (b : Matrix a) : Matrix a :=
  Ops.solve qr b

/--
Solve `A x = b` in the least-squares sense.
-/
def solveLstsq [Ops a] (qr : QR a) (b : Matrix a) : Matrix a :=
  Ops.solveLstsq qr b

end QR

/- Cholesky decomposition (LLT) -----------------------------------------------/

opaque Cholesky.Nonempty : NonemptyType
def Cholesky (_a : Type) : Type := Cholesky.Nonempty.type
instance : Nonempty (Cholesky a) := Cholesky.Nonempty.property

namespace Cholesky

-- FFI: new
@[extern "faermat_mat_cholesky_f64"]
private opaque choleskyF64 : @& Matrix Float -> Option (Cholesky Float)
@[extern "faermat_mat_cholesky_f32"]
private opaque choleskyF32 : @& Matrix Float32 -> Option (Cholesky Float32)
@[extern "faermat_mat_cholesky_c64"]
private opaque choleskyC64 :
    @& Matrix Numplex.C64 -> Option (Cholesky Numplex.C64)
@[extern "faermat_mat_cholesky_c32"]
private opaque choleskyC32 :
    @& Matrix Numplex.C32 -> Option (Cholesky Numplex.C32)

-- FFI: L factor
@[extern "faermat_cholesky_L_f64"]
private opaque lFactorF64 : @& Cholesky Float -> Matrix Float
@[extern "faermat_cholesky_L_f32"]
private opaque lFactorF32 : @& Cholesky Float32 -> Matrix Float32
@[extern "faermat_cholesky_L_c64"]
private opaque lFactorC64 : @& Cholesky Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_cholesky_L_c32"]
private opaque lFactorC32 : @& Cholesky Numplex.C32 -> Matrix Numplex.C32

-- FFI: solve
@[extern "faermat_cholesky_solve_f64"]
private opaque solveF64 : @& Cholesky Float -> @& Matrix Float -> Matrix Float
@[extern "faermat_cholesky_solve_f32"]
private opaque solveF32 :
    @& Cholesky Float32 -> @& Matrix Float32 -> Matrix Float32
@[extern "faermat_cholesky_solve_c64"]
private opaque solveC64 :
    @& Cholesky Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_cholesky_solve_c32"]
private opaque solveC32 :
    @& Cholesky Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

-- FFI: inverse
@[extern "faermat_cholesky_inverse_f64"]
private opaque inverseF64 : @& Cholesky Float -> Matrix Float
@[extern "faermat_cholesky_inverse_f32"]
private opaque inverseF32 : @& Cholesky Float32 -> Matrix Float32
@[extern "faermat_cholesky_inverse_c64"]
private opaque inverseC64 : @& Cholesky Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_cholesky_inverse_c32"]
private opaque inverseC32 : @& Cholesky Numplex.C32 -> Matrix Numplex.C32

-- Ops typeclass
class Ops (a : Type) where
  new : Matrix a -> Option (Cholesky a)
  lFactor : Cholesky a -> Matrix a
  solve : Cholesky a -> Matrix a -> Matrix a
  inverse : Cholesky a -> Matrix a

instance : Ops Float where
  new := choleskyF64
  lFactor := lFactorF64
  solve := solveF64
  inverse := inverseF64

instance : Ops Float32 where
  new := choleskyF32
  lFactor := lFactorF32
  solve := solveF32
  inverse := inverseF32

instance : Ops Numplex.C64 where
  new := choleskyC64
  lFactor := lFactorC64
  solve := solveC64
  inverse := inverseC64

instance : Ops Numplex.C32 where
  new := choleskyC32
  lFactor := lFactorC32
  solve := solveC32
  inverse := inverseC32

/--
Compute the Cholesky decomposition. Returns `none` if the matrix is not
positive definite (or not Hermitian positive definite for complex types).
-/
def new [Ops a] (m : Matrix a) : Option (Cholesky a) :=
  Ops.new m

/--
Extract the L factor (lower triangular).
-/
def L [Ops a] (chol : Cholesky a) : Matrix a :=
  Ops.lFactor chol

/--
Solve `A x = b`.
-/
def solve [Ops a] (chol : Cholesky a) (b : Matrix a) : Matrix a :=
  Ops.solve chol b

/--
Compute the inverse.
-/
def inverse [Ops a] (chol : Cholesky a) : Matrix a :=
  Ops.inverse chol

end Cholesky

/- SVD (thin) -----------------------------------------------------------------/

opaque SVD.Nonempty : NonemptyType
def SVD (_a : Type) : Type := SVD.Nonempty.type
instance : Nonempty (SVD a) := SVD.Nonempty.property

namespace SVD

-- FFI: new
@[extern "faermat_mat_svd_f64"]
private opaque svdF64 : @& Matrix Float -> Option (SVD Float)
@[extern "faermat_mat_svd_f32"]
private opaque svdF32 : @& Matrix Float32 -> Option (SVD Float32)
@[extern "faermat_mat_svd_c64"]
private opaque svdC64 : @& Matrix Numplex.C64 -> Option (SVD Numplex.C64)
@[extern "faermat_mat_svd_c32"]
private opaque svdC32 : @& Matrix Numplex.C32 -> Option (SVD Numplex.C32)

-- FFI: U factor
@[extern "faermat_svd_U_f64"]
private opaque uFactorF64 : @& SVD Float -> Matrix Float
@[extern "faermat_svd_U_f32"]
private opaque uFactorF32 : @& SVD Float32 -> Matrix Float32
@[extern "faermat_svd_U_c64"]
private opaque uFactorC64 : @& SVD Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_svd_U_c32"]
private opaque uFactorC32 : @& SVD Numplex.C32 -> Matrix Numplex.C32

-- FFI: V factor
@[extern "faermat_svd_V_f64"]
private opaque vFactorF64 : @& SVD Float -> Matrix Float
@[extern "faermat_svd_V_f32"]
private opaque vFactorF32 : @& SVD Float32 -> Matrix Float32
@[extern "faermat_svd_V_c64"]
private opaque vFactorC64 : @& SVD Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_svd_V_c32"]
private opaque vFactorC32 : @& SVD Numplex.C32 -> Matrix Numplex.C32

-- FFI: singular values (always real)
@[extern "faermat_svd_S_f64"]
private opaque singularValuesF64 : @& SVD Float -> Array Float
@[extern "faermat_svd_S_f32"]
private opaque singularValuesF32 : @& SVD Float32 -> Array Float32
@[extern "faermat_svd_S_c64"]
private opaque singularValuesC64 : @& SVD Numplex.C64 -> Array Float
@[extern "faermat_svd_S_c32"]
private opaque singularValuesC32 : @& SVD Numplex.C32 -> Array Float32

-- FFI: pseudoinverse
@[extern "faermat_svd_pseudoinverse_f64"]
private opaque pseudoinverseF64 : @& SVD Float -> Matrix Float
@[extern "faermat_svd_pseudoinverse_f32"]
private opaque pseudoinverseF32 : @& SVD Float32 -> Matrix Float32
@[extern "faermat_svd_pseudoinverse_c64"]
private opaque pseudoinverseC64 : @& SVD Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_svd_pseudoinverse_c32"]
private opaque pseudoinverseC32 : @& SVD Numplex.C32 -> Matrix Numplex.C32

-- FFI: solve least squares
@[extern "faermat_svd_solve_lstsq_f64"]
private opaque solveLstsqF64 : @& SVD Float -> @& Matrix Float -> Matrix Float
@[extern "faermat_svd_solve_lstsq_f32"]
private opaque solveLstsqF32 :
    @& SVD Float32 -> @& Matrix Float32 -> Matrix Float32
@[extern "faermat_svd_solve_lstsq_c64"]
private opaque solveLstsqC64 :
    @& SVD Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_svd_solve_lstsq_c32"]
private opaque solveLstsqC32 :
    @& SVD Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

-- Ops typeclass (r = real type for singular values)
class Ops (a : Type) (r : outParam Type) where
  new : Matrix a -> Option (SVD a)
  uFactor : SVD a -> Matrix a
  vFactor : SVD a -> Matrix a
  singularValues : SVD a -> Array r
  pseudoinverse : SVD a -> Matrix a
  solveLstsq : SVD a -> Matrix a -> Matrix a

instance : Ops Float Float where
  new := svdF64
  uFactor := uFactorF64
  vFactor := vFactorF64
  singularValues := singularValuesF64
  pseudoinverse := pseudoinverseF64
  solveLstsq := solveLstsqF64

instance : Ops Float32 Float32 where
  new := svdF32
  uFactor := uFactorF32
  vFactor := vFactorF32
  singularValues := singularValuesF32
  pseudoinverse := pseudoinverseF32
  solveLstsq := solveLstsqF32

instance : Ops Numplex.C64 Float where
  new := svdC64
  uFactor := uFactorC64
  vFactor := vFactorC64
  singularValues := singularValuesC64
  pseudoinverse := pseudoinverseC64
  solveLstsq := solveLstsqC64

instance : Ops Numplex.C32 Float32 where
  new := svdC32
  uFactor := uFactorC32
  vFactor := vFactorC32
  singularValues := singularValuesC32
  pseudoinverse := pseudoinverseC32
  solveLstsq := solveLstsqC32

/--
Compute the thin SVD. Returns `none` on convergence failure.
-/
def new [Ops a r] (m : Matrix a) : Option (SVD a) :=
  Ops.new m

/--
Extract the U factor.
-/
def U [Ops a r] (svd : SVD a) : Matrix a :=
  Ops.uFactor svd

/--
Extract the V factor.
-/
def V [Ops a r] (svd : SVD a) : Matrix a :=
  Ops.vFactor svd

/--
Extract the singular values as a flat array (in nonincreasing order). Always
real-valued.
-/
def singularValues [Ops a r] (svd : SVD a) : Array r :=
  Ops.singularValues svd

/--
Compute the pseudoinverse.
-/
def pseudoinverse [Ops a r] (svd : SVD a) : Matrix a :=
  Ops.pseudoinverse svd

/--
Solve `A x = b` in the least-squares sense.
-/
def solveLstsq [Ops a r] (svd : SVD a) (b : Matrix a) : Matrix a :=
  Ops.solveLstsq svd b

end SVD

/- Self-adjoint eigendecomposition --------------------------------------------/

opaque SelfAdjointEigen.Nonempty : NonemptyType
def SelfAdjointEigen (_a : Type) : Type := SelfAdjointEigen.Nonempty.type
instance : Nonempty (SelfAdjointEigen a) := SelfAdjointEigen.Nonempty.property

namespace SelfAdjointEigen

-- FFI: new
@[extern "faermat_mat_selfadjoint_eigen_f64"]
private opaque eigenF64 : @& Matrix Float -> Option (SelfAdjointEigen Float)
@[extern "faermat_mat_selfadjoint_eigen_f32"]
private opaque eigenF32 : @& Matrix Float32 -> Option (SelfAdjointEigen Float32)
@[extern "faermat_mat_selfadjoint_eigen_c64"]
private opaque eigenC64 :
    @& Matrix Numplex.C64 -> Option (SelfAdjointEigen Numplex.C64)
@[extern "faermat_mat_selfadjoint_eigen_c32"]
private opaque eigenC32 :
    @& Matrix Numplex.C32 -> Option (SelfAdjointEigen Numplex.C32)

-- FFI: eigenvectors
@[extern "faermat_selfadjoint_eigen_U_f64"]
private opaque eigenvectorsF64 : @& SelfAdjointEigen Float -> Matrix Float
@[extern "faermat_selfadjoint_eigen_U_f32"]
private opaque eigenvectorsF32 : @& SelfAdjointEigen Float32 -> Matrix Float32
@[extern "faermat_selfadjoint_eigen_U_c64"]
private opaque eigenvectorsC64 :
    @& SelfAdjointEigen Numplex.C64 -> Matrix Numplex.C64
@[extern "faermat_selfadjoint_eigen_U_c32"]
private opaque eigenvectorsC32 :
    @& SelfAdjointEigen Numplex.C32 -> Matrix Numplex.C32

-- FFI: eigenvalues (always real)
@[extern "faermat_selfadjoint_eigen_S_f64"]
private opaque eigenvaluesF64 : @& SelfAdjointEigen Float -> Array Float
@[extern "faermat_selfadjoint_eigen_S_f32"]
private opaque eigenvaluesF32 : @& SelfAdjointEigen Float32 -> Array Float32
@[extern "faermat_selfadjoint_eigen_S_c64"]
private opaque eigenvaluesC64 : @& SelfAdjointEigen Numplex.C64 -> Array Float
@[extern "faermat_selfadjoint_eigen_S_c32"]
private opaque eigenvaluesC32 : @& SelfAdjointEigen Numplex.C32 -> Array Float32

-- Ops typeclass (r = real type for eigenvalues)
class Ops (a : Type) (r : outParam Type) where
  new : Matrix a -> Option (SelfAdjointEigen a)
  eigenvectors : SelfAdjointEigen a -> Matrix a
  eigenvalues : SelfAdjointEigen a -> Array r

instance : Ops Float Float where
  new := eigenF64
  eigenvectors := eigenvectorsF64
  eigenvalues := eigenvaluesF64

instance : Ops Float32 Float32 where
  new := eigenF32
  eigenvectors := eigenvectorsF32
  eigenvalues := eigenvaluesF32

instance : Ops Numplex.C64 Float where
  new := eigenC64
  eigenvectors := eigenvectorsC64
  eigenvalues := eigenvaluesC64

instance : Ops Numplex.C32 Float32 where
  new := eigenC32
  eigenvectors := eigenvectorsC32
  eigenvalues := eigenvaluesC32

/--
Compute the self-adjoint (symmetric/Hermitian) eigendecomposition. Returns
`none` on convergence failure.
-/
def new [Ops a r] (m : Matrix a) : Option (SelfAdjointEigen a) :=
  Ops.new m

/--
Extract the eigenvectors (columns of U).
-/
def eigenvectors [Ops a r] (evd : SelfAdjointEigen a) : Matrix a :=
  Ops.eigenvectors evd

/--
Extract the eigenvalues (in nondecreasing order). Always real-valued.
-/
def eigenvalues [Ops a r] (evd : SelfAdjointEigen a) : Array r :=
  Ops.eigenvalues evd

end SelfAdjointEigen

/- General eigendecomposition -------------------------------------------------/

opaque Eigen.Nonempty : NonemptyType
def Eigen (_a : Type) : Type := Eigen.Nonempty.type
instance : Nonempty (Eigen a) := Eigen.Nonempty.property

namespace Eigen

-- FFI (Float -> C64)
@[extern "faermat_mat_eigen_f64"]
private opaque eigenF64 : @& Matrix Float -> Option (Eigen Float)
@[extern "faermat_eigen_U_f64"]
private opaque eigenvectorsF64 : @& Eigen Float -> Matrix Numplex.C64
@[extern "faermat_eigen_S_f64"]
private opaque eigenvaluesF64 : @& Eigen Float -> Array Numplex.C64

-- FFI (Float32 -> C32)
@[extern "faermat_mat_eigen_f32"]
private opaque eigenF32 : @& Matrix Float32 -> Option (Eigen Float32)
@[extern "faermat_eigen_U_f32"]
private opaque eigenvectorsF32 : @& Eigen Float32 -> Matrix Numplex.C32
@[extern "faermat_eigen_S_f32"]
private opaque eigenvaluesF32 : @& Eigen Float32 -> Array Numplex.C32

-- Ops typeclass (c = complex output type)
class Ops (a : Type) (c : outParam Type) where
  new : Matrix a -> Option (Eigen a)
  eigenvectors : Eigen a -> Matrix c
  eigenvalues : Eigen a -> Array c

instance : Ops Float Numplex.C64 where
  new := eigenF64
  eigenvectors := eigenvectorsF64
  eigenvalues := eigenvaluesF64

instance : Ops Float32 Numplex.C32 where
  new := eigenF32
  eigenvectors := eigenvectorsF32
  eigenvalues := eigenvaluesF32

/--
Compute the general eigendecomposition. Returns `none` on convergence failure.
Eigenvalues and eigenvectors are complex-valued. Only available for real scalar
types (Float, Float32).
-/
def new [Ops a c] (m : Matrix a) : Option (Eigen a) :=
  Ops.new m

/--
Extract the eigenvectors (columns of U). Returns a complex matrix even for real
input.
-/
def eigenvectors [Ops a c] (evd : Eigen a) : Matrix c :=
  Ops.eigenvectors evd

/--
Extract the eigenvalues as a complex array.
-/
def eigenvalues [Ops a c] (evd : Eigen a) : Array c :=
  Ops.eigenvalues evd

end Eigen

/- Convenience methods on Matrix ----------------------------------------------/

namespace Matrix

-- FFI: determinant
@[extern "faermat_lu_det_f64"]
private opaque detF64 : @& Matrix Float -> Float
@[extern "faermat_lu_det_f32"]
private opaque detF32 : @& Matrix Float32 -> Float32
@[extern "faermat_lu_det_c64"]
private opaque detC64 : @& Matrix Numplex.C64 -> Numplex.C64
@[extern "faermat_lu_det_c32"]
private opaque detC32 : @& Matrix Numplex.C32 -> Numplex.C32

class HasDet (a : Type) where
  det : Matrix a -> a

instance : HasDet Float where
  det := detF64
instance : HasDet Float32 where
  det := detF32
instance : HasDet Numplex.C64 where
  det := detC64
instance : HasDet Numplex.C32 where
  det := detC32

-- FFI: singular values (convenience)
@[extern "faermat_mat_singular_values_f64"]
private opaque singularValuesF64 : @& Matrix Float -> Option (Array Float)
@[extern "faermat_mat_singular_values_f32"]
private opaque singularValuesF32 : @& Matrix Float32 -> Option (Array Float32)
@[extern "faermat_mat_singular_values_c64"]
private opaque singularValuesC64 : @& Matrix Numplex.C64 -> Option (Array Float)
@[extern "faermat_mat_singular_values_c32"]
private opaque singularValuesC32 :
    @& Matrix Numplex.C32 -> Option (Array Float32)

class HasSingularValues (a : Type) (r : outParam Type) where
  singularValues : Matrix a -> Option (Array r)

instance : HasSingularValues Float Float where
  singularValues := singularValuesF64
instance : HasSingularValues Float32 Float32 where
  singularValues := singularValuesF32
instance : HasSingularValues Numplex.C64 Float where
  singularValues := singularValuesC64
instance : HasSingularValues Numplex.C32 Float32 where
  singularValues := singularValuesC32

-- FFI: self-adjoint eigenvalues (convenience)
@[extern "faermat_mat_selfadjoint_eigenvalues_f64"]
private opaque selfAdjointEigenvaluesF64 :
    @& Matrix Float -> Option (Array Float)
@[extern "faermat_mat_selfadjoint_eigenvalues_f32"]
private opaque selfAdjointEigenvaluesF32 :
    @& Matrix Float32 -> Option (Array Float32)
@[extern "faermat_mat_selfadjoint_eigenvalues_c64"]
private opaque selfAdjointEigenvaluesC64 :
    @& Matrix Numplex.C64 -> Option (Array Float)
@[extern "faermat_mat_selfadjoint_eigenvalues_c32"]
private opaque selfAdjointEigenvaluesC32 :
    @& Matrix Numplex.C32 -> Option (Array Float32)

class HasSelfAdjointEigenvalues (a : Type) (r : outParam Type) where
  selfAdjointEigenvalues : Matrix a -> Option (Array r)

instance : HasSelfAdjointEigenvalues Float Float where
  selfAdjointEigenvalues := selfAdjointEigenvaluesF64
instance : HasSelfAdjointEigenvalues Float32 Float32 where
  selfAdjointEigenvalues := selfAdjointEigenvaluesF32
instance : HasSelfAdjointEigenvalues Numplex.C64 Float where
  selfAdjointEigenvalues := selfAdjointEigenvaluesC64
instance : HasSelfAdjointEigenvalues Numplex.C32 Float32 where
  selfAdjointEigenvalues := selfAdjointEigenvaluesC32

-- FFI: general eigenvalues (convenience, real only)
@[extern "faermat_mat_eigenvalues_f64"]
private opaque eigenvaluesF64 : @& Matrix Float -> Option (Array Numplex.C64)
@[extern "faermat_mat_eigenvalues_f32"]
private opaque eigenvaluesF32 : @& Matrix Float32 -> Option (Array Numplex.C32)

class HasEigenvalues (a : Type) (c : outParam Type) where
  eigenvalues : Matrix a -> Option (Array c)

instance : HasEigenvalues Float Numplex.C64 where
  eigenvalues := eigenvaluesF64
instance : HasEigenvalues Float32 Numplex.C32 where
  eigenvalues := eigenvaluesF32

/--
Compute the determinant.
-/
def det [HasDet a] (m : Matrix a) : a :=
  HasDet.det m

/--
Solve `A x = B` using LU decomposition.
-/
def solve [LU.Ops a] (a' b : Matrix a) : Matrix a :=
  let lu := LU.new a'
  lu.solve b

/--
Solve `A x = b` (vector) using LU decomposition.
-/
def solveVec [LU.Ops a] (a' : Matrix a) (b : Vector a) : Vector a :=
  let lu := LU.new a'
  lu.solveVec b

/--
Compute the inverse using LU decomposition.
-/
def inv [LU.Ops a] (m : Matrix a) : Matrix a :=
  let lu := LU.new m
  lu.inverse

/--
Solve `A x = B` in the least-squares sense (QR).
-/
def lstsq [QR.Ops a] (a' b : Matrix a) : Matrix a := let qr := QR.new a'
  qr.solveLstsq b

/--
Compute singular values (no U, V). Returns `none` on convergence failure.
-/
def singularValues [HasSingularValues a r] (m : Matrix a) : Option (Array r) :=
  HasSingularValues.singularValues m

/--
Compute eigenvalues of a symmetric/Hermitian matrix. Returns `none` on
convergence failure.
-/
def selfAdjointEigenvalues [HasSelfAdjointEigenvalues a r] (m : Matrix a) :
    Option (Array r) :=
  HasSelfAdjointEigenvalues.selfAdjointEigenvalues m

/--
Compute eigenvalues of a general (non-symmetric) matrix. Returns complex
eigenvalues. Returns `none` on convergence failure. Only available for real
scalar types (Float, Float32).
-/
def eigenvalues [HasEigenvalues a c] (m : Matrix a) : Option (Array c) :=
  HasEigenvalues.eigenvalues m

/- Matrix functions via Eigen -------------------------------------------------/

-- expm FFI declarations
@[extern "faermat_mat_expm_f64"]
private opaque expmF64 : @& Matrix Float -> Option (Matrix Float)
@[extern "faermat_mat_expm_f32"]
private opaque expmF32 :
    @& Matrix Float32 -> Option (Matrix Float32)
@[extern "faermat_mat_expm_c64"]
private opaque expmC64 :
    @& Matrix Numplex.C64 -> Option (Matrix Numplex.C64)
@[extern "faermat_mat_expm_c32"]
private opaque expmC32 :
    @& Matrix Numplex.C32 -> Option (Matrix Numplex.C32)

-- sqrtm FFI declarations (real input -> complex output)
@[extern "faermat_mat_sqrtm_f64"]
private opaque sqrtmF64 :
    @& Matrix Float -> Option (Matrix Numplex.C64)
@[extern "faermat_mat_sqrtm_f32"]
private opaque sqrtmF32 :
    @& Matrix Float32 -> Option (Matrix Numplex.C32)
@[extern "faermat_mat_sqrtm_c64"]
private opaque sqrtmC64 :
    @& Matrix Numplex.C64 -> Option (Matrix Numplex.C64)
@[extern "faermat_mat_sqrtm_c32"]
private opaque sqrtmC32 :
    @& Matrix Numplex.C32 -> Option (Matrix Numplex.C32)

-- logm FFI declarations (real input -> complex output)
@[extern "faermat_mat_logm_f64"]
private opaque logmF64 :
    @& Matrix Float -> Option (Matrix Numplex.C64)
@[extern "faermat_mat_logm_f32"]
private opaque logmF32 :
    @& Matrix Float32 -> Option (Matrix Numplex.C32)
@[extern "faermat_mat_logm_c64"]
private opaque logmC64 :
    @& Matrix Numplex.C64 -> Option (Matrix Numplex.C64)
@[extern "faermat_mat_logm_c32"]
private opaque logmC32 :
    @& Matrix Numplex.C32 -> Option (Matrix Numplex.C32)

/--
Internal typeclass for matrix exponential FFI dispatch. Use the public
`Matrix.expm` function instead.
-/
class HasExpm (a : Type) where
  expm : Matrix a -> Option (Matrix a)

instance : HasExpm Float where
  expm m := expmF64 m
instance : HasExpm Float32 where
  expm m := expmF32 m
instance : HasExpm Numplex.C64 where
  expm m := expmC64 m
instance : HasExpm Numplex.C32 where
  expm m := expmC32 m

/--
Internal typeclass for matrix square root FFI dispatch. Use the public
`Matrix.sqrtm` function instead.
-/
class HasSqrtm (a : Type) (c : outParam Type) where
  sqrtm : Matrix a -> Option (Matrix c)

instance : HasSqrtm Float Numplex.C64 where
  sqrtm m := sqrtmF64 m
instance : HasSqrtm Float32 Numplex.C32 where
  sqrtm m := sqrtmF32 m
instance : HasSqrtm Numplex.C64 Numplex.C64 where
  sqrtm m := sqrtmC64 m
instance : HasSqrtm Numplex.C32 Numplex.C32 where
  sqrtm m := sqrtmC32 m

/--
Internal typeclass for matrix logarithm FFI dispatch. Use the public
`Matrix.logm` function instead.
-/
class HasLogm (a : Type) (c : outParam Type) where
  logm : Matrix a -> Option (Matrix c)

instance : HasLogm Float Numplex.C64 where
  logm m := logmF64 m
instance : HasLogm Float32 Numplex.C32 where
  logm m := logmF32 m
instance : HasLogm Numplex.C64 Numplex.C64 where
  logm m := logmC64 m
instance : HasLogm Numplex.C32 Numplex.C32 where
  logm m := logmC32 m

/--
Matrix exponential via eigendecomposition. Computes `V * diag(exp(lambda)) *
V^†`. Returns `none` on convergence failure or non-square input.
-/
def expm [HasExpm a] (m : Matrix a) : Option (Matrix a) :=
  HasExpm.expm m

/--
Matrix square root via eigendecomposition. For real input types, the result
is complex (negative eigenvalues produce complex square roots). Returns
`none` on convergence failure or non-square input.
-/
def sqrtm [HasSqrtm a c] (m : Matrix a) : Option (Matrix c) :=
  HasSqrtm.sqrtm m

/--
Matrix logarithm via eigendecomposition. For real input types, the result
is complex (negative eigenvalues produce complex logarithms). Returns
`none` on convergence failure or non-square input.
-/
def logm [HasLogm a c] (m : Matrix a) : Option (Matrix c) :=
  HasLogm.logm m

end Matrix
end Faermat
