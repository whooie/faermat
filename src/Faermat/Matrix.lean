import Faermat.Scalar
import Fmtl

namespace Faermat

-- Opaque matrix type. The phantom type parameter tracks the scalar type but is
-- erased at runtime; all variants share the same external-object
-- representation.
opaque Matrix.Nonempty : NonemptyType
def Matrix (_a : Type) : Type := Matrix.Nonempty.type
instance : Nonempty (Matrix a) := Matrix.Nonempty.property

namespace Matrix

/- FFI declarations: Float (f64, unboxed scalars) -----------------------------/

/- * Construction -------------------------------------------------------------/

@[extern "faermat_mat_of_array_f64"]
private opaque ofArrayF64 :
    UInt64 -> UInt64 -> @& Array Float -> Option (Matrix Float)

@[extern "faermat_mat_of_row_array_f64"]
private opaque ofRowArrayF64 :
    UInt64 -> UInt64 -> @& Array Float -> Option (Matrix Float)

@[extern "faermat_mat_zeros_f64"]
private opaque zerosF64 : UInt64 -> UInt64 -> Matrix Float

@[extern "faermat_mat_identity_f64"]
private opaque identityF64 : UInt64 -> Matrix Float

@[extern "faermat_mat_full_f64"]
private opaque fullF64 : UInt64 -> UInt64 -> Float -> Matrix Float

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_mat_nrows_f64"]
private opaque nrowsF64 : @& Matrix Float -> UInt64

@[extern "faermat_mat_ncols_f64"]
private opaque ncolsF64 : @& Matrix Float -> UInt64

@[extern "faermat_mat_get_f64"]
private opaque getF64 : @& Matrix Float -> UInt64 -> UInt64 -> Float

@[extern "faermat_mat_to_array_f64"]
private opaque toArrayF64 : @& Matrix Float -> Array Float

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_mat_add_f64"]
private opaque addF64 : @& Matrix Float -> @& Matrix Float -> Matrix Float

@[extern "faermat_mat_sub_f64"]
private opaque subF64 : @& Matrix Float -> @& Matrix Float -> Matrix Float

@[extern "faermat_mat_mul_f64"]
private opaque mulF64 : @& Matrix Float -> @& Matrix Float -> Matrix Float

@[extern "faermat_mat_scale_f64"]
private opaque scaleF64 : Float -> @& Matrix Float -> Matrix Float

@[extern "faermat_mat_transpose_f64"]
private opaque transposeF64 : @& Matrix Float -> Matrix Float

@[extern "faermat_mat_neg_f64"]
private opaque negF64 : @& Matrix Float -> Matrix Float

/- * Views --------------------------------------------------------------------/

@[extern "faermat_mat_submatrix_f64"]
private opaque submatrixF64 :
    @& Matrix Float ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    Option (Matrix Float)

@[extern "faermat_mat_row_f64"]
private opaque rowF64 : @& Matrix Float -> UInt64 -> Option (Matrix Float)

@[extern "faermat_mat_col_f64"]
private opaque colF64 : @& Matrix Float -> UInt64 -> Option (Matrix Float)

@[extern "faermat_mat_materialize_f64"]
private opaque materializeF64 : @& Matrix Float -> Matrix Float

/- * Diagonal -----------------------------------------------------------------/

@[extern "faermat_mat_diag_f64"]
private opaque diagF64 : @& Matrix Float -> Array Float

@[extern "faermat_mat_from_diag_f64"]
private opaque fromDiagF64 : @& Array Float -> Matrix Float

@[extern "faermat_mat_trace_f64"]
private opaque traceF64 : @& Matrix Float -> Float

/- * Norm / Adjoint -----------------------------------------------------------/

@[extern "faermat_mat_set_f64"]
private opaque setF64 :
    Matrix Float -> UInt64 -> UInt64 -> Float -> Matrix Float

@[extern "faermat_mat_kron_f64"]
private opaque kronF64 :
    @& Matrix Float -> @& Matrix Float -> Matrix Float

@[extern "faermat_mat_reshape_f64"]
private opaque reshapeF64 :
    Matrix Float -> UInt64 -> UInt64 -> Option (Matrix Float)

@[extern "faermat_mat_norm_f64"]
private opaque normF64 : @& Matrix Float -> Float

@[extern "faermat_mat_adjoint_f64"]
private opaque adjointF64 : @& Matrix Float -> Matrix Float

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_mat_to_string_f64"]
private opaque toStringF64 : @& Matrix Float -> String

