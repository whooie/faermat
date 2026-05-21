import Faermat.Matrix
import Fmtl

namespace Faermat

/--
Opaque vector type backed by faer Col<T>.

Note on matrix-vector multiplication associativity: Lean 4's `*` is
`infixl:70`, so `A * B * v` parses as `(A * B) * v`, which computes the
matrix product first (O(n^3) + O(n^2)). For the more efficient O(n^2) +
O(n^2), use explicit parentheses: `A * (B * v)`.
-/
opaque Vector.Nonempty : NonemptyType
def Vector (_a : Type) : Type := Vector.Nonempty.type
instance : Nonempty (Vector a) := Vector.Nonempty.property

namespace Vector

/- FFI declarations: Float (f64, unboxed scalars) -----------------------------/

/- * Construction -------------------------------------------------------------/

@[extern "faermat_vec_of_array_f64"]
private opaque ofArrayF64 : @& Array Float -> Option (Vector Float)

@[extern "faermat_vec_zeros_f64"]
private opaque zerosF64 : UInt64 -> Vector Float

@[extern "faermat_vec_full_f64"]
private opaque fullF64 : UInt64 -> Float -> Vector Float

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_vec_len_f64"]
private opaque lenF64 : @& Vector Float -> UInt64

@[extern "faermat_vec_get_f64"]
private opaque getF64 : @& Vector Float -> UInt64 -> Float

@[extern "faermat_vec_to_array_f64"]
private opaque toArrayF64 : @& Vector Float -> Array Float

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_vec_add_f64"]
private opaque addF64 : @& Vector Float -> @& Vector Float -> Vector Float

@[extern "faermat_vec_sub_f64"]
private opaque subF64 : @& Vector Float -> @& Vector Float -> Vector Float

@[extern "faermat_vec_neg_f64"]
private opaque negF64 : @& Vector Float -> Vector Float

@[extern "faermat_vec_scale_f64"]
private opaque scaleF64 : Float -> @& Vector Float -> Vector Float

@[extern "faermat_vec_dot_f64"]
private opaque dotF64 : @& Vector Float -> @& Vector Float -> Float

@[extern "faermat_vec_set_f64"]
private opaque setF64 : Vector Float -> UInt64 -> Float -> Vector Float

@[extern "faermat_vec_norm_f64"]
private opaque normF64 : @& Vector Float -> Float

@[extern "faermat_vec_conj_dot_f64"]
private opaque conjDotF64 : @& Vector Float -> @& Vector Float -> Float

/- * Mat-vec multiply ---------------------------------------------------------/

@[extern "faermat_mat_vec_mul_f64"]
private opaque matVecMulF64 : @& Matrix Float -> @& Vector Float -> Vector Float

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_vec_to_string_f64"]
private opaque toStringF64 : @& Vector Float -> String

@[extern "faermat_vec_fmt_f64"]
private opaque fmtF64 :
  @& Vector Float ->
  Int64 ->
  Int64 ->
  UInt32 ->
  Int64 ->
  UInt8 ->
  UInt8 ->
  UInt8 ->
  String

@[extern "faermat_vec_fmt_lower_exp_f64"]
private opaque fmtLowerExpF64 :
  @& Vector Float ->
  Int64 ->
  Int64 ->
  UInt32 ->
  Int64 ->
  UInt8 ->
  UInt8 ->
  UInt8 ->
  String

@[extern "faermat_vec_fmt_upper_exp_f64"]
private opaque fmtUpperExpF64 :
  @& Vector Float ->
  Int64 ->
  Int64 ->
  UInt32 ->
  Int64 ->
  UInt8 ->
  UInt8 ->
  UInt8 ->
  String

/- FFI declarations: Float32 (f32, boxed scalars) -----------------------------/

/- * Construction -------------------------------------------------------------/

@[extern "faermat_vec_of_array_f32"]
private opaque ofArrayF32 : @& Array Float32 -> Option (Vector Float32)

@[extern "faermat_vec_zeros_f32"]
private opaque zerosF32 : UInt64 -> Vector Float32

@[extern "faermat_vec_full_f32"]
private opaque fullF32 : UInt64 -> @& Float32 -> Vector Float32

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_vec_len_f32"]
private opaque lenF32 : @& Vector Float32 -> UInt64

@[extern "faermat_vec_get_f32"]
private opaque getF32 : @& Vector Float32 -> UInt64 -> Float32

@[extern "faermat_vec_to_array_f32"]
private opaque toArrayF32 : @& Vector Float32 -> Array Float32

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_vec_add_f32"]
private opaque addF32 : @& Vector Float32 -> @& Vector Float32 -> Vector Float32

