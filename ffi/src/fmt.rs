use crate::lean::*;
use crate::scalar::FaerScalar;

/// Pad a string to a target width using the given fill char and alignment.
fn pad(s: &str, w: usize, fill_ch: char, align: i64) -> String {
    let slen = s.len();
    if slen >= w { return s.to_string(); }
    let diff = w - slen;
    match align {
        1 => {
            // left
            let mut out = s.to_string();
            for _ in 0..diff { out.push(fill_ch); }
            out
        }
        2 => {
            // center
            let left = diff / 2;
            let right = diff - left;
            let mut out = String::with_capacity(w);
            for _ in 0..left { out.push(fill_ch); }
            out.push_str(s);
            for _ in 0..right { out.push(fill_ch); }
            out
        }
        _ => {
            // right (default for numbers)
            let mut out = String::with_capacity(w);
            for _ in 0..diff { out.push(fill_ch); }
            out.push_str(s);
            out
        }
    }
}

/// Element formatter function type.
type ElemFmt<T> = fn(T, Option<usize>, bool, bool) -> String;

/// Format a matrix as a column-aligned bracketed string, using the given
/// per-element formatter.
fn fmt_matrix_with<T>(
    mat: faer::MatRef<'_, T>,
    elem_fmt: ElemFmt<T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    _zero_pad: bool,
) -> String
where T: FaerScalar
{
    let nr = mat.nrows();
    let nc = mat.ncols();
    if nr == 0 || nc == 0 { return "[\n]".to_string(); }
    let prec =
        if precision >= 0 {
            Some(precision as usize)
        } else {
            None
        };
    let min_width =
        if width >= 0 { width as usize } else { 0 };
    let mut formatted: Vec<Vec<String>> = Vec::with_capacity(nr);
    let mut col_widths: Vec<usize> = vec![min_width; nc];
    for matrow in mat.row_iter() {
        let mut row = Vec::with_capacity(nc);
        for (&elem, width) in matrow.iter().zip(col_widths.iter_mut()) {
            let fmtstr = elem_fmt(elem, prec, sign_plus, alternate);
            *width = (*width).max(fmtstr.len());
            row.push(fmtstr);
        }
        formatted.push(row);
    }

    // determine fill char and alignment
    let fill_ch = char::from_u32(fill).unwrap_or(' ');
    // 0 = none -> default right for numbers
    let actual_align = if align == 0 { 3 } else { align };

    let mut out = String::from("[\n");
    for (i, row) in formatted.into_iter().enumerate() {
        out.push('[');
        let iter = row.into_iter().zip(col_widths.iter()).enumerate();
        for (j, (elem, &width)) in iter {
            out.push_str(&pad(&elem, width, fill_ch, actual_align));
            if j + 1 < nc { out.push_str(", "); }
        }
        out.push(']');
        if i + 1 < nr { out.push(','); }
        out.push('\n');
    }
    out.push(']');
    out
}

