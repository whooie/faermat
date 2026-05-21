import Numplex

namespace Faermat

/--
Typeclass for scalar types supported by Faermat. Instances exist for `Float`,
`Float32`, `C64`, `C32`.
-/
class FaerScalar (a : Type) where
  /--
  Tag value used internally for FFI dispatch.
    - 0 = Float
    - 1 = Float32
    - 2 = C64
    - 3 = C32
  -/
  tag : UInt8

instance : FaerScalar Float where
  tag := 0

instance : FaerScalar Float32 where
  tag := 1

instance : FaerScalar Numplex.C64 where
  tag := 2

instance : FaerScalar Numplex.C32 where
  tag := 3

end Faermat