@[extern "faermat_vec_sub_f32"]
private opaque subF32 : @& Vector Float32 -> @& Vector Float32 -> Vector Float32

@[extern "faermat_vec_neg_f32"]
private opaque negF32 : @& Vector Float32 -> Vector Float32

@[extern "faermat_vec_scale_f32"]
private opaque scaleF32 : @& Float32 -> @& Vector Float32 -> Vector Float32

@[extern "faermat_vec_dot_f32"]
private opaque dotF32 : @& Vector Float32 -> @& Vector Float32 -> Float32

@[extern "faermat_vec_set_f32"]
private opaque setF32 : Vector Float32 -> UInt64 -> @& Float32 -> Vector Float32

@[extern "faermat_vec_norm_f32"]
private opaque normF32 : @& Vector Float32 -> Float32

@[extern "faermat_vec_conj_dot_f32"]
private opaque conjDotF32 : @& Vector Float32 -> @& Vector Float32 -> Float32

/- * Mat-vec multiply ---------------------------------------------------------/

@[extern "faermat_mat_vec_mul_f32"]
private opaque matVecMulF32 :
    @& Matrix Float32 -> @& Vector Float32 -> Vector Float32

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_vec_to_string_f32"]
private opaque toStringF32 : @& Vector Float32 -> String

@[extern "faermat_vec_fmt_f32"]
private opaque fmtF32 :
    @& Vector Float32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_lower_exp_f32"]
private opaque fmtLowerExpF32 :
    @& Vector Float32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_upper_exp_f32"]
private opaque fmtUpperExpF32 :
    @& Vector Float32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

/- FFI declarations: Numplex.C64 (complex f64, boxed scalars) -----------------/

/- * Construction -------------------------------------------------------------/

@[extern "faermat_vec_of_array_c64"]
private opaque ofArrayC64 : @& Array Numplex.C64 -> Option (Vector Numplex.C64)

@[extern "faermat_vec_zeros_c64"]
private opaque zerosC64 : UInt64 -> Vector Numplex.C64

@[extern "faermat_vec_full_c64"]
private opaque fullC64 : UInt64 -> @& Numplex.C64 -> Vector Numplex.C64

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_vec_len_c64"]
private opaque lenC64 : @& Vector Numplex.C64 -> UInt64

@[extern "faermat_vec_get_c64"]
private opaque getC64 : @& Vector Numplex.C64 -> UInt64 -> Numplex.C64

@[extern "faermat_vec_to_array_c64"]
private opaque toArrayC64 : @& Vector Numplex.C64 -> Array Numplex.C64

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_vec_add_c64"]
private opaque addC64 :
    @& Vector Numplex.C64 -> @& Vector Numplex.C64 -> Vector Numplex.C64

@[extern "faermat_vec_sub_c64"]
private opaque subC64 :
    @& Vector Numplex.C64 -> @& Vector Numplex.C64 -> Vector Numplex.C64

@[extern "faermat_vec_neg_c64"]
private opaque negC64 : @& Vector Numplex.C64 -> Vector Numplex.C64

@[extern "faermat_vec_scale_c64"]
private opaque scaleC64 :
    @& Numplex.C64 -> @& Vector Numplex.C64 -> Vector Numplex.C64

@[extern "faermat_vec_dot_c64"]
private opaque dotC64 :
    @& Vector Numplex.C64 -> @& Vector Numplex.C64 -> Numplex.C64

@[extern "faermat_vec_set_c64"]
private opaque setC64 :
    Vector Numplex.C64 -> UInt64 -> @& Numplex.C64 -> Vector Numplex.C64

@[extern "faermat_vec_norm_c64"]
private opaque normC64 : @& Vector Numplex.C64 -> Float

@[extern "faermat_vec_conj_dot_c64"]
private opaque conjDotC64 :
    @& Vector Numplex.C64 -> @& Vector Numplex.C64 -> Numplex.C64

/- * Mat-vec multiply ---------------------------------------------------------/

@[extern "faermat_mat_vec_mul_c64"]
private opaque matVecMulC64 :
    @& Matrix Numplex.C64 -> @& Vector Numplex.C64 -> Vector Numplex.C64

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_vec_to_string_c64"]
private opaque toStringC64 : @& Vector Numplex.C64 -> String

@[extern "faermat_vec_fmt_c64"]
private opaque fmtC64 :
    @& Vector Numplex.C64 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_lower_exp_c64"]
private opaque fmtLowerExpC64 :
    @& Vector Numplex.C64 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_upper_exp_c64"]