/// Format a matrix using Display formatting.
fn fmt_matrix<T>(
    mat: faer::MatRef<'_, T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_matrix_with(
        mat,
        T::fmt_elem,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/// Format a matrix using lowercase exp notation.
fn fmt_matrix_lower_exp<T>(
    mat: faer::MatRef<'_, T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_matrix_with(
        mat,
        T::fmt_elem_lower_exp,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/// Format a matrix using uppercase exp notation.
fn fmt_matrix_upper_exp<T>(
    mat: faer::MatRef<'_, T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_matrix_with(
        mat,
        T::fmt_elem_upper_exp,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/// Format a vector as a single-line bracketed string, using the given
/// per-element formatter.
fn fmt_vector_with<T>(
    col: &faer::Col<T>,
    elem_fmt: ElemFmt<T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    _zero_pad: bool,
) -> String
where T: FaerScalar
{
    let n = col.nrows();
    if n == 0 { return "[]".to_string(); }
    let prec = if precision >= 0 {
        Some(precision as usize)
    } else {
        None
    };
    let formatted: Vec<String> =
        (0..n)
        .map(|i| elem_fmt(col[i], prec, sign_plus, alternate))
        .collect();

    let fill_ch = char::from_u32(fill).unwrap_or(' ');
    let actual_align = if align == 0 { 3 } else { align };
    let min_width =
        if width >= 0 { width as usize } else { 0 };

    let mut out = String::from("[");
    for (k, s) in formatted.iter().enumerate() {
        out.push_str(&pad(s, min_width, fill_ch, actual_align));
        if k + 1 < n { out.push_str(", "); }
    }
    out.push(']');
    out
}

/// Format a vector using Display formatting.
fn fmt_vector<T>(
    col: &faer::Col<T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_vector_with(
        col,
        T::fmt_elem,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/// Format a vector using lowercase exp notation.
fn fmt_vector_lower_exp<T>(
    col: &faer::Col<T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_vector_with(
        col,
        T::fmt_elem_lower_exp,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/// Format a vector using uppercase exp notation.
fn fmt_vector_upper_exp<T>(
    col: &faer::Col<T>,
    precision: i64,
    width: i64,
    fill: u32,
    align: i64,
    sign_plus: bool,
    alternate: bool,
    zero_pad: bool,
) -> String
where T: FaerScalar
{
    fmt_vector_with(
        col,
        T::fmt_elem_upper_exp,
        precision,
        width,
        fill,
        align,
        sign_plus,
        alternate,
        zero_pad,
    )
}

/* FFI wrappers for all scalar types ******************************************/

macro_rules! fmt_ffi {
    (
        $suffix:ident,
        $T:ty,
        $unwrap_mat:path,
        $unwrap_vec:path
    ) => { paste::paste!(
        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_fmt_ $suffix>](
            m: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let r = $unwrap_mat(m).as_ref();
            let s = fmt_matrix::<$T>(
                r,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_to_string_ $suffix>](
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let r = $unwrap_mat(m).as_ref();
            let s = fmt_matrix::<$T>(
                r,
                -1,
                -1,
                ' ' as u32,
                0,
                false,
                false,
                false,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_fmt_lower_exp_ $suffix>](
            m: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let r = $unwrap_mat(m).as_ref();
            let s = fmt_matrix_lower_exp::<$T>(
                r,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_fmt_upper_exp_ $suffix>](
            m: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let r = $unwrap_mat(m).as_ref();
            let s = fmt_matrix_upper_exp::<$T>(
                r,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_vec_fmt_ $suffix>](
            v: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let col = $unwrap_vec(v);
            let s = fmt_vector::<$T>(
                col,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_vec_to_string_ $suffix>](
            v: BLeanObjArg,
        ) -> LeanObjRes
        {
            let col = $unwrap_vec(v);
            let s = fmt_vector::<$T>(
                col,
                -1,
                -1,
                ' ' as u32, 0,
                false,
                false,
                false,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_vec_fmt_lower_exp_ $suffix>](
            v: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let col = $unwrap_vec(v);
            let s = fmt_vector_lower_exp::<$T>(
                col,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_vec_fmt_upper_exp_ $suffix>](
            v: BLeanObjArg,
            precision: i64,
            width: i64,
            fill: u32,
            align: i64,
            sign_plus: u8,
            alternate: u8,
            zero_pad: u8,
        ) -> LeanObjRes
        {
            let col = $unwrap_vec(v);
            let s = fmt_vector_upper_exp::<$T>(
                col,
                precision,
                width,
                fill,
                align,
                sign_plus != 0,
                alternate != 0,
                zero_pad != 0,
            );
            mk_string(&s)
        }

    ); }
}

fmt_ffi!(f64, f64, crate::matrix::unwrap_f64, crate::vector::unwrap_f64);
fmt_ffi!(f32, f32, crate::matrix::unwrap_f32, crate::vector::unwrap_f32);
fmt_ffi!(
    c64,
    num_complex::Complex<f64>,
    crate::matrix::unwrap_c64,
    crate::vector::unwrap_c64
);
fmt_ffi!(
    c32,
    num_complex::Complex<f32>,
    crate::matrix::unwrap_c32,
    crate::vector::unwrap_c32
);
