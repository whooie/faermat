use std::ffi::c_void;
use std::sync::{Arc, OnceLock};

use faer::mat::AsMatRef;
use faer::prelude::ReborrowMut;
use faer::{Mat, MatRef};

use crate::lean::*;
use crate::scalar::FaerScalar;

/* Inner type *****************************************************************/

pub enum MatrixInner<T> {
    Owned(Arc<Mat<T>>),
    View {
        parent: Arc<Mat<T>>,
        row_start: usize,
        col_start: usize,
        nrows: usize,
        ncols: usize,
    },
}

impl<T> MatrixInner<T>
where T: FaerScalar
{
    pub fn as_ref(&self) -> MatRef<'_, T> {
        match self {
            MatrixInner::Owned(m) => m.as_mat_ref(),
            MatrixInner::View {
                parent,
                row_start,
                col_start,
                nrows,
                ncols,
            } => {
                parent
                .as_mat_ref()
                .submatrix(*row_start, *col_start, *nrows, *ncols)
            },
        }
    }

    pub fn nrows(&self) -> usize {
        match self {
            MatrixInner::Owned(m) => m.nrows(),
            MatrixInner::View { nrows, .. } => *nrows,
        }
    }

    pub fn ncols(&self) -> usize {
        match self {
            MatrixInner::Owned(m) => m.ncols(),
            MatrixInner::View { ncols, .. } => *ncols,
        }
    }
}

/* Per-scalar-type class registration *****************************************/

macro_rules! matrix_class {
    (
        $T:ty,
        $suffix:ident,
        $Wrapper:ident,
        $LOCK:ident,
        $finalize:ident,
        $foreach:ident,
        $get_class:ident
    ) => {
        struct $Wrapper(*mut LeanExternalClass);
        unsafe impl Send for $Wrapper {}
        unsafe impl Sync for $Wrapper {}
        static $LOCK: OnceLock<$Wrapper> = OnceLock::new();

        unsafe extern "C" fn $finalize(ptr: *mut c_void) {
            drop(Box::from_raw(ptr as *mut MatrixInner<$T>));
        }
        unsafe extern "C" fn $foreach(
            _ptr: *mut c_void,
            _child: BLeanObjArg,
        ) {}

        fn $get_class() -> *mut LeanExternalClass {
            $LOCK
                .get_or_init(|| unsafe {
                    $Wrapper(
                        lean_register_external_class(
                            Some($finalize),
                            Some($foreach),
                        )
                    )
                }).0
        }

        paste::paste!(
            pub unsafe fn [<wrap_ $suffix>](m: Mat<$T>) -> LeanObjRes {
                let inner = MatrixInner::Owned(Arc::new(m));
                let boxed = Box::into_raw(Box::new(inner));
                faermat_lean_alloc_external($get_class(), boxed as *mut c_void)
            }

            unsafe fn [<wrap_inner_ $suffix>](inner: MatrixInner<$T>)
                -> LeanObjRes
            {
                let boxed = Box::into_raw(Box::new(inner));
                faermat_lean_alloc_external($get_class(), boxed as *mut c_void)
            }

            pub unsafe fn [<unwrap_ $suffix>](o: BLeanObjArg)
                -> &'static MatrixInner<$T>
            {
                let ptr = faermat_lean_get_external_data(o);
                &*(ptr as *const MatrixInner<$T>)
            }
        );
    };
}

/* Boxed scalar FFI ***********************************************************/