private opaque fmtUpperExpC64 :
    @& Vector Numplex.C64 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

/- FFI declarations: Numplex.C32 (complex f32, boxed scalars) -----------------/

/- * Construction -------------------------------------------------------------/

@[extern "faermat_vec_of_array_c32"]
private opaque ofArrayC32 : @& Array Numplex.C32 -> Option (Vector Numplex.C32)

@[extern "faermat_vec_zeros_c32"]
private opaque zerosC32 : UInt64 -> Vector Numplex.C32

@[extern "faermat_vec_full_c32"]
private opaque fullC32 : UInt64 -> @& Numplex.C32 -> Vector Numplex.C32

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_vec_len_c32"]
private opaque lenC32 : @& Vector Numplex.C32 -> UInt64

@[extern "faermat_vec_get_c32"]
private opaque getC32 : @& Vector Numplex.C32 -> UInt64 -> Numplex.C32

@[extern "faermat_vec_to_array_c32"]
private opaque toArrayC32 : @& Vector Numplex.C32 -> Array Numplex.C32

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_vec_add_c32"]
private opaque addC32 :
    @& Vector Numplex.C32 -> @& Vector Numplex.C32 -> Vector Numplex.C32

@[extern "faermat_vec_sub_c32"]
private opaque subC32 :
    @& Vector Numplex.C32 -> @& Vector Numplex.C32 -> Vector Numplex.C32

@[extern "faermat_vec_neg_c32"]
private opaque negC32 : @& Vector Numplex.C32 -> Vector Numplex.C32

@[extern "faermat_vec_scale_c32"]
private opaque scaleC32 :
    @& Numplex.C32 -> @& Vector Numplex.C32 -> Vector Numplex.C32

@[extern "faermat_vec_dot_c32"]
private opaque dotC32 :
    @& Vector Numplex.C32 -> @& Vector Numplex.C32 -> Numplex.C32

@[extern "faermat_vec_set_c32"]
private opaque setC32 :
    Vector Numplex.C32 -> UInt64 -> @& Numplex.C32 -> Vector Numplex.C32

@[extern "faermat_vec_norm_c32"]
private opaque normC32 : @& Vector Numplex.C32 -> Float32

@[extern "faermat_vec_conj_dot_c32"]
private opaque conjDotC32 :
    @& Vector Numplex.C32 -> @& Vector Numplex.C32 -> Numplex.C32

/- * Mat-vec multiply ---------------------------------------------------------/

@[extern "faermat_mat_vec_mul_c32"]
private opaque matVecMulC32 :
    @& Matrix Numplex.C32 -> @& Vector Numplex.C32 -> Vector Numplex.C32

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_vec_to_string_c32"]
private opaque toStringC32 : @& Vector Numplex.C32 -> String

@[extern "faermat_vec_fmt_c32"]
private opaque fmtC32 :
    @& Vector Numplex.C32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_lower_exp_c32"]
private opaque fmtLowerExpC32 :
    @& Vector Numplex.C32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_vec_fmt_upper_exp_c32"]
private opaque fmtUpperExpC32 :
    @& Vector Numplex.C32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

/- Dispatch typeclass ---------------------------------------------------------/

/--
Typeclass dispatching vector operations to the appropriate scalar-type-specific
FFI backend. Instances exist for `Float`, `Float32`, `Numplex.C64`, and
`Numplex.C32`.
-/
class Ops (a : Type) where
  ofArray : Array a -> Option (Vector a)
  zeros : UInt64 -> Vector a
  full : UInt64 -> a -> Vector a
  len : Vector a -> UInt64
  get : Vector a -> UInt64 -> a
  toArray : Vector a -> Array a
  add : Vector a -> Vector a -> Vector a
  sub : Vector a -> Vector a -> Vector a
  neg : Vector a -> Vector a
  scale : a -> Vector a -> Vector a
  dot : Vector a -> Vector a -> a
  set : Vector a -> UInt64 -> a -> Vector a
  conjDot : Vector a -> Vector a -> a
  matVecMul : Matrix a -> Vector a -> Vector a
  toString : Vector a -> String
  fmt :
    Vector a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String
  fmtLowerExp :
    Vector a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String
  fmtUpperExp :
    Vector a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