@[extern "faermat_mat_fmt_f64"]
private opaque fmtF64 :
    @& Matrix Float ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_lower_exp_f64"]
private opaque fmtLowerExpF64 :
    @& Matrix Float ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_upper_exp_f64"]
private opaque fmtUpperExpF64 :
    @& Matrix Float ->
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

@[extern "faermat_mat_of_array_f32"]
private opaque ofArrayF32 :
    UInt64 -> UInt64 -> @& Array Float32 -> Option (Matrix Float32)

@[extern "faermat_mat_of_row_array_f32"]
private opaque ofRowArrayF32 :
    UInt64 -> UInt64 -> @& Array Float32 -> Option (Matrix Float32)

@[extern "faermat_mat_zeros_f32"]
private opaque zerosF32 : UInt64 -> UInt64 -> Matrix Float32

@[extern "faermat_mat_identity_f32"]
private opaque identityF32 : UInt64 -> Matrix Float32

@[extern "faermat_mat_full_f32"]
private opaque fullF32 : UInt64 -> UInt64 -> @& Float32 -> Matrix Float32

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_mat_nrows_f32"]
private opaque nrowsF32 : @& Matrix Float32 -> UInt64

@[extern "faermat_mat_ncols_f32"]
private opaque ncolsF32 : @& Matrix Float32 -> UInt64

@[extern "faermat_mat_get_f32"]
private opaque getF32 : @& Matrix Float32 -> UInt64 -> UInt64 -> Float32

@[extern "faermat_mat_to_array_f32"]
private opaque toArrayF32 : @& Matrix Float32 -> Array Float32

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_mat_add_f32"]
private opaque addF32 : @& Matrix Float32 -> @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_sub_f32"]
private opaque subF32 : @& Matrix Float32 -> @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_mul_f32"]
private opaque mulF32 : @& Matrix Float32 -> @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_scale_f32"]
private opaque scaleF32 : @& Float32 -> @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_transpose_f32"]
private opaque transposeF32 : @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_neg_f32"]
private opaque negF32 : @& Matrix Float32 -> Matrix Float32

/- * Views --------------------------------------------------------------------/

@[extern "faermat_mat_submatrix_f32"]
private opaque submatrixF32 :
    @& Matrix Float32 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    Option (Matrix Float32)

@[extern "faermat_mat_row_f32"]
private opaque rowF32 :
    @& Matrix Float32 -> UInt64 -> Option (Matrix Float32)

@[extern "faermat_mat_col_f32"]
private opaque colF32 :
    @& Matrix Float32 -> UInt64 -> Option (Matrix Float32)

@[extern "faermat_mat_materialize_f32"]
private opaque materializeF32 : @& Matrix Float32 -> Matrix Float32

/- * Diagonal -----------------------------------------------------------------/

@[extern "faermat_mat_diag_f32"]
private opaque diagF32 : @& Matrix Float32 -> Array Float32

@[extern "faermat_mat_from_diag_f32"]
private opaque fromDiagF32 : @& Array Float32 -> Matrix Float32

@[extern "faermat_mat_trace_f32"]
private opaque traceF32 : @& Matrix Float32 -> Float32

/- * Norm / Adjoint -----------------------------------------------------------/

@[extern "faermat_mat_set_f32"]
private opaque setF32 :
    Matrix Float32 -> UInt64 -> UInt64 -> @& Float32 -> Matrix Float32

@[extern "faermat_mat_kron_f32"]
private opaque kronF32 :
    @& Matrix Float32 -> @& Matrix Float32 -> Matrix Float32

@[extern "faermat_mat_reshape_f32"]
private opaque reshapeF32 :
    Matrix Float32 -> UInt64 -> UInt64 -> Option (Matrix Float32)

@[extern "faermat_mat_norm_f32"]
private opaque normF32 : @& Matrix Float32 -> Float32

@[extern "faermat_mat_adjoint_f32"]
private opaque adjointF32 : @& Matrix Float32 -> Matrix Float32

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_mat_to_string_f32"]
private opaque toStringF32 : @& Matrix Float32 -> String

@[extern "faermat_mat_fmt_f32"]
private opaque fmtF32 :
    @& Matrix Float32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_lower_exp_f32"]
private opaque fmtLowerExpF32 :
    @& Matrix Float32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_upper_exp_f32"]
private opaque fmtUpperExpF32 :
    @& Matrix Float32 ->
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