macro_rules! matrix_ffi_boxed {
    ($T:ty, $suffix:ident) => { paste::paste!(
        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_of_array_ $suffix>](
            nrows: u64,
            ncols: u64,
            data: BLeanObjArg,
        ) -> LeanObjRes
        {
            let nr = nrows as usize;
            let nc = ncols as usize;
            let vals = <$T as FaerScalar>::array_to_vec(data);
            if vals.len() != nr * nc { return mk_option_none(); }
            let mat = Mat::from_fn(nr, nc, |i, j| vals[j * nr + i]);
            mk_option_some([<wrap_ $suffix>](mat))
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_of_row_array_ $suffix>](
            nrows: u64,
            ncols: u64,
            data: BLeanObjArg,
        ) -> LeanObjRes
        {
            let nr = nrows as usize;
            let nc = ncols as usize;
            let vals = <$T as FaerScalar>::array_to_vec(data);
            if vals.len() != nr * nc { return mk_option_none(); }
            let mat = Mat::from_fn(nr, nc, |i, j| vals[i * nc + j]);
            mk_option_some([<wrap_ $suffix>](mat))
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_zeros_ $suffix>](
            nrows: u64,
            ncols: u64,
        ) -> LeanObjRes
        {
            [<wrap_ $suffix>](Mat::<$T>::zeros(nrows as usize, ncols as usize))
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_identity_ $suffix>](n: u64)
            -> LeanObjRes
        {
            let n = n as usize;
            let mat: Mat<$T> = Mat::identity(n, n);
            [<wrap_ $suffix>](mat)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_full_ $suffix>](
            nrows: u64,
            ncols: u64,
            val: BLeanObjArg,
        ) -> LeanObjRes
        {
            let v = <$T as FaerScalar>::unbox_scalar(val);
            let mat = Mat::full(nrows as usize, ncols as usize, v);
            [<wrap_ $suffix>](mat)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_nrows_ $suffix>](m: BLeanObjArg)
            -> u64
        {
            [<unwrap_ $suffix>](m).nrows() as u64
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_ncols_ $suffix>](m: BLeanObjArg)
            -> u64
        {
            [<unwrap_ $suffix>](m).ncols() as u64
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_get_ $suffix>](
            m: BLeanObjArg,
            i: u64,
            j: u64,
        ) -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            <$T as FaerScalar>::box_scalar(r[(i as usize, j as usize)])
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_to_array_ $suffix>](
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            let nr = r.nrows();
            let nc = r.ncols();
            let mut vals = Vec::with_capacity(nr * nc);
            for j in 0 .. nc {
                for i in 0 .. nr {
                    vals.push(r[(i, j)]);
                }
            }
            <$T as FaerScalar>::vec_to_array(&vals)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_submatrix_ $suffix>](
            m: BLeanObjArg,
            row_start: u64,
            col_start: u64,
            nrows: u64,
            ncols: u64,
        ) -> LeanObjRes
        {
            let inner = [<unwrap_ $suffix>](m);
            let rs = row_start as usize;
            let cs = col_start as usize;
            let nr = nrows as usize;
            let nc = ncols as usize;
            if rs + nr > inner.nrows() || cs + nc > inner.ncols() {
                return mk_option_none();
            }
            let (parent, abs_rs, abs_cs) = match inner {
                MatrixInner::Owned(arc) => (Arc::clone(arc), rs, cs),
                MatrixInner::View {
                    parent,
                    row_start: prs,
                    col_start: pcs,
                    ..
                } => (Arc::clone(parent), prs + rs, pcs + cs),
            };
            mk_option_some(
                [<wrap_inner_ $suffix>](
                    MatrixInner::View {
                        parent,
                        row_start: abs_rs,
                        col_start: abs_cs,
                        nrows: nr,
                        ncols: nc,
                    }
                )
            )
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_row_ $suffix>](
            m: BLeanObjArg,
            i: u64,
        ) -> LeanObjRes
        {
            let inner = [<unwrap_ $suffix>](m);
            let row = i as usize;
            if row >= inner.nrows() { return mk_option_none(); }
            let nc = inner.ncols();
            let (parent, abs_r, abs_c) = match inner {
                MatrixInner::Owned(arc) => (Arc::clone(arc), row, 0),
                MatrixInner::View { parent, row_start, col_start, .. } =>
                    (Arc::clone(parent), row_start + row, *col_start),
            };
            mk_option_some(
                [<wrap_inner_ $suffix>](
                    MatrixInner::View {
                        parent,
                        row_start: abs_r,
                        col_start: abs_c,
                        nrows: 1,
                        ncols: nc,
                    }
                )
            )
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_col_ $suffix>](
            m: BLeanObjArg,
            j: u64,
        ) -> LeanObjRes
        {
            let inner = [<unwrap_ $suffix>](m);
            let col = j as usize;
            if col >= inner.ncols() { return mk_option_none(); }
            let nr = inner.nrows();
            let (parent, abs_r, abs_c) = match inner {
                MatrixInner::Owned(arc) => (Arc::clone(arc), 0, col),
                MatrixInner::View { parent, row_start, col_start, .. } =>
                    (Arc::clone(parent), *row_start, col_start + col),
            };
            mk_option_some(
                [<wrap_inner_ $suffix>](
                    MatrixInner::View {
                        parent,
                        row_start: abs_r,
                        col_start: abs_c,
                        nrows: nr,
                        ncols: 1,
                    },
                )
            )
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_materialize_ $suffix>](
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            [<wrap_ $suffix>](r.to_owned())
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_add_ $suffix>](
            a: BLeanObjArg,
            b: BLeanObjArg,
        ) -> LeanObjRes
        {
            let ra = [<unwrap_ $suffix>](a).as_ref();
            let rb = [<unwrap_ $suffix>](b).as_ref();
            if ra.nrows() != rb.nrows() || ra.ncols() != rb.ncols() {
                let msg = c"Matrix.add: dimension mismatch";
                lean_internal_panic(msg.as_ptr());
            }
            [<wrap_ $suffix>](ra + rb)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_sub_ $suffix>](
            a: BLeanObjArg,
            b: BLeanObjArg,
        ) -> LeanObjRes
        {
            let ra = [<unwrap_ $suffix>](a).as_ref();
            let rb = [<unwrap_ $suffix>](b).as_ref();
            if ra.nrows() != rb.nrows() || ra.ncols() != rb.ncols() {
                let msg = c"Matrix.sub: dimension mismatch";
                lean_internal_panic(msg.as_ptr());
            }
            [<wrap_ $suffix>](ra - rb)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_mul_ $suffix>](
            a: BLeanObjArg,
            b: BLeanObjArg,
        ) -> LeanObjRes
        {
            let ra = [<unwrap_ $suffix>](a).as_ref();
            let rb = [<unwrap_ $suffix>](b).as_ref();
            if ra.ncols() != rb.nrows() {
                let msg = c"Matrix.mul: dimension mismatch";
                lean_internal_panic(msg.as_ptr());
            }
            [<wrap_ $suffix>](ra * rb)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_scale_ $suffix>](
            s: BLeanObjArg,
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let sv = <$T as FaerScalar>::unbox_scalar(s);
            let r = [<unwrap_ $suffix>](m).as_ref();
            [<wrap_ $suffix>](faer::Scale(sv) * r)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_transpose_ $suffix>](
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            [<wrap_ $suffix>](r.transpose().to_owned())
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_neg_ $suffix>](m: BLeanObjArg)
            -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            [<wrap_ $suffix>](-r)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_diag_ $suffix>](m: BLeanObjArg)
            -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            let n = r.nrows().min(r.ncols());
            let mut vals = Vec::with_capacity(n);
            for k in 0..n {
                vals.push(r[(k, k)]);
            }
            <$T as FaerScalar>::vec_to_array(&vals)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_from_diag_ $suffix>](
            data: BLeanObjArg,
        ) -> LeanObjRes
        {
            let vals = <$T as FaerScalar>::array_to_vec(data);
            let n = vals.len();
            let mut mat: Mat<$T> = Mat::zeros(n, n);
            mat.diagonal_mut()
                .column_vector_mut()
                .iter_mut()
                .zip(vals)
                .for_each(|(elem, v)| { *elem = v; });
            [<wrap_ $suffix>](mat)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_trace_ $suffix>](
            m: BLeanObjArg,
        ) -> LeanObjRes
        {
            let r = [<unwrap_ $suffix>](m).as_ref();
            let n = r.nrows().min(r.ncols());
            let mut sum = <$T as faer_traits::ComplexField>::zero_impl();
            for k in 0..n { sum += r[(k, k)]; }
            <$T as FaerScalar>::box_scalar(sum)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_kron_ $suffix>](
            a: BLeanObjArg,
            b: BLeanObjArg,
        ) -> LeanObjRes
        {
            let ra = [<unwrap_ $suffix>](a).as_ref();
            let rb = [<unwrap_ $suffix>](b).as_ref();
            let mr = ra.nrows() * rb.nrows();
            let mc = ra.ncols() * rb.ncols();
            let mut result: Mat<$T> = Mat::zeros(mr, mc);
            faer::linalg::kron::kron(
                result.as_mut(),
                ra,
                rb,
            );
            [<wrap_ $suffix>](result)
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_reshape_ $suffix>](
            m: LeanObjArg,
            new_nrows: u64,
            new_ncols: u64,
        ) -> LeanObjRes
        {
            let new_nr = new_nrows as usize;
            let new_nc = new_ncols as usize;
            let inner = [<unwrap_ $suffix>](m);
            let old_nr = inner.nrows();
            let old_nc = inner.ncols();
            if old_nr * old_nc != new_nr * new_nc {
                return mk_option_none();
            }
            let can_reinterpret = if faermat_lean_is_exclusive(m) {
                match inner {
                    MatrixInner::Owned(arc)
                        if Arc::strong_count(arc) == 1 =>
                    {
                        let r = arc.as_mat_ref();
                        r.col_stride() == old_nr as isize
                    }
                    _ => false,
                }
            } else {
                false
            };
            let result = if can_reinterpret {
                let r = inner.as_ref();
                let ptr = r.as_ptr();
                let reshaped = MatRef::<$T>::from_raw_parts(
                    ptr,
                    new_nr,
                    new_nc,
                    1,
                    new_nr as isize,
                );
                reshaped.to_owned()
            } else {
                reshape_copy(
                    inner.as_ref(), old_nr, new_nr, new_nc,
                )
            };
            mk_option_some([<wrap_ $suffix>](result))
        }

        #[no_mangle]
        pub unsafe extern "C" fn [<faermat_mat_set_ $suffix>](
            m: LeanObjArg,
            i: u64,
            j: u64,
            val: BLeanObjArg,
        ) -> LeanObjRes
        {
            let ii = i as usize;
            let jj = j as usize;
            let scalar =
                <$T as FaerScalar>::unbox_scalar(val);
            if faermat_lean_is_exclusive(m) {
                let ptr =
                    faermat_lean_get_external_data(m);
                let inner = &mut *(ptr
                    as *mut MatrixInner<$T>);
                match inner {
                    MatrixInner::Owned(arc)
                        if Arc::strong_count(arc) == 1 =>
                    {
                        Arc::get_mut(arc).unwrap()
                            [(ii, jj)] = scalar;
                    }
                    _ => {
                        let mut mat =
                            inner.as_ref().to_owned();
                        mat[(ii, jj)] = scalar;
                        *inner = MatrixInner::Owned(
                            Arc::new(mat),
                        );
                    }
                }
                m
            } else {
                let inner = [<unwrap_ $suffix>](m);
                let mut mat =
                    inner.as_ref().to_owned();
                mat[(ii, jj)] = scalar;
                faermat_lean_dec(m);
                [<wrap_ $suffix>](mat)
            }
        }
    ); }
}