instance : Ops Float where
  ofArray data := ofArrayF64 data
  zeros n := zerosF64 n
  full n v := fullF64 n v
  len v := lenF64 v
  get v i := getF64 v i
  toArray v := toArrayF64 v
  add a b := addF64 a b
  sub a b := subF64 a b
  neg v := negF64 v
  scale s v := scaleF64 s v
  dot a b := dotF64 a b
  set v i val := setF64 v i val
  conjDot a b := conjDotF64 a b
  matVecMul m v := matVecMulF64 m v
  toString v := toStringF64 v
  fmt v p w f al sp alt zp := fmtF64 v p w f al sp alt zp
  fmtLowerExp v p w f al sp alt zp := fmtLowerExpF64 v p w f al sp alt zp
  fmtUpperExp v p w f al sp alt zp := fmtUpperExpF64 v p w f al sp alt zp

instance : Ops Float32 where
  ofArray data := ofArrayF32 data
  zeros n := zerosF32 n
  full n v := fullF32 n v
  len v := lenF32 v
  get v i := getF32 v i
  toArray v := toArrayF32 v
  add a b := addF32 a b
  sub a b := subF32 a b
  neg v := negF32 v
  scale s v := scaleF32 s v
  dot a b := dotF32 a b
  set v i val := setF32 v i val
  conjDot a b := conjDotF32 a b
  matVecMul m v := matVecMulF32 m v
  toString v := toStringF32 v
  fmt v p w f al sp alt zp := fmtF32 v p w f al sp alt zp
  fmtLowerExp v p w f al sp alt zp := fmtLowerExpF32 v p w f al sp alt zp
  fmtUpperExp v p w f al sp alt zp := fmtUpperExpF32 v p w f al sp alt zp

instance : Ops Numplex.C64 where
  ofArray data := ofArrayC64 data
  zeros n := zerosC64 n
  full n v := fullC64 n v
  len v := lenC64 v
  get v i := getC64 v i
  toArray v := toArrayC64 v
  add a b := addC64 a b
  sub a b := subC64 a b
  neg v := negC64 v
  scale s v := scaleC64 s v
  dot a b := dotC64 a b
  set v i val := setC64 v i val
  conjDot a b := conjDotC64 a b
  matVecMul m v := matVecMulC64 m v
  toString v := toStringC64 v
  fmt v p w f al sp alt zp := fmtC64 v p w f al sp alt zp
  fmtLowerExp v p w f al sp alt zp := fmtLowerExpC64 v p w f al sp alt zp
  fmtUpperExp v p w f al sp alt zp := fmtUpperExpC64 v p w f al sp alt zp

instance : Ops Numplex.C32 where
  ofArray data := ofArrayC32 data
  zeros n := zerosC32 n
  full n v := fullC32 n v
  len v := lenC32 v
  get v i := getC32 v i
  toArray v := toArrayC32 v
  add a b := addC32 a b
  sub a b := subC32 a b
  neg v := negC32 v
  scale s v := scaleC32 s v
  dot a b := dotC32 a b
  set v i val := setC32 v i val
  conjDot a b := conjDotC32 a b
  matVecMul m v := matVecMulC32 m v
  toString v := toStringC32 v
  fmt v p w f al sp alt zp := fmtC32 v p w f al sp alt zp
  fmtLowerExp v p w f al sp alt zp := fmtLowerExpC32 v p w f al sp alt zp
  fmtUpperExp v p w f al sp alt zp := fmtUpperExpC32 v p w f al sp alt zp

/- Public API -----------------------------------------------------------------/

/--
Create a vector from a flat array.
-/
def ofArray [Ops a] (data : Array a) : Option (Vector a) :=
  Ops.ofArray data

/--
Create a vector from a function `f i` mapping index to element.
-/
def fromFn [Ops a] (n : Nat) (f : Nat -> a) : Vector a :=
  let data := Array.ofFn (n := n) (fun i => f i.val)
  match Ops.ofArray data with
  | some v => v
  | none => Ops.zeros n.toUInt64 -- unreachable

/--
Create a zero vector of length `n`.
-/
def zeros [Ops a] (n : Nat) : Vector a :=
  Ops.zeros n.toUInt64

/--
Create a vector filled with a constant value.
-/
def full [Ops a] (n : Nat) (v : a) : Vector a :=
  Ops.full n.toUInt64 v

/--
Length of the vector.
-/
def len [Ops a] (v : Vector a) : Nat :=
  (Ops.len v).toNat

/--
Get the element at index `i`.
-/
def get? [Ops a] (v : Vector a) (i : Nat) : Option a :=
  if i < v.len then
    some (Ops.get v i.toUInt64)
  else
    none

/--
Extract to a flat array.
-/
def toArray [Ops a] (v : Vector a) : Array a :=
  Ops.toArray v