@[extern "faermat_mat_of_array_c64"]
private opaque ofArrayC64 :
    UInt64 -> UInt64 -> @& Array Numplex.C64 -> Option (Matrix Numplex.C64)

@[extern "faermat_mat_of_row_array_c64"]
private opaque ofRowArrayC64 :
    UInt64 -> UInt64 -> @& Array Numplex.C64 -> Option (Matrix Numplex.C64)

@[extern "faermat_mat_zeros_c64"]
private opaque zerosC64 : UInt64 -> UInt64 -> Matrix Numplex.C64

@[extern "faermat_mat_identity_c64"]
private opaque identityC64 : UInt64 -> Matrix Numplex.C64

@[extern "faermat_mat_full_c64"]
private opaque fullC64 :
    UInt64 -> UInt64 -> @& Numplex.C64 -> Matrix Numplex.C64

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_mat_nrows_c64"]
private opaque nrowsC64 : @& Matrix Numplex.C64 -> UInt64

@[extern "faermat_mat_ncols_c64"]
private opaque ncolsC64 : @& Matrix Numplex.C64 -> UInt64

@[extern "faermat_mat_get_c64"]
private opaque getC64 : @& Matrix Numplex.C64 -> UInt64 -> UInt64 -> Numplex.C64

@[extern "faermat_mat_to_array_c64"]
private opaque toArrayC64 : @& Matrix Numplex.C64 -> Array Numplex.C64

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_mat_add_c64"]
private opaque addC64 :
    @& Matrix Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_sub_c64"]
private opaque subC64 :
    @& Matrix Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_mul_c64"]
private opaque mulC64 :
    @& Matrix Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_scale_c64"]
private opaque scaleC64 :
    @& Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_transpose_c64"]
private opaque transposeC64 : @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_neg_c64"]
private opaque negC64 : @& Matrix Numplex.C64 -> Matrix Numplex.C64

/- * Views --------------------------------------------------------------------/

@[extern "faermat_mat_submatrix_c64"]
private opaque submatrixC64 :
    @& Matrix Numplex.C64 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    Option (Matrix Numplex.C64)

@[extern "faermat_mat_row_c64"]
private opaque rowC64 :
    @& Matrix Numplex.C64 -> UInt64 -> Option (Matrix Numplex.C64)

@[extern "faermat_mat_col_c64"]
private opaque colC64 :
    @& Matrix Numplex.C64 -> UInt64 -> Option (Matrix Numplex.C64)

@[extern "faermat_mat_materialize_c64"]
private opaque materializeC64 : @& Matrix Numplex.C64 -> Matrix Numplex.C64

/- * Diagonal -----------------------------------------------------------------/

@[extern "faermat_mat_diag_c64"]
private opaque diagC64 : @& Matrix Numplex.C64 -> Array Numplex.C64

@[extern "faermat_mat_from_diag_c64"]
private opaque fromDiagC64 : @& Array Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_trace_c64"]
private opaque traceC64 : @& Matrix Numplex.C64 -> Numplex.C64

/- * Norm / Adjoint -----------------------------------------------------------/

@[extern "faermat_mat_set_c64"]
private opaque setC64 :
    Matrix Numplex.C64 ->
    UInt64 ->
    UInt64 ->
    @& Numplex.C64 ->
    Matrix Numplex.C64

@[extern "faermat_mat_kron_c64"]
private opaque kronC64 :
    @& Matrix Numplex.C64 -> @& Matrix Numplex.C64 -> Matrix Numplex.C64

@[extern "faermat_mat_reshape_c64"]
private opaque reshapeC64 :
    Matrix Numplex.C64 -> UInt64 -> UInt64 -> Option (Matrix Numplex.C64)

@[extern "faermat_mat_norm_c64"]
private opaque normC64 : @& Matrix Numplex.C64 -> Float

@[extern "faermat_mat_adjoint_c64"]
private opaque adjointC64 : @& Matrix Numplex.C64 -> Matrix Numplex.C64

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_mat_to_string_c64"]
private opaque toStringC64 : @& Matrix Numplex.C64 -> String

@[extern "faermat_mat_fmt_c64"]
private opaque fmtC64 :
    @& Matrix Numplex.C64 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_lower_exp_c64"]
private opaque fmtLowerExpC64 :
    @& Matrix Numplex.C64 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_upper_exp_c64"]
private opaque fmtUpperExpC64 :
    @& Matrix Numplex.C64 ->
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

