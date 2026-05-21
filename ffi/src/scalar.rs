use crate::lean::*;

/// Trait abstracting scalar-type-specific operations
/// needed by the FFI layer.
pub trait FaerScalar: faer_traits::ComplexField + Copy + 'static {
    /// Extract a Lean Array of this scalar into a Vec.
    unsafe fn array_to_vec(a: BLeanObjArg) -> Vec<Self>;

    /// Convert a Vec of this scalar into a Lean Array.
    unsafe fn vec_to_array(v: &[Self]) -> LeanObjRes;

    /// Box a single scalar value for Lean.
    unsafe fn box_scalar(v: Self) -> LeanObjRes;

    /// Unbox a single scalar value from Lean.
    unsafe fn unbox_scalar(o: BLeanObjArg) -> Self;

    /// Format a single element as a string. Handles precision, sign_plus, and
    /// alternate. Width/fill/align/zero_pad are handled at the matrix/vector
    /// level for column alignment.
    fn fmt_elem(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String;

    /// Format using lowercase scientific notation.
    fn fmt_elem_lower_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String;

    /// Format using uppercase scientific notation.
    fn fmt_elem_upper_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String;
}

/// Format a real scalar using the content spec fields.
fn fmt_real<F>(
    v: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::Display
{
    match (precision, sign_plus, alternate) {
        (Some(p), true, true) => format!("{v:+#.p$}"),
        (Some(p), true, false) => format!("{v:+.p$}"),
        (Some(p), false, true) => format!("{v:#.p$}"),
        (Some(p), false, false) => format!("{v:.p$}"),
        (None, true, true) => format!("{v:+#}"),
        (None, true, false) => format!("{v:+}"),
        (None, false, true) => format!("{v:#}"),
        (None, false, false) => format!("{v}"),
    }
}

/// Format a real scalar in lowercase scientific notation.
fn fmt_real_lower_exp<F>(
    v: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::LowerExp
{
    match (precision, sign_plus, alternate) {
        (Some(p), true, true) => format!("{v:+#.p$e}"),
        (Some(p), true, false) => format!("{v:+.p$e}"),
        (Some(p), false, true) => format!("{v:#.p$e}"),
        (Some(p), false, false) => format!("{v:.p$e}"),
        (None, true, true) => format!("{v:+#e}"),
        (None, true, false) => format!("{v:+e}"),
        (None, false, true) => format!("{v:#e}"),
        (None, false, false) => format!("{v:e}"),
    }
}

/// Format a real scalar in uppercase scientific notation.
fn fmt_real_upper_exp<F>(
    v: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::UpperExp
{
    match (precision, sign_plus, alternate) {
        (Some(p), true, true) => format!("{v:+#.p$E}"),
        (Some(p), true, false) => format!("{v:+.p$E}"),
        (Some(p), false, true) => format!("{v:#.p$E}"),
        (Some(p), false, false) => format!("{v:.p$E}"),
        (None, true, true) => format!("{v:+#E}"),
        (None, true, false) => format!("{v:+E}"),
        (None, false, true) => format!("{v:#E}"),
        (None, false, false) => format!("{v:E}"),
    }
}

impl FaerScalar for f64 {
    unsafe fn array_to_vec(a: BLeanObjArg) -> Vec<Self> {
        array_float_to_vec(a)
    }

    unsafe fn vec_to_array(v: &[Self]) -> LeanObjRes {
        vec_to_array_float(v)
    }

    unsafe fn box_scalar(v: Self) -> LeanObjRes {
        faermat_lean_box_float(v)
    }

    unsafe fn unbox_scalar(o: BLeanObjArg) -> Self {
        faermat_lean_unbox_float(o)
    }

    fn fmt_elem(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_real(v, precision, sign_plus, alternate)
    }

    fn fmt_elem_lower_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_real_lower_exp(v, precision, sign_plus, alternate)
    }

    fn fmt_elem_upper_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_real_upper_exp(v, precision, sign_plus, alternate)
    }
}

impl FaerScalar for f32 {
    unsafe fn array_to_vec(a: BLeanObjArg) -> Vec<Self> {
        array_float32_to_vec(a)
    }

    unsafe fn vec_to_array(v: &[Self]) -> LeanObjRes {
        vec_to_array_float32(v)
    }

    unsafe fn box_scalar(v: Self) -> LeanObjRes {
        faermat_lean_box_float32(v)
    }

    unsafe fn unbox_scalar(o: BLeanObjArg) -> Self {
        faermat_lean_unbox_float32(o)
    }

    fn fmt_elem(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_real(v, precision, sign_plus, alternate)
    }

    fn fmt_elem_lower_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_real_lower_exp(v, precision, sign_plus, alternate)
    }

    fn fmt_elem_upper_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String {
        fmt_real_upper_exp(v, precision, sign_plus, alternate)
    }
}