/--
Scale every element by a scalar.
-/
def scale [Ops a] (s : a) (v : Vector a) : Vector a :=
  Ops.scale s v

/--
Set the element at index `i`, returning a new vector. Mutates in place when
the reference count allows. Panics if out of bounds.
-/
def set [Ops a] (v : Vector a) (i : Nat) (val : a) : Vector a :=
  Ops.set v i.toUInt64 val

/--
Set the element at index `i`, returning `none` if out of bounds.
-/
def set? [Ops a] (v : Vector a) (i : Nat) (val : a) :
    Option (Vector a) :=
  if i < v.len then some (v.set i val) else none

/--
Dot product (inner product). Panics if lengths differ.
-/
def dot [Ops a] (va vb : Vector a) : a :=
  Ops.dot va vb

/--
L2 norm. Returns the real scalar type associated with `a`.
-/
class HasNorm (a : Type) (r : outParam Type) where
  normI : Vector a -> r

instance : HasNorm Float Float where
  normI v := normF64 v
instance : HasNorm Float32 Float32 where
  normI v := normF32 v
instance : HasNorm Numplex.C64 Float where
  normI v := normC64 v
instance : HasNorm Numplex.C32 Float32 where
  normI v := normC32 v

def norm [HasNorm a r] (v : Vector a) : r :=
  HasNorm.normI v

/--
Conjugate dot product. For real types, this is the same as `dot`. For complex
types, the left operand is conjugated: `conjDot u v = sum(conj(u_i) * v_i)`.
-/
def conjDot [Ops a] (va vb : Vector a) : a :=
  Ops.conjDot va vb

/--
Matrix-vector product. Panics if dimensions mismatch.
-/
def matMul [Ops a] (m : Matrix a) (v : Vector a) : Vector a :=
  Ops.matVecMul m v

/- * GetElem instances --------------------------------------------------------/

instance [Ops a] : GetElem (Vector a) Nat a (fun v i => i < v.len) where
  getElem v i _ := Ops.get v i.toUInt64

instance [Ops a] : GetElem? (Vector a) Nat a (fun v i => i < v.len) where
  getElem? v i := v.get? i

/- * Operator instances -------------------------------------------------------/

instance [Ops a] : Add (Vector a) where
  add := Ops.add

instance [Ops a] : Sub (Vector a) where
  sub := Ops.sub

instance [Ops a] : Neg (Vector a) where
  neg := Ops.neg

instance [Ops a] : HMul a (Vector a) (Vector a) where
  hMul := Ops.scale

instance [Ops a] : HMul (Vector a) a (Vector a) where
  hMul v x := x * v

instance [Ops a] : HMul (Matrix a) (Vector a) (Vector a) where
  hMul := Ops.matVecMul

/- * Formatting instances -----------------------------------------------------/

instance [Ops a] : ToString (Vector a) where
  toString v := Ops.toString v

private def fmtSpec (spec : Fmtl.FormatSpec) :
    Int64 × Int64 × UInt32 × Int64 × UInt8 × UInt8 × UInt8 :=
  let precision : Int64 :=
    match spec.precision with
    | some p => Int64.ofNat p
    | none => -1
  let width : Int64 :=
    match spec.width with
    | some w => Int64.ofNat w
    | none => -1
  let fill : UInt32 := spec.fill.toNat.toUInt32
  let align : Int64 :=
    match spec.align with
    | none => 0
    | some .left => 1
    | some .center => 2
    | some .right => 3
  let signPlus : UInt8 :=
    if spec.sign == .plus then 1 else 0
  let alt : UInt8 :=
    if spec.alternate then 1 else 0
  let zp : UInt8 :=
    if spec.zeroPad then 1 else 0
  (precision, width, fill, align, signPlus, alt, zp)

instance [Ops a] : Fmtl.Display (Vector a) where
  fmt v spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmt v p w f al sp alt zp

instance [Ops a] : Fmtl.LowerExp (Vector a) where
  fmt v spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmtLowerExp v p w f al sp alt zp

instance [Ops a] : Fmtl.UpperExp (Vector a) where
  fmt v spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmtUpperExp v p w f al sp alt zp

instance : Coe (Vector Float) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Vector Float32) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Vector Numplex.C64) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Vector Numplex.C32) (Fmtl.FmtArg .display) := Fmtl.Display.coe

instance : Coe (Vector Float) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Vector Float32) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Vector Numplex.C64) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Vector Numplex.C32) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe

instance : Coe (Vector Float) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Vector Float32) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Vector Numplex.C64) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Vector Numplex.C32) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe

end Vector
end Faermat