@[extern "faermat_mat_of_array_c32"]
private opaque ofArrayC32 :
    UInt64 -> UInt64 -> @& Array Numplex.C32 -> Option (Matrix Numplex.C32)

@[extern "faermat_mat_of_row_array_c32"]
private opaque ofRowArrayC32 :
    UInt64 -> UInt64 -> @& Array Numplex.C32 -> Option (Matrix Numplex.C32)

@[extern "faermat_mat_zeros_c32"]
private opaque zerosC32 : UInt64 -> UInt64 -> Matrix Numplex.C32

@[extern "faermat_mat_identity_c32"]
private opaque identityC32 : UInt64 -> Matrix Numplex.C32

@[extern "faermat_mat_full_c32"]
private opaque fullC32 :
    UInt64 -> UInt64 -> @& Numplex.C32 -> Matrix Numplex.C32

/- * Inspection ---------------------------------------------------------------/

@[extern "faermat_mat_nrows_c32"]
private opaque nrowsC32 : @& Matrix Numplex.C32 -> UInt64

@[extern "faermat_mat_ncols_c32"]
private opaque ncolsC32 : @& Matrix Numplex.C32 -> UInt64

@[extern "faermat_mat_get_c32"]
private opaque getC32 : @& Matrix Numplex.C32 -> UInt64 -> UInt64 -> Numplex.C32

@[extern "faermat_mat_to_array_c32"]
private opaque toArrayC32 : @& Matrix Numplex.C32 -> Array Numplex.C32

/- * Arithmetic ---------------------------------------------------------------/

@[extern "faermat_mat_add_c32"]
private opaque addC32 :
    @& Matrix Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_sub_c32"]
private opaque subC32 :
    @& Matrix Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_mul_c32"]
private opaque mulC32 :
    @& Matrix Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_scale_c32"]
private opaque scaleC32 :
    @& Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_transpose_c32"]
private opaque transposeC32 : @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_neg_c32"]
private opaque negC32 : @& Matrix Numplex.C32 -> Matrix Numplex.C32

/- * Views --------------------------------------------------------------------/

@[extern "faermat_mat_submatrix_c32"]
private opaque submatrixC32 :
    @& Matrix Numplex.C32 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    UInt64 ->
    Option (Matrix Numplex.C32)

@[extern "faermat_mat_row_c32"]
private opaque rowC32 :
    @& Matrix Numplex.C32 -> UInt64 -> Option (Matrix Numplex.C32)

@[extern "faermat_mat_col_c32"]
private opaque colC32 :
    @& Matrix Numplex.C32 -> UInt64 -> Option (Matrix Numplex.C32)

@[extern "faermat_mat_materialize_c32"]
private opaque materializeC32 : @& Matrix Numplex.C32 -> Matrix Numplex.C32

/- * Diagonal -----------------------------------------------------------------/

@[extern "faermat_mat_diag_c32"]
private opaque diagC32 : @& Matrix Numplex.C32 -> Array Numplex.C32

@[extern "faermat_mat_from_diag_c32"]
private opaque fromDiagC32 : @& Array Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_trace_c32"]
private opaque traceC32 : @& Matrix Numplex.C32 -> Numplex.C32

/- * Norm / Adjoint -----------------------------------------------------------/

@[extern "faermat_mat_set_c32"]
private opaque setC32 :
    Matrix Numplex.C32 ->
    UInt64 ->
    UInt64 ->
    @& Numplex.C32 ->
    Matrix Numplex.C32

@[extern "faermat_mat_kron_c32"]
private opaque kronC32 :
    @& Matrix Numplex.C32 -> @& Matrix Numplex.C32 -> Matrix Numplex.C32

@[extern "faermat_mat_reshape_c32"]
private opaque reshapeC32 :
    Matrix Numplex.C32 -> UInt64 -> UInt64 -> Option (Matrix Numplex.C32)

@[extern "faermat_mat_norm_c32"]
private opaque normC32 : @& Matrix Numplex.C32 -> Float32

@[extern "faermat_mat_adjoint_c32"]
private opaque adjointC32 : @& Matrix Numplex.C32 -> Matrix Numplex.C32

/- * Formatting ---------------------------------------------------------------/

@[extern "faermat_mat_to_string_c32"]
private opaque toStringC32 : @& Matrix Numplex.C32 -> String

@[extern "faermat_mat_fmt_c32"]
private opaque fmtC32 :
    @& Matrix Numplex.C32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_lower_exp_c32"]
private opaque fmtLowerExpC32 :
    @& Matrix Numplex.C32 ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