/* f64 class + FFI ************************************************************/
// f64 (Lean's Float) is unboxed at the ABI level: scalars pass as
// raw C doubles, not as boxed Lean objects. This means functions
// like get, full, scale, set, and trace have different C signatures
// from the boxed-scalar versions generated by matrix_ffi_boxed! for
// f32/c64/c32. Because of this, f64 FFI functions are written out
// manually rather than generated by the macro.

matrix_class!(
    f64,
    f64,
    MatF64Ptr,
    MAT_CLASS_F64,
    finalize_mat_f64,
    foreach_mat_f64,
    get_mat_class_f64
);

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_of_row_array_f64(
    nrows: u64,
    ncols: u64,
    data: BLeanObjArg,
) -> LeanObjRes
{
    let nr = nrows as usize;
    let nc = ncols as usize;
    let vals = array_float_to_vec(data);
    if vals.len() != nr * nc { return mk_option_none(); }
    let mat = Mat::from_fn(nr, nc, |i, j| vals[i * nc + j]);
    mk_option_some(wrap_f64(mat))
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_of_array_f64(
    nrows: u64,
    ncols: u64,
    data: BLeanObjArg,
) -> LeanObjRes
{
    let nr = nrows as usize;
    let nc = ncols as usize;
    let vals = array_float_to_vec(data);
    if vals.len() != nr * nc { return mk_option_none(); }
    let mat = Mat::from_fn(nr, nc, |i, j| vals[j * nr + i]);
    mk_option_some(wrap_f64(mat))
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_zeros_f64(nrows: u64, ncols: u64)
    -> LeanObjRes
{
    wrap_f64(Mat::zeros(nrows as usize, ncols as usize))
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_identity_f64(n: u64) -> LeanObjRes {
    let n = n as usize;
    let mat: Mat<f64> = Mat::identity(n, n);
    wrap_f64(mat)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_full_f64(nrows: u64, ncols: u64, val: f64)
    -> LeanObjRes
{
    let mat: Mat<f64> = Mat::full(nrows as usize, ncols as usize, val);
    wrap_f64(mat)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_nrows_f64(m: BLeanObjArg) -> u64 {
    unwrap_f64(m).nrows() as u64
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_ncols_f64(m: BLeanObjArg) -> u64 {
    unwrap_f64(m).ncols() as u64
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_get_f64(m: BLeanObjArg, i: u64, j: u64)
    -> f64
{
    let r = unwrap_f64(m).as_ref();
    r[(i as usize, j as usize)]
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_to_array_f64(m: BLeanObjArg)
    -> LeanObjRes
{
    let r = unwrap_f64(m).as_ref();
    let nr = r.nrows();
    let nc = r.ncols();
    let mut vals = Vec::with_capacity(nr * nc);
    for j in 0..nc {
        for i in 0..nr {
            vals.push(r[(i, j)]);
        }
    }
    vec_to_array_float(&vals)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_submatrix_f64(
    m: BLeanObjArg,
    row_start: u64,
    col_start: u64,
    nrows: u64,
    ncols: u64,
) -> LeanObjRes
{
    let inner = unwrap_f64(m);
    let rs = row_start as usize;
    let cs = col_start as usize;
    let nr = nrows as usize;
    let nc = ncols as usize;
    if rs + nr > inner.nrows() || cs + nc > inner.ncols() {
        return mk_option_none();
    }
    let (parent, abs_rs, abs_cs) = match inner {
        MatrixInner::Owned(arc) => (Arc::clone(arc), rs, cs),
        MatrixInner::View { parent, row_start: prs, col_start: pcs, .. } =>
            (Arc::clone(parent), prs + rs, pcs + cs),
    };
    mk_option_some(
        wrap_inner_f64(
            MatrixInner::View {
                parent,
                row_start: abs_rs,
                col_start: abs_cs,
                nrows: nr,
                ncols: nc,
            }
        )
    )
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_row_f64(m: BLeanObjArg, i: u64)
    -> LeanObjRes
{
    let inner = unwrap_f64(m);
    let row = i as usize;
    if row >= inner.nrows() { return mk_option_none(); }
    let nc = inner.ncols();
    let (parent, abs_r, abs_c) = match inner {
        MatrixInner::Owned(arc) => (Arc::clone(arc), row, 0),
        MatrixInner::View { parent, row_start, col_start, .. } =>
            (Arc::clone(parent), row_start + row, *col_start),
    };
    mk_option_some(
        wrap_inner_f64(
            MatrixInner::View {
                parent,
                row_start: abs_r,
                col_start: abs_c,
                nrows: 1,
                ncols: nc,
            }
        )
    )
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_col_f64(m: BLeanObjArg, j: u64)
    -> LeanObjRes
{
    let inner = unwrap_f64(m);
    let col = j as usize;
    if col >= inner.ncols() { return mk_option_none(); }
    let nr = inner.nrows();
    let (parent, abs_r, abs_c) = match inner {
        MatrixInner::Owned(arc) => (Arc::clone(arc), 0, col),
        MatrixInner::View { parent, row_start, col_start, .. } =>
            (Arc::clone(parent), *row_start, col_start + col),
    };
    mk_option_some(
        wrap_inner_f64(
            MatrixInner::View {
                parent,
                row_start: abs_r,
                col_start: abs_c,
                nrows: nr,
                ncols: 1,
            }
        )
    )
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_materialize_f64(m: BLeanObjArg)
    -> LeanObjRes
{
    let r = unwrap_f64(m).as_ref();
    wrap_f64(r.to_owned())
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_add_f64(a: BLeanObjArg, b: BLeanObjArg)
    -> LeanObjRes
{
    let ra = unwrap_f64(a).as_ref();
    let rb = unwrap_f64(b).as_ref();
    if ra.nrows() != rb.nrows() || ra.ncols() != rb.ncols() {
        let msg = c"Matrix.add: dimension mismatch";
        lean_internal_panic(msg.as_ptr());
    }
    wrap_f64(ra + rb)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_sub_f64(a: BLeanObjArg, b: BLeanObjArg)
    -> LeanObjRes
{
    let ra = unwrap_f64(a).as_ref();
    let rb = unwrap_f64(b).as_ref();
    if ra.nrows() != rb.nrows() || ra.ncols() != rb.ncols() {
        let msg = c"Matrix.sub: dimension mismatch";
        lean_internal_panic(msg.as_ptr());
    }
    wrap_f64(ra - rb)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_mul_f64(a: BLeanObjArg, b: BLeanObjArg)
    -> LeanObjRes
{
    let ra = unwrap_f64(a).as_ref();
    let rb = unwrap_f64(b).as_ref();
    if ra.ncols() != rb.nrows() {
        let msg = c"Matrix.mul: dimension mismatch";
        lean_internal_panic(msg.as_ptr());
    }
    wrap_f64(ra * rb)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_scale_f64(s: f64, m: BLeanObjArg)
    -> LeanObjRes
{
    let r = unwrap_f64(m).as_ref();
    wrap_f64(faer::Scale(s) * r)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_transpose_f64(m: BLeanObjArg)
    -> LeanObjRes
{
    let r = unwrap_f64(m).as_ref();
    wrap_f64(r.transpose().to_owned())
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_neg_f64(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_f64(m).as_ref();
    wrap_f64(-r)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_diag_f64(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_f64(m).as_ref();
    let n = r.nrows().min(r.ncols());
    let mut vals = Vec::with_capacity(n);
    for k in 0 .. n { vals.push(r[(k, k)]); }
    vec_to_array_float(&vals)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_from_diag_f64(data: BLeanObjArg)
    -> LeanObjRes
{
    let vals = array_float_to_vec(data);
    let n = vals.len();
    let mut mat: Mat<f64> = Mat::zeros(n, n);
    mat.diagonal_mut()
        .column_vector_mut()
        .iter_mut()
        .zip(vals)
        .for_each(|(elem, v)| { *elem = v; });
    wrap_f64(mat)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_trace_f64(m: BLeanObjArg) -> f64 {
    let r = unwrap_f64(m).as_ref();
    let n = r.nrows().min(r.ncols());
    let mut sum = 0.0;
    for k in 0 .. n { sum += r[(k, k)]; }
    sum
}

/* Element set ****************************************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_set_f64(
    m: LeanObjArg, i: u64, j: u64, val: f64,
) -> LeanObjRes
{
    let ii = i as usize;
    let jj = j as usize;
    if faermat_lean_is_exclusive(m) {
        let ptr = faermat_lean_get_external_data(m);
        let inner = &mut *(ptr as *mut MatrixInner<f64>);
        match inner {
            MatrixInner::Owned(arc)
                if Arc::strong_count(arc) == 1 =>
            {
                Arc::get_mut(arc).unwrap()[(ii, jj)] = val;
            }
            _ => {
                let mut mat = inner.as_ref().to_owned();
                mat[(ii, jj)] = val;
                *inner =
                    MatrixInner::Owned(Arc::new(mat));
            }
        }
        m
    } else {
        let inner = unwrap_f64(m);
        let mut mat = inner.as_ref().to_owned();
        mat[(ii, jj)] = val;
        faermat_lean_dec(m);
        wrap_f64(mat)
    }
}

/* Kronecker product **********************************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_kron_f64(
    a: BLeanObjArg,
    b: BLeanObjArg,
) -> LeanObjRes
{
    let ra = unwrap_f64(a).as_ref();
    let rb = unwrap_f64(b).as_ref();
    let mr = ra.nrows() * rb.nrows();
    let mc = ra.ncols() * rb.ncols();
    let mut result: Mat<f64> = Mat::zeros(mr, mc);
    faer::linalg::kron::kron(result.as_mut(), ra, rb);
    wrap_f64(result)
}

/* Reshape ********************************************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_reshape_f64(
    m: LeanObjArg,
    new_nrows: u64,
    new_ncols: u64,
) -> LeanObjRes
{
    let new_nr = new_nrows as usize;
    let new_nc = new_ncols as usize;
    let inner = unwrap_f64(m);
    let old_nr = inner.nrows();
    let old_nc = inner.ncols();
    if old_nr * old_nc != new_nr * new_nc {
        return mk_option_none();
    }
    let can_reinterpret = if faermat_lean_is_exclusive(m) {
        match inner {
            MatrixInner::Owned(arc)
                if Arc::strong_count(arc) == 1 =>
            {
                let r = arc.as_mat_ref();
                r.col_stride() == old_nr as isize
            }
            _ => false,
        }
    } else {
        false
    };
    let result = if can_reinterpret {
        let r = inner.as_ref();
        let ptr = r.as_ptr();
        let reshaped = MatRef::<f64>::from_raw_parts(
            ptr,
            new_nr,
            new_nc,
            1,
            new_nr as isize,
        );
        reshaped.to_owned()
    } else {
        reshape_copy(inner.as_ref(), old_nr, new_nr, new_nc)
    };
    mk_option_some(wrap_f64(result))
}

/// Column-wise staggered copy for reshape.
fn reshape_copy<T>(
    src: MatRef<'_, T>,
    old_nr: usize,
    new_nr: usize,
    new_nc: usize,
) -> Mat<T>
where
    T: faer_traits::ComplexField + Copy,
{
    let mut dst: Mat<T> = Mat::zeros(new_nr, new_nc);
    {
        let mut src_cols = src.col_iter();
        let mut dst_cols = dst.as_mut().col_iter_mut();
        let mut src_col = src_cols.next().unwrap();
        let mut dst_col = dst_cols.next().unwrap();
        let mut si = 0usize;
        let mut di = 0usize;
        loop {
            let src_rem = old_nr - si;
            let dst_rem = new_nr - di;
            let chunk = src_rem.min(dst_rem);
            if chunk == 0 { break; }
            dst_col.rb_mut().subrows_mut(di, chunk)
                .copy_from(src_col.subrows(si, chunk));
            si += chunk;
            di += chunk;
            if si == old_nr {
                si = 0;
                match src_cols.next() {
                    Some(c) => src_col = c,
                    None => break,
                }
            }
            if di == new_nr {
                di = 0;
                match dst_cols.next() {
                    Some(c) => dst_col = c,
                    None => break,
                }
            }
        }
    }
    dst
}

/* f32, c64, c32 **************************************************************/

matrix_class!(
    f32,
    f32,
    MatF32Ptr,
    MAT_CLASS_F32,
    finalize_mat_f32,
    foreach_mat_f32,
    get_mat_class_f32
);
matrix_ffi_boxed!(f32, f32);

matrix_class!(
    num_complex::Complex<f64>,
    c64,
    MatC64Ptr,
    MAT_CLASS_C64,
    finalize_mat_c64,
    foreach_mat_c64,
    get_mat_class_c64
);
matrix_ffi_boxed!(num_complex::Complex<f64>, c64);

matrix_class!(
    num_complex::Complex<f32>,
    c32,
    MatC32Ptr,
    MAT_CLASS_C32,
    finalize_mat_c32,
    foreach_mat_c32,
    get_mat_class_c32
);
matrix_ffi_boxed!(num_complex::Complex<f32>, c32);

/* L2 norm ********************************************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_norm_f64(m: BLeanObjArg) -> f64 {
    unwrap_f64(m).as_ref().norm_l2()
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_norm_f32(m: BLeanObjArg) -> LeanObjRes {
    let n: f32 = unwrap_f32(m).as_ref().norm_l2();
    faermat_lean_box_float32(n)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_norm_c64(m: BLeanObjArg) -> f64 {
    unwrap_c64(m).as_ref().norm_l2()
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_norm_c32(m: BLeanObjArg) -> LeanObjRes {
    let n: f32 = unwrap_c32(m).as_ref().norm_l2();
    faermat_lean_box_float32(n)
}

/* Adjoint ********************************************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_adjoint_f64(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_f64(m).as_ref();
    wrap_f64(r.transpose().to_owned())
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_adjoint_f32(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_f32(m).as_ref();
    wrap_f32(r.transpose().to_owned())
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_adjoint_c64(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_c64(m).as_ref();
    let adj = r.adjoint().to_owned();
    wrap_c64(adj)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_adjoint_c32(m: BLeanObjArg) -> LeanObjRes {
    let r = unwrap_c32(m).as_ref();
    let adj = r.adjoint().to_owned();
    wrap_c32(adj)
}

/* fromRealDiag for complex elems *********************************************/

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_from_real_diag_c64(data: BLeanObjArg)
    -> LeanObjRes
{
    let vals = array_float_to_vec(data);
    let n = vals.len();
    let mut mat: Mat<num_complex::Complex<f64>> = Mat::zeros(n, n);
    mat.diagonal_mut()
        .column_vector_mut()
        .iter_mut()
        .zip(vals)
        .for_each(|(elem, v)| { elem.re = v; });
    wrap_c64(mat)
}

#[no_mangle]
pub unsafe extern "C" fn faermat_mat_from_real_diag_c32(data: BLeanObjArg)
    -> LeanObjRes
{
    let vals = array_float32_to_vec(data);
    let n = vals.len();
    let mut mat: Mat<num_complex::Complex<f32>> = Mat::zeros(n, n);
    mat.diagonal_mut()
        .column_vector_mut()
        .iter_mut()
        .zip(vals)
        .for_each(|(elem, v)| { elem.re = v; });
    wrap_c32(mat)
}