/// Normalize negative zero to positive zero.
fn norm_neg_zero<F>(v: F) -> F
where F: PartialOrd + Default + Copy,
{
    if v == F::default() { F::default() } else { v }
}

/// Format a complex number as `<re>+<im>i` or `<re>-<im>i`. Negative zero in
/// the imaginary part is normalized to positive zero so that we get `+0i`
/// rather than `-0i`.
fn fmt_complex<F>(
    re: F,
    im: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::Display + PartialOrd + Default + Copy,
{
    let re_s = fmt_real(re, precision, sign_plus, alternate);
    let im_s = fmt_real(norm_neg_zero(im), precision, true, alternate);
    format!("{re_s}{im_s}i")
}

/// Format a complex number in lowercase scientific notation.
fn fmt_complex_lower_exp<F>(
    re: F,
    im: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::LowerExp + PartialOrd + Default + Copy,
{
    let re_s = fmt_real_lower_exp(re, precision, sign_plus, alternate);
    let im_s =
        fmt_real_lower_exp(norm_neg_zero(im), precision, true, alternate);
    format!("{re_s}{im_s}i")
}

/// Format a complex number in uppercase scientific notation.
fn fmt_complex_upper_exp<F>(
    re: F,
    im: F,
    precision: Option<usize>,
    sign_plus: bool,
    alternate: bool,
) -> String
where F: std::fmt::UpperExp + PartialOrd + Default + Copy,
{
    let re_s = fmt_real_upper_exp(re, precision, sign_plus, alternate);
    let im_s =
        fmt_real_upper_exp(norm_neg_zero(im), precision, true, alternate);
    format!("{re_s}{im_s}i")
}

impl FaerScalar for num_complex::Complex<f64> {
    unsafe fn array_to_vec(a: BLeanObjArg) -> Vec<Self> {
        array_complex_f64_to_vec(a)
    }

    unsafe fn vec_to_array(v: &[Self]) -> LeanObjRes {
        vec_to_array_complex_f64(v)
    }

    unsafe fn box_scalar(v: Self) -> LeanObjRes {
        box_complex_f64(v)
    }

    unsafe fn unbox_scalar(o: BLeanObjArg) -> Self {
        unbox_complex_f64(o)
    }

    fn fmt_elem(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex(v.re, v.im, precision, sign_plus, alternate)
    }

    fn fmt_elem_lower_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex_lower_exp(v.re, v.im, precision, sign_plus, alternate)
    }

    fn fmt_elem_upper_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex_upper_exp(v.re, v.im, precision, sign_plus, alternate)
    }
}

impl FaerScalar for num_complex::Complex<f32> {
    unsafe fn array_to_vec(a: BLeanObjArg) -> Vec<Self> {
        array_complex_f32_to_vec(a)
    }

    unsafe fn vec_to_array(v: &[Self]) -> LeanObjRes {
        vec_to_array_complex_f32(v)
    }

    unsafe fn box_scalar(v: Self) -> LeanObjRes {
        box_complex_f32(v)
    }

    unsafe fn unbox_scalar(o: BLeanObjArg) -> Self {
        unbox_complex_f32(o)
    }

    fn fmt_elem(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex(v.re, v.im, precision, sign_plus, alternate)
    }

    fn fmt_elem_lower_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex_lower_exp(v.re, v.im, precision, sign_plus, alternate)
    }

    fn fmt_elem_upper_exp(
        v: Self,
        precision: Option<usize>,
        sign_plus: bool,
        alternate: bool,
    ) -> String
    {
        fmt_complex_upper_exp(v.re, v.im, precision, sign_plus, alternate)
    }
}