@[extern "faermat_mat_fmt_upper_exp_c32"]
private opaque fmtUpperExpC32 :
    @& Matrix Numplex.C32 ->
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
Typeclass dispatching matrix operations to the appropriate scalar-type-specific
FFI backend. Instances exist for `Float`, `Float32`, `Numplex.C64`, and
`Numplex.C32`.
-/
class Ops (a : Type) where
  ofArray : UInt64 -> UInt64 -> Array a -> Option (Matrix a)
  ofRowArray : UInt64 -> UInt64 -> Array a -> Option (Matrix a)
  zeros : UInt64 -> UInt64 -> Matrix a
  identity : UInt64 -> Matrix a
  full : UInt64 -> UInt64 -> a -> Matrix a
  nrows : Matrix a -> UInt64
  ncols : Matrix a -> UInt64
  get : Matrix a -> UInt64 -> UInt64 -> a
  toArray : Matrix a -> Array a
  add : Matrix a -> Matrix a -> Matrix a
  sub : Matrix a -> Matrix a -> Matrix a
  mul : Matrix a -> Matrix a -> Matrix a
  scale : a -> Matrix a -> Matrix a
  transpose : Matrix a -> Matrix a
  neg : Matrix a -> Matrix a
  submatrix :
    Matrix a -> UInt64 -> UInt64 -> UInt64 -> UInt64 -> Option (Matrix a)
  row : Matrix a -> UInt64 -> Option (Matrix a)
  col : Matrix a -> UInt64 -> Option (Matrix a)
  materialize : Matrix a -> Matrix a
  diag : Matrix a -> Array a
  fromDiag : Array a -> Matrix a
  trace : Matrix a -> a
  adjoint : Matrix a -> Matrix a
  set : Matrix a -> UInt64 -> UInt64 -> a -> Matrix a
  kron : Matrix a -> Matrix a -> Matrix a
  reshape : Matrix a -> UInt64 -> UInt64 -> Option (Matrix a)
  toString : Matrix a -> String
  fmt :
    Matrix a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String
  fmtLowerExp :
    Matrix a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String
  fmtUpperExp :
    Matrix a ->
    Int64 ->
    Int64 ->
    UInt32 ->
    Int64 ->
    UInt8 ->
    UInt8 ->
    UInt8 ->
    String

instance : Ops Float where
  ofArray nr nc data := ofArrayF64 nr nc data
  ofRowArray nr nc data := ofRowArrayF64 nr nc data
  zeros nr nc := zerosF64 nr nc
  identity n := identityF64 n
  full nr nc v := fullF64 nr nc v
  nrows m := nrowsF64 m
  ncols m := ncolsF64 m
  get m i j := getF64 m i j
  toArray m := toArrayF64 m
  add a b := addF64 a b
  sub a b := subF64 a b
  mul a b := mulF64 a b
  scale s m := scaleF64 s m
  transpose m := transposeF64 m
  neg m := negF64 m
  submatrix m rs cs nr nc := submatrixF64 m rs cs nr nc
  row m i := rowF64 m i
  col m j := colF64 m j
  materialize m := materializeF64 m
  diag m := diagF64 m
  fromDiag data := fromDiagF64 data
  trace m := traceF64 m
  adjoint m := adjointF64 m
  set m i j v := setF64 m i j v
  kron a b := kronF64 a b
  reshape m nr nc := reshapeF64 m nr nc
  toString m := toStringF64 m
  fmt m p w f al sp alt zp := fmtF64 m p w f al sp alt zp
  fmtLowerExp m p w f al sp alt zp := fmtLowerExpF64 m p w f al sp alt zp
  fmtUpperExp m p w f al sp alt zp := fmtUpperExpF64 m p w f al sp alt zp

instance : Ops Float32 where
  ofArray nr nc data := ofArrayF32 nr nc data
  ofRowArray nr nc data := ofRowArrayF32 nr nc data
  zeros nr nc := zerosF32 nr nc
  identity n := identityF32 n
  full nr nc v := fullF32 nr nc v
  nrows m := nrowsF32 m
  ncols m := ncolsF32 m
  get m i j := getF32 m i j
  toArray m := toArrayF32 m
  add a b := addF32 a b
  sub a b := subF32 a b
  mul a b := mulF32 a b
  scale s m := scaleF32 s m
  transpose m := transposeF32 m
  neg m := negF32 m
  submatrix m rs cs nr nc := submatrixF32 m rs cs nr nc
  row m i := rowF32 m i
  col m j := colF32 m j
  materialize m := materializeF32 m
  diag m := diagF32 m
  fromDiag data := fromDiagF32 data
  trace m := traceF32 m
  adjoint m := adjointF32 m
  set m i j v := setF32 m i j v
  kron a b := kronF32 a b
  reshape m nr nc := reshapeF32 m nr nc
  toString m := toStringF32 m
  fmt m p w f al sp alt zp := fmtF32 m p w f al sp alt zp
  fmtLowerExp m p w f al sp alt zp := fmtLowerExpF32 m p w f al sp alt zp
  fmtUpperExp m p w f al sp alt zp := fmtUpperExpF32 m p w f al sp alt zp

