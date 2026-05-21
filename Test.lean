import Faermat
import Fmtl
import Numplex

open Faermat
open Fmtl

def main : IO Unit := do
  IO.println "=== Basic Matrix ==="
  IO.println ""

  let eye : Matrix Float := Matrix.identity 3
  IO.println s!"identity 3x3:\n{eye}"
  IO.println ""

  -- Column-major: [col0..., col1..., col2...]
  let data := #[
    1.0, 4.0, 7.0,
    2.0, 5.0, 8.0,
    3.0, 6.0, 9.0,
  ]
  match Matrix.ofArray 3 3 data with
  | none => IO.println "error: failed to create matrix"
  | some m => do
    IO.println s!"m:\n{m}"

    let m2 := m * m
    IO.println s!"m * m:\n{m2}"

    IO.println (printf "formatted (3 dp):\n{:.3}" m)

    IO.println ""
    IO.println "=== Views + Vectors ==="
    IO.println ""

    -- Views
    match m.submatrix 0 1 2 2 with
    | none => IO.println "error: submatrix failed"
    | some sub =>
      IO.println s!"submatrix(0,1,2,2):\n{sub}"

    IO.println s!"trace(m) = {m.trace}"
    IO.println ""

    -- Vectors
    match Vector.ofArray #[1.0, 2.0, 3.0] with
    | none => IO.println "error: vector creation failed"
    | some v => do
      IO.println s!"v = {v}"
      IO.println s!"dot(v, v) = {Vector.dot v v}"
      IO.println s!"norm(v) = {v.norm}"
      IO.println s!"m * v = {m * v}"
      IO.println ""

  IO.println "=== Decompositions ==="
  IO.println ""

  -- Use a well-conditioned non-singular matrix
  -- A = [[2,1,0],[1,3,1],[0,1,2]]
  -- (symmetric positive definite)
  let aData := #[
    2.0, 1.0, 0.0,
    1.0, 3.0, 1.0,
    0.0, 1.0, 2.0,
  ]
  match Matrix.ofArray 3 3 aData with
  | none => IO.println "error: failed to create A"
  | some a => do
    IO.println s!"A:\n{a}"

    -- LU decomposition
    let lu := LU.new a
    IO.println s!"LU.L:\n{lu.L}"
    IO.println s!"LU.U:\n{lu.U}"

    -- Solve A x = b
    let bData := #[
      1.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0,
    ]
    match Matrix.ofArray 3 3 bData with
    | none => IO.println "error: failed to create b"
    | some b => do
      let x := lu.solve b
      IO.println s!"LU solve (A \\ I):\n{x}"

      -- Verify: A * x should be close to b
      let check := a * x
      IO.println (printf "A * (A \\ I) (should be I):\n{:.6}" check)
      IO.println ""

    -- Solve with vector RHS
    match Vector.ofArray #[1.0, 2.0, 3.0] with
    | none => IO.println "error"
    | some bv => do
      let xv := lu.solveVec bv
      IO.println s!"LU solve vec: x = {xv}"
      IO.println s!"A * x = {a * xv}"
      IO.println ""

    -- Determinant
    IO.println s!"det(A) = {a.det}"
    IO.println ""

    -- Inverse
    let ainv := a.inv
    IO.println (printf "A^-1:\n{:.6}" ainv)
    IO.println (printf "A * A^-1:\n{:.6}" (a * ainv))
    IO.println ""

    -- QR decomposition
    let qr := QR.new a
    IO.println (printf "QR.Q:\n{:.6}" qr.Q)
    IO.println (printf "QR.R:\n{:.6}" qr.R)
    IO.println (printf "Q * R (should be A):\n{:.6}" (qr.Q * qr.R))
    IO.println ""

    -- Cholesky (A is SPD)
    match Cholesky.new a with
    | none => IO.println "Cholesky failed (not SPD?)"
    | some chol => do
      IO.println (printf "Cholesky.L:\n{:.6}" chol.L)
      IO.println (printf "L * L^T (should be A):\n{:.6}"
        (chol.L * chol.L.transpose))
      IO.println ""

    -- SVD
    match SVD.new a with
    | none => IO.println "SVD failed"
    | some svd => do
      IO.println s!"singular values: {svd.singularValues}"
      IO.println (printf "SVD.U:\n{:.6}" svd.U)
      IO.println (printf "SVD.V:\n{:.6}" svd.V)
      IO.println ""

    -- Eigendecomposition (A is symmetric)
    match SelfAdjointEigen.new a with
    | none => IO.println "Eigendecomposition failed"
    | some evd => do
      IO.println s!"eigenvalues: {evd.eigenvalues}"
      IO.println (printf "eigenvectors:\n{:.6}" evd.eigenvectors)
      IO.println ""

    -- Convenience: singular values only
    match a.singularValues with
    | none => IO.println "singular values failed"
    | some sv =>
      IO.println s!"singular values (direct): {sv}"

    -- Convenience: eigenvalues only
    match a.selfAdjointEigenvalues with
    | none => IO.println "eigenvalues failed"
    | some ev =>
      IO.println s!"eigenvalues (direct): {ev}"

  IO.println ""
  IO.println "=== Least squares ==="
  IO.println ""

  -- Overdetermined system: 4x2 matrix
  let ovData := #[
    1.0, 2.0, 3.0, 4.0,
    1.0, 1.0, 1.0, 1.0,
  ]
  match Matrix.ofArray 4 2 ovData with
  | none => IO.println "error: failed to create A"
  | some aov => do
    IO.println s!"A (4x2):\n{aov}"
    let bData := #[1.0, 2.0, 3.0, 4.0]
    match Matrix.ofArray 4 1 bData with
    | none => IO.println "error"
    | some bov => do
      let x : Matrix Float := aov.lstsq bov
      IO.println (printf "lstsq solution:\n{:.6}" x)
      IO.println (printf "A * x:\n{:.6}" (aov * x))

  IO.println ""
  IO.println "=== Multi-scalar types ==="
  IO.println ""

  -- Float32 matrix
  IO.println "--- Float32 ---"
  let f32data : Array Float32 := #[1.0, 4.0, 2.0, 5.0, 3.0, 6.0]
  match Matrix.ofArray 2 3 f32data with
  | none => IO.println "error: f32 matrix creation"
  | some (m32 : Matrix Float32) => do
    IO.println s!"f32 nrows={m32.nrows}, ncols={m32.ncols}"
    let t32 := m32.transpose
    IO.println s!"f32 transpose nrows={t32.nrows}, ncols={t32.ncols}"
    let prod := m32 * t32
    IO.println s!"f32 m*m^T nrows={prod.nrows}, ncols={prod.ncols}"
    -- Check a known element: (0,0) of m*m^T
    -- m row 0 = [1,2,3], dot with [1,2,3] = 14
    IO.println s!"f32 (m*m^T)[0,0] = {prod[(0, 0)]!}"
    IO.println s!"f32 trace(m*m^T) = {prod.trace}"
    IO.println ""

    -- Float32 vector
    let v32data : Array Float32 := #[1.0, 2.0, 3.0]
    match Vector.ofArray v32data with
    | none => IO.println "error: f32 vector creation"
    | some (v32 : Vector Float32) => do
      IO.println s!"f32 vec len={v32.len}"
      IO.println s!"f32 dot(v,v) = {Vector.dot v32 v32}"
      let mv := m32 * v32
      IO.println s!"f32 m * v len={mv.len}"
      IO.println ""

  -- C64 matrix
  IO.println "--- C64 ---"
  let c (r i : Float) : Numplex.C64 := { re := r, im := i }
  -- 2x2 column-major: col0=[1+i, 3+0i], col1=[2-i, 4+2i]
  let c64data : Array Numplex.C64 := #[c 1 1, c 3 0, c 2 (-1), c 4 2]
  match Matrix.ofArray 2 2 c64data with
  | none => IO.println "error: c64 matrix creation"
  | some (mc : Matrix Numplex.C64) => do
    IO.println s!"c64 nrows={mc.nrows}, ncols={mc.ncols}"
    let elem := mc[(0, 1)]!
    IO.println s!"c64 [0,1] = {elem.re} + {elem.im}i"
    let mc2 := mc * mc
    let e00 := mc2[(0, 0)]!
    IO.println s!"c64 (m*m)[0,0] = {e00.re} + {e00.im}i"
    let tr := mc.trace
    IO.println s!"c64 trace = {tr.re} + {tr.im}i"
    IO.println ""

    -- C64 vector
    let vc64data : Array Numplex.C64 := #[c 1 0, c 0 1]
    match Vector.ofArray vc64data with
    | none => IO.println "error: c64 vector creation"
    | some (vc : Vector Numplex.C64) => do
      IO.println s!"c64 vec len={vc.len}"
      let d := Vector.dot vc vc
      IO.println s!"c64 dot(v,v) = {d.re} + {d.im}i"
      let mv := mc * vc
      IO.println s!"c64 m*v len={mv.len}"
      let mv0 := mv[0]!
      IO.println s!"c64 (m*v)[0] = {mv0.re} + {mv0.im}i"
      IO.println ""

  IO.println "=== Norm, adjoint, conjDot, formatting ==="
  IO.println ""

  -- Float norm + formatting
  match Matrix.ofArray 2 2 #[1.0, 3.0, 2.0, 4.0] with
  | none => IO.println "error"
  | some (mf : Matrix Float) => do
    IO.println s!"f64 matrix norm = {mf.norm}"
    IO.println s!"f64 adjoint (= transpose):\n{mf.adjoint}"
    IO.println (printf "f64 formatted:\n{:.2}" mf)

  -- Float vector norm + conjDot
  match Vector.ofArray #[3.0, 4.0] with
  | none => IO.println "error"
  | some (vf : Vector Float) => do
    IO.println s!"f64 vec norm = {vf.norm}"
    IO.println s!"f64 conjDot = {Vector.conjDot vf vf}"
    IO.println (printf "f64 vec formatted: {:.2}" vf)
    IO.println ""

  -- Float32 formatting + norm
  let f32data2 : Array Float32 := #[1.0, 3.0, 2.0, 4.0]
  match Matrix.ofArray 2 2 f32data2 with
  | none => IO.println "error"
  | some (m32b : Matrix Float32) => do
    IO.println s!"f32 matrix:\n{m32b}"
    IO.println s!"f32 norm = {m32b.norm}"

  let v32b_data : Array Float32 := #[3.0, 4.0]
  match Vector.ofArray v32b_data with
  | none => IO.println "error"
  | some (v32b : Vector Float32) => do
    IO.println s!"f32 vec: {v32b}"
    IO.println s!"f32 vec norm = {v32b.norm}"
    IO.println ""

  -- C64 formatting + norm + adjoint + conjDot
  let c (r i : Float) : Numplex.C64 := { re := r, im := i }
  let c64d : Array Numplex.C64 := #[c 1 2, c 3 0, c 0 (-1), c 4 2]
  match Matrix.ofArray 2 2 c64d with
  | none => IO.println "error"
  | some (mc2 : Matrix Numplex.C64) => do
    IO.println s!"c64 matrix:\n{mc2}"
    IO.println s!"c64 norm = {mc2.norm}"
    IO.println s!"c64 adjoint:\n{mc2.adjoint}"

  let vc64d : Array Numplex.C64 := #[c 1 2, c 3 (-4)]
  match Vector.ofArray vc64d with
  | none => IO.println "error"
  | some (vc2 : Vector Numplex.C64) => do
    IO.println s!"c64 vec: {vc2}"
    IO.println s!"c64 vec norm = {vc2.norm}"
    let cd := Vector.conjDot vc2 vc2
    IO.println s!"c64 conjDot = {cd.re} + {cd.im}i"
    let d := Vector.dot vc2 vc2
    IO.println s!"c64 dot = {d.re} + {d.im}i"
    IO.println ""

  IO.println ""
  IO.println "=== Eigen + matrix functions ==="
  IO.println ""

  -- General eigendecomposition (non-symmetric matrix)
  -- B = [[0, -1], [1, 0]] has eigenvalues +/- i
  match Matrix.ofArray 2 2 #[0.0, 1.0, -1.0, 0.0] with
  | none => IO.println "error: failed to create B"
  | some b => do
    match Eigen.new b with
    | none => IO.println "Eigen failed"
    | some evd => do
      let evals := evd.eigenvalues
      IO.println s!"Eigen eigenvalues:"
      for ev in evals do
        IO.println s!"  {ev.re} + {ev.im}i"
      IO.println (printf "Eigen eigenvectors:\n{:.6}"
        evd.eigenvectors)
      IO.println ""

    -- Convenience eigenvalues
    match b.eigenvalues with
    | none => IO.println "eigenvalues failed"
    | some evals => do
      IO.println s!"eigenvalues (direct):"
      for ev in evals do
        IO.println s!"  {ev.re} + {ev.im}i"
      IO.println ""

  -- Matrix exponential (symmetric matrix)
  -- A = [[2,1,0],[1,3,1],[0,1,2]] from above
  let aData2 := #[
    2.0, 1.0, 0.0,
    1.0, 3.0, 1.0,
    0.0, 1.0, 2.0,
  ]
  match Matrix.ofArray 3 3 aData2 with
  | none => IO.println "error"
  | some a2 => do
    match a2.expm with
    | none => IO.println "expm failed"
    | some ea =>
      IO.println (printf "expm(A):\n{:.6}" ea)

    match a2.sqrtm with
    | none => IO.println "sqrtm failed"
    | some (sa : Matrix Numplex.C64) => do
      IO.println (printf "sqrtm(A):\n{:.6}" sa)
      IO.println (printf
        "sqrtm(A) * sqrtm(A) (should be A):\n{:.6}"
        (sa * sa))

  -- Float32 expm/sqrtm
  IO.println "--- Float32 expm/sqrtm ---"
  let f32Sym : Array Float32 := #[
    2.0, 1.0, 0.0,
    1.0, 3.0, 1.0,
    0.0, 1.0, 2.0
  ]
  match Matrix.ofArray 3 3 f32Sym with
  | none => IO.println "error: f32 sym matrix"
  | some (s32 : Matrix Float32) => do
    match s32.expm with
    | none => IO.println "f32 expm failed"
    | some ea32 =>
      IO.println s!"f32 expm[0,0] = {ea32[(0, 0)]!}"
    match s32.sqrtm with
    | none => IO.println "f32 sqrtm failed"
    | some (sa32 : Matrix Numplex.C32) => do
      let check := sa32 * sa32
      IO.println
        s!"f32 sqrtm*sqrtm[0,0] = {check[(0, 0)]!}"
    IO.println ""

  -- C64 expm/sqrtm (Hermitian matrix)
  IO.println "--- C64 expm/sqrtm ---"
  let cc (r i : Float) : Numplex.C64 :=
    { re := r, im := i }
  let c64Sym : Array Numplex.C64 := #[cc 2 0, cc 1 1, cc 1 (-1), cc 3 0]
  match Matrix.ofArray 2 2 c64Sym with
  | none => IO.println "error: c64 sym matrix"
  | some (sc64 : Matrix Numplex.C64) => do
    match sc64.expm with
    | none => IO.println "c64 expm failed"
    | some eac =>
      let e00 := eac[(0, 0)]!
      IO.println s!"c64 expm[0,0] = {e00}"
    match sc64.sqrtm with
    | none => IO.println "c64 sqrtm failed"
    | some sac => do
      let check := sac * sac
      let c00 := check[(0, 0)]!
      IO.println s!"c64 sqrtm*sqrtm[0,0] = {c00}"
    match sc64.logm with
    | none => IO.println "c64 logm failed"
    | some logc =>
      let l00 := logc[(0, 0)]!
      IO.println s!"c64 logm[0,0] = {l00}"
    IO.println ""

  IO.println ""
  IO.println "=== Multi-type decompositions ==="
  IO.println ""

  -- Float32 LU decomposition
  IO.println "--- Float32 LU ---"
  let f32A : Array Float32 := #[
    2.0, 1.0, 0.0,
    1.0, 3.0, 1.0,
    0.0, 1.0, 2.0,
  ]
  match Matrix.ofArray 3 3 f32A with
  | none => IO.println "error: f32 matrix"
  | some (a32 : Matrix Float32) => do
    let lu32 := LU.new a32
    IO.println s!"f32 LU.L nrows={lu32.L.nrows}"
    IO.println s!"f32 LU.U nrows={lu32.U.nrows}"
    IO.println s!"f32 det = {a32.det}"
    let inv32 := a32.inv
    let check32 := a32 * inv32
    IO.println s!"f32 (A*A^-1)[0,0] = {check32[(0, 0)]!}"
    IO.println s!"f32 (A*A^-1)[1,1] = {check32[(1, 1)]!}"
    IO.println ""

    -- Float32 QR
    IO.println "--- Float32 QR ---"
    let qr32 := QR.new a32
    let q32r32 := qr32.Q * qr32.R
    IO.println s!"f32 Q*R[0,0] = {q32r32[(0, 0)]!}"
    IO.println ""

    -- Float32 Cholesky
    IO.println "--- Float32 Cholesky ---"
    match Cholesky.new a32 with
    | none => IO.println "f32 Cholesky failed"
    | some chol32 => do
      let l32 := chol32.L
      let llt32 := l32 * l32.transpose
      IO.println s!"f32 L*L^T[0,0] = {llt32[(0, 0)]!}"
      IO.println ""

    -- Float32 SVD
    IO.println "--- Float32 SVD ---"
    match SVD.new a32 with
    | none => IO.println "f32 SVD failed"
    | some svd32 => do
      IO.println s!"f32 singular values: {svd32.singularValues}"
      IO.println ""

    -- Float32 SelfAdjointEigen
    IO.println "--- Float32 SelfAdjointEigen ---"
    match SelfAdjointEigen.new a32 with
    | none => IO.println "f32 eigen failed"
    | some evd32 => do
      IO.println s!"f32 eigenvalues: {evd32.eigenvalues}"
      IO.println ""

    -- Float32 general Eigen
    IO.println "--- Float32 Eigen ---"
    match Eigen.new a32 with
    | none => IO.println "f32 Eigen failed"
    | some eig32 => do
      let evals32 := eig32.eigenvalues
      IO.println s!"f32 Eigen eigenvalues:"
      for ev in evals32 do
        IO.println s!"  {ev.re} + {ev.im}i"
      IO.println ""

  -- C64 LU decomposition
  IO.println "--- C64 LU ---"
  let c (r i : Float) : Numplex.C64 :=
    { re := r, im := i }
  -- 2x2 Hermitian positive definite:
  -- [[2, 1-i], [1+i, 3]]
  let c64A : Array Numplex.C64 := #[c 2 0, c 1 1, c 1 (-1), c 3 0]
  match Matrix.ofArray 2 2 c64A with
  | none => IO.println "error: c64 matrix"
  | some (ac : Matrix Numplex.C64) => do
    let d := ac.det
    IO.println s!"c64 det = {d.re} + {d.im}i"
    let inv_c := ac.inv
    let check_c := ac * inv_c
    let e00 := check_c[(0, 0)]!
    IO.println s!"c64 (A*A^-1)[0,0] = {e00.re} + {e00.im}i"
    IO.println ""

    -- C64 QR
    IO.println "--- C64 QR ---"
    let qrc := QR.new ac
    let qr_check := qrc.Q * qrc.R
    let qr00 := qr_check[(0, 0)]!
    IO.println s!"c64 Q*R[0,0] = {qr00.re} + {qr00.im}i"
    IO.println ""

    -- C64 Cholesky (Hermitian PD)
    IO.println "--- C64 Cholesky ---"
    match Cholesky.new ac with
    | none => IO.println "c64 Cholesky failed"
    | some cholc => do
      let lc := cholc.L
      let llt_c := lc * lc.adjoint
      let llt00 := llt_c[(0, 0)]!
      IO.println s!"c64 L*L^H[0,0] = {llt00.re} + {llt00.im}i"
      IO.println ""

    -- C64 SVD (singular values are real)
    IO.println "--- C64 SVD ---"
    match SVD.new ac with
    | none => IO.println "c64 SVD failed"
    | some svdc =>
      IO.println s!"c64 singular values: {svdc.singularValues}"
      IO.println ""

    -- C64 SelfAdjointEigen (eigenvalues are real)
    IO.println "--- C64 SelfAdjointEigen ---"
    match SelfAdjointEigen.new ac with
    | none => IO.println "c64 eigen failed"
    | some evdc =>
      IO.println s!"c64 eigenvalues: {evdc.eigenvalues}"
      IO.println ""

  -- Scientific notation formatting tests
  IO.println "=== Formatting: LowerExp / UpperExp ==="
  IO.println ""
  let fmtData := #[1.0, 4.0, 2.0, 50000.0]
  match Matrix.ofArray 2 2 fmtData with
  | none => IO.println "error"
  | some (fm : Matrix Float) => do
    IO.println (printf "lowerExp:\n{:e}" fm)
    IO.println (printf "upperExp:\n{:E}" fm)
    IO.println (printf "lowerExp .3:\n{:.3e}" fm)

  match Vector.ofArray #[0.001, 2500.0, -3.14] with
  | none => IO.println "error"
  | some (fv : Vector Float) => do
    IO.println (printf "vec lowerExp: {:e}" fv)
    IO.println (printf "vec upperExp: {:E}" fv)
  IO.println ""

  -- C64 scientific notation
  let cc2 (r i : Float) : Numplex.C64 := { re := r, im := i }
  let cfm : Array Numplex.C64 := #[cc2 1000 (-0.5), cc2 0.001 2.0]
  match Matrix.ofArray 1 2 cfm with
  | none => IO.println "error"
  | some (cm : Matrix Numplex.C64) => do
    IO.println (printf "c64 lowerExp: {:e}" cm)
    IO.println (printf "c64 upperExp: {:E}" cm)
  IO.println ""

  IO.println ""
  IO.println "=== GetElem + set ==="
  IO.println ""

  -- Matrix GetElem
  let mat := Matrix.ofArray 3 3 #[
    1.0, 4.0, 7.0,
    2.0, 5.0, 8.0,
    3.0, 6.0, 9.0,
  ]
  match mat with
  | none => IO.println "error"
  | some (mg : Matrix Float) => do
    IO.println s!"m[(0,0)]! = {mg[(0, 0)]!}"
    IO.println s!"m[(1,2)]! = {mg[(1, 2)]!}"
    -- GetElem? (bounds-checked)
    IO.println s!"m[(0,0)]? = {mg[(0, 0)]?}"
    IO.println s!"m[(100,0)]? = {mg[(100, 0)]?}"

    -- set
    let ms := mg.set 0 0 99.0
    IO.println s!"after set 0 0 99: m[(0,0)] = {ms[(0, 0)]!}"
    IO.println s!"original unchanged: m[(0,0)] = {mg[(0, 0)]!}"

    -- set?
    match mg.set? 0 0 42.0 with
    | some ms2 =>
      IO.println s!"set? 0 0 42: m[(0,0)] = {ms2[(0, 0)]!}"
    | none => IO.println "set? returned none (unexpected)"
    match mg.set? 100 0 42.0 with
    | some _ => IO.println "set? OOB returned some (unexpected)"
    | none => IO.println "set? 100 0: none (correct)"
    IO.println ""

  -- Vector GetElem
  match Vector.ofArray #[10.0, 20.0, 30.0] with
  | none => IO.println "error"
  | some (vg : Vector Float) => do
    IO.println s!"v[0]! = {vg[0]!}"
    IO.println s!"v[2]! = {vg[2]!}"
    IO.println s!"v[0]? = {vg[0]?}"
    IO.println s!"v[100]? = {vg[100]?}"

    -- set
    let vs := vg.set 1 77.0
    IO.println s!"after set 1 77: v[1] = {vs[1]!}"
    IO.println s!"original unchanged: v[1] = {vg[1]!}"
    IO.println ""

  -- C64 GetElem + set
  let cc3 (r i : Float) : Numplex.C64 := { re := r, im := i }
  let c64d2 : Array Numplex.C64 := #[cc3 1 2, cc3 3 0, cc3 0 (-1), cc3 4 2]
  match Matrix.ofArray 2 2 c64d2 with
  | none => IO.println "error"
  | some (mc3 : Matrix Numplex.C64) => do
    let e := mc3[(0, 1)]!
    IO.println s!"c64 m[(0,1)] = {e}"
    let mc3s := mc3.set 0 0 (cc3 99 (-99))
    IO.println s!"c64 after set: m[(0,0)] = {mc3s[(0, 0)]!}"
    IO.println ""

  IO.println ""
  IO.println "=== ofRowArray + fromFn ==="
  IO.println ""

  -- ofRowArray: row-major data [row0..., row1..., row2...]
  -- row0=[1,2,3], row1=[4,5,6], row2=[7,8,9]
  let rowData := #[
    1.0, 2.0, 3.0,
    4.0, 5.0, 6.0,
    7.0, 8.0, 9.0,
  ]
  match Matrix.ofRowArray 3 3 rowData with
  | none => IO.println "error: ofRowArray failed"
  | some (mr : Matrix Float) => do
    IO.println s!"ofRowArray 3x3:\n{mr}"
    IO.println s!"m[(0,1)]! = {mr[(0, 1)]!}"
    IO.println s!"m[(1,0)]! = {mr[(1, 0)]!}"
    IO.println s!"m[(2,2)]! = {mr[(2, 2)]!}"
    IO.println ""

  -- ofRowArray size mismatch
  match Matrix.ofRowArray 2 2 #[1.0, 2.0, 3.0] with
  | none => IO.println "ofRowArray size mismatch: none (correct)"
  | some _ => IO.println "ofRowArray size mismatch: some (wrong)"
  IO.println ""

  -- Matrix.fromFn
  let mfn : Matrix Float :=
    Matrix.fromFn 3 3 (fun i j =>
      Float.ofNat (i * 3 + j + 1))
  IO.println s!"fromFn 3x3 (1..9 row-major):\n{mfn}"
  IO.println s!"fromFn m[(0,1)]! = {mfn[(0, 1)]!}"
  IO.println s!"fromFn m[(1,0)]! = {mfn[(1, 0)]!}"
  IO.println ""

  -- Vector.fromFn
  let vfn : Vector Float :=
    Vector.fromFn 5 (fun i => Float.ofNat (i * i))
  IO.println s!"fromFn vec (i^2): {vfn}"
  IO.println s!"fromFn v[0]! = {vfn[0]!}"
  IO.println s!"fromFn v[4]! = {vfn[4]!}"
  IO.println ""

  IO.println ""
  IO.println "=== kron, reshape, isSquare, logm, powm ==="
  IO.println ""

  -- Kronecker product
  let ka := Matrix.identity (a := Float) 2
  let kb := Matrix.full 2 2 (1.0 : Float)
  let kp := ka.kron kb
  IO.println s!"kron(I2, ones(2,2)) shape: {kp.shape}"
  IO.println s!"kron result:\n{kp}"

  -- Reshape
  let rd : Array Float := #[1, 2, 3, 4, 5, 6]
  match Matrix.ofArray 2 3 rd with
  | none => IO.println "error: reshape source"
  | some r23 => do
    IO.println s!"2x3 matrix:\n{r23}"
    match r23.reshape 3 2 with
    | none => IO.println "reshape 3x2 failed"
    | some r32 =>
      IO.println s!"reshaped to 3x2:\n{r32}"
    match r23.reshape 4 2 with
    | none => IO.println "reshape 4x2: none (expected)"
    | some _ => IO.println "reshape 4x2: unexpected success"
    IO.println ""

  -- isSquare
  let sq := Matrix.identity (a := Float) 3
  let nsq := Matrix.zeros (a := Float) 2 3
  IO.println s!"identity 3x3 isSquare: {sq.isSquare}"
  IO.println s!"zeros 2x3 isSquare: {nsq.isSquare}"
  IO.println ""

  -- logm
  let diag2 : Array Float := #[2.0, 0.0, 0.0, 3.0]
  match Matrix.ofArray 2 2 diag2 with
  | none => IO.println "error: logm matrix"
  | some dmat => do
    match dmat.logm with
    | none => IO.println "logm failed"
    | some (lm : Matrix Numplex.C64) => do
      IO.println s!"logm(diag(2,3))[0,0] = {lm[(0, 0)]!}"
      IO.println s!"logm(diag(2,3))[1,1] = {lm[(1, 1)]!}"
      -- Round-trip: expm(logm(A)) should be A
      match lm.expm with
      | none => IO.println "expm(logm) failed"
      | some rt =>
        IO.println s!"expm(logm(A))[0,0] = {rt[(0, 0)]!}"
        IO.println s!"expm(logm(A))[1,1] = {rt[(1, 1)]!}"
    IO.println ""

  -- powm
  let pm : Array Float := #[1, 2, 3, 4]
  match Matrix.ofArray 2 2 pm with
  | none => IO.println "error: powm matrix"
  | some pmat => do
    let p0 := pmat ^ 0
    IO.println s!"m^0 (should be I):\n{p0}"
    let p1 := pmat ^ 1
    IO.println s!"m^1 (should be m):\n{p1}"
    let p2 := pmat ^ 2
    let m2 := pmat * pmat
    IO.println s!"m^2:\n{p2}"
    IO.println s!"m*m:\n{m2}"
    let p3 := pmat ^ 3
    IO.println s!"m^3:\n{p3}"
    IO.println ""