instance : Ops Numplex.C64 where
  ofArray nr nc data := ofArrayC64 nr nc data
  ofRowArray nr nc data := ofRowArrayC64 nr nc data
  zeros nr nc := zerosC64 nr nc
  identity n := identityC64 n
  full nr nc v := fullC64 nr nc v
  nrows m := nrowsC64 m
  ncols m := ncolsC64 m
  get m i j := getC64 m i j
  toArray m := toArrayC64 m
  add a b := addC64 a b
  sub a b := subC64 a b
  mul a b := mulC64 a b
  scale s m := scaleC64 s m
  transpose m := transposeC64 m
  neg m := negC64 m
  submatrix m rs cs nr nc := submatrixC64 m rs cs nr nc
  row m i := rowC64 m i
  col m j := colC64 m j
  materialize m := materializeC64 m
  diag m := diagC64 m
  fromDiag data := fromDiagC64 data
  trace m := traceC64 m
  adjoint m := adjointC64 m
  set m i j v := setC64 m i j v
  kron a b := kronC64 a b
  reshape m nr nc := reshapeC64 m nr nc
  toString m := toStringC64 m
  fmt m p w f al sp alt zp := fmtC64 m p w f al sp alt zp
  fmtLowerExp m p w f al sp alt zp := fmtLowerExpC64 m p w f al sp alt zp
  fmtUpperExp m p w f al sp alt zp := fmtUpperExpC64 m p w f al sp alt zp

instance : Ops Numplex.C32 where
  ofArray nr nc data := ofArrayC32 nr nc data
  ofRowArray nr nc data := ofRowArrayC32 nr nc data
  zeros nr nc := zerosC32 nr nc
  identity n := identityC32 n
  full nr nc v := fullC32 nr nc v
  nrows m := nrowsC32 m
  ncols m := ncolsC32 m
  get m i j := getC32 m i j
  toArray m := toArrayC32 m
  add a b := addC32 a b
  sub a b := subC32 a b
  mul a b := mulC32 a b
  scale s m := scaleC32 s m
  transpose m := transposeC32 m
  neg m := negC32 m
  submatrix m rs cs nr nc := submatrixC32 m rs cs nr nc
  row m i := rowC32 m i
  col m j := colC32 m j
  materialize m := materializeC32 m
  diag m := diagC32 m
  fromDiag data := fromDiagC32 data
  trace m := traceC32 m
  adjoint m := adjointC32 m
  set m i j v := setC32 m i j v
  kron a b := kronC32 a b
  reshape m nr nc := reshapeC32 m nr nc
  toString m := toStringC32 m
  fmt m p w f al sp alt zp := fmtC32 m p w f al sp alt zp
  fmtLowerExp m p w f al sp alt zp := fmtLowerExpC32 m p w f al sp alt zp
  fmtUpperExp m p w f al sp alt zp := fmtUpperExpC32 m p w f al sp alt zp

/- Public API -----------------------------------------------------------------/

/--
Create a matrix from a flat column-major array. Returns `none` if `data.size !=
nrows * ncols`.
-/
def ofArray [Ops a] (nrows ncols : Nat) (data : Array a) : Option (Matrix a) :=
  Ops.ofArray nrows.toUInt64 ncols.toUInt64 data

/--
Create a matrix from a flat row-major array. Returns `none` if
`data.size != nrows * ncols`.
-/
def ofRowArray [Ops a] (nrows ncols : Nat) (data : Array a) :
    Option (Matrix a) :=
  Ops.ofRowArray nrows.toUInt64 ncols.toUInt64 data

/--
Create a matrix from a function `f i j` mapping row and column indices to
elements.
-/
def fromFn [Ops a] (nrows ncols : Nat) (f : Nat -> Nat -> a) :
    Matrix a :=
  let data := Id.run do
    let mut arr := Array.mkEmpty (nrows * ncols)
    for j in 0 ... ncols do
      for i in 0 ... nrows do
        arr := arr.push (f i j)
    return arr
  match Ops.ofArray nrows.toUInt64 ncols.toUInt64 data with
  | some m => m
  | none => Ops.zeros nrows.toUInt64 ncols.toUInt64 -- unreachable

/--
Create a matrix of zeros.
-/
def zeros [Ops a] (nrows ncols : Nat) : Matrix a :=
  Ops.zeros nrows.toUInt64 ncols.toUInt64

/--
Create an identity matrix.
-/
def identity [Ops a] (n : Nat) : Matrix a :=
  Ops.identity n.toUInt64

/--
Create a matrix filled with a constant value.
-/
def full [Ops a] (nrows ncols : Nat) (v : a) : Matrix a :=
  Ops.full nrows.toUInt64 ncols.toUInt64 v

/--
Number of rows.
-/
def nrows [Ops a] (m : Matrix a) : Nat :=
  (Ops.nrows m).toNat

/--
Number of columns.
-/
def ncols [Ops a] (m : Matrix a) : Nat :=
  (Ops.ncols m).toNat

/--
Matrix dimensions.
-/
def shape [Ops a] (m : Matrix a) : Nat × Nat :=
  (m.nrows, m.ncols)

/--
Get the element at row `i`, column `j`.
-/
def get? [Ops a] (m : Matrix a) (i j : Nat) : Option a :=
  if i < m.nrows && j < m.ncols then
    some (Ops.get m i.toUInt64 j.toUInt64)
  else
    none

/--
Extract to a flat column-major array.
-/
def toArray [Ops a] (m : Matrix a) : Array a :=
  Ops.toArray m

/--
Transpose the matrix.
-/
def transpose [Ops a] (m : Matrix a) : Matrix a :=
  Ops.transpose m

/--
Scale every element by a scalar.
-/
def scale [Ops a] (s : a) (m : Matrix a) : Matrix a :=
  Ops.scale s m

/--
Extract a submatrix view (zero-copy). Returns `none` if the region is out of
bounds.
-/
def submatrix [Ops a] (m : Matrix a) (rowStart colStart nrows ncols : Nat) :
    Option (Matrix a) :=
  Ops.submatrix m
    rowStart.toUInt64
    colStart.toUInt64
    nrows.toUInt64
    ncols.toUInt64

/--
Extract row `i` as a 1-by-ncols matrix view. Returns `none` if out of bounds.
-/
def row [Ops a] (m : Matrix a) (i : Nat) : Option (Matrix a) :=
  Ops.row m i.toUInt64

/--
Extract column `j` as an nrows-by-1 matrix view. Returns `none` if out of
bounds.
-/
def col [Ops a] (m : Matrix a) (j : Nat) : Option (Matrix a) :=
  Ops.col m j.toUInt64

/--
Force a view into a contiguous owned copy.
-/
def materialize [Ops a] (m : Matrix a) : Matrix a :=
  Ops.materialize m

/--
Extract the diagonal as a flat array.
-/
def diag [Ops a] (m : Matrix a) : Array a :=
  Ops.diag m

/--
Create a diagonal matrix from a flat array.
-/
def fromDiag [Ops a] (data : Array a) : Matrix a :=
  Ops.fromDiag data

/--
Trace (sum of diagonal elements).
-/
def trace [Ops a] (m : Matrix a) : a :=
  Ops.trace m

/--
L2 (Frobenius) norm. Returns the real scalar type associated with `a`.
-/
class HasNorm (a : Type) (r : outParam Type) where
  normI : Matrix a -> r

instance : HasNorm Float Float where
  normI m := normF64 m
instance : HasNorm Float32 Float32 where
  normI m := normF32 m
instance : HasNorm Numplex.C64 Float where
  normI m := normC64 m
instance : HasNorm Numplex.C32 Float32 where
  normI m := normC32 m

def norm [HasNorm a r] (m : Matrix a) : r :=
  HasNorm.normI m

/--
Adjoint (conjugate transpose). For real types, this is the same as `transpose`.
-/
def adjoint [Ops a] (m : Matrix a) : Matrix a :=
  Ops.adjoint m

/--
Set the element at row `i`, column `j`, returning a new matrix. Mutates in
place when the reference count allows. Panics if out of bounds.
-/
def set [Ops a] (m : Matrix a) (i j : Nat) (v : a) : Matrix a :=
  Ops.set m i.toUInt64 j.toUInt64 v

/--
Set the element at row `i`, column `j`, returning `none` if out of bounds.
-/
def set? [Ops a] (m : Matrix a) (i j : Nat) (v : a) : Option (Matrix a) :=
  if i < m.nrows && j < m.ncols then some (m.set i j v) else none

/--
Kronecker product of two matrices.
-/
def kron [Ops a] (a' b : Matrix a) : Matrix a :=
  Ops.kron a' b

/--
Reshape a matrix to new dimensions, preserving column-major element order.
Returns `none` if `nrows * ncols` differs from the original total element
count.
-/
def reshape [Ops a] (m : Matrix a) (nrows ncols : Nat) : Option (Matrix a) :=
  Ops.reshape m nrows.toUInt64 ncols.toUInt64

/--
Check whether a matrix is square (runtime).
-/
def isSquare [Ops a] (m : Matrix a) : Bool :=
  m.nrows == m.ncols

/--
Proposition that a matrix is square (for use in axiom hypotheses).
-/
def IsSquare [Ops a] (m : Matrix a) : Prop :=
  m.nrows = m.ncols

instance [Ops a] (m : Matrix a) : Decidable (IsSquare m) :=
  inferInstanceAs (Decidable (m.nrows = m.ncols))

/--
Matrix power by natural number exponent via binary exponentiation.
-/
/- * GetElem instances --------------------------------------------------------/

instance [Ops a] :
    GetElem (Matrix a) (Nat × Nat) a
    (fun m (i, j) => i < m.nrows ∧ j < m.ncols)
where
  getElem m ij _ :=
    let (i, j) := ij
    Ops.get m i.toUInt64 j.toUInt64

instance [Ops a] :
    GetElem? (Matrix a) (Nat × Nat) a
    (fun m (i, j) => i < m.nrows ∧ j < m.ncols)
where
  getElem? m ij :=
    let (i, j) := ij
    m.get? i j

/- * Operator instances -------------------------------------------------------/

instance [Ops a] : Add (Matrix a) where
  add := Ops.add

instance [Ops a] : Sub (Matrix a) where
  sub := Ops.sub

instance [Ops a] : Neg (Matrix a) where
  neg := Ops.neg

instance [Ops a] : HMul (Matrix a) (Matrix a) (Matrix a) where
  hMul := Ops.mul

instance [Ops a] : HMul a (Matrix a) (Matrix a) where
  hMul := Ops.scale

instance [Ops a] : HMul (Matrix a) a (Matrix a) where
  hMul mat s := s * mat

/--
Matrix power by natural number exponent via binary exponentiation.
-/
def powm [Ops a] (m : Matrix a) : Nat -> Matrix a
  | 0 => Matrix.identity m.nrows
  | 1 => m
  | n + 2 =>
    let half := powm m ((n + 2) / 2)
    if (n + 2) % 2 == 0 then
      half * half
    else
      half * half * m

instance [Ops a] : HPow (Matrix a) Nat (Matrix a) where
  hPow := Matrix.powm

/- * Formatting instances -----------------------------------------------------/

instance [Ops a] : ToString (Matrix a) where
  toString m := Ops.toString m

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

instance [Ops a] : Fmtl.Display (Matrix a) where
  fmt m spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmt m p w f al sp alt zp

instance [Ops a] : Fmtl.LowerExp (Matrix a) where
  fmt m spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmtLowerExp m p w f al sp alt zp

instance [Ops a] : Fmtl.UpperExp (Matrix a) where
  fmt m spec :=
    let (p, w, f, al, sp, alt, zp) := fmtSpec spec
    Ops.fmtUpperExp m p w f al sp alt zp

instance : Coe (Matrix Float) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Matrix Float32) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Matrix Numplex.C64) (Fmtl.FmtArg .display) := Fmtl.Display.coe
instance : Coe (Matrix Numplex.C32) (Fmtl.FmtArg .display) := Fmtl.Display.coe

instance : Coe (Matrix Float) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Matrix Float32) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Matrix Numplex.C64) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe
instance : Coe (Matrix Numplex.C32) (Fmtl.FmtArg .lowerExp) := Fmtl.LowerExp.coe

instance : Coe (Matrix Float) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Matrix Float32) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Matrix Numplex.C64) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe
instance : Coe (Matrix Numplex.C32) (Fmtl.FmtArg .upperExp) := Fmtl.UpperExp.coe

end Matrix
end Faermat
