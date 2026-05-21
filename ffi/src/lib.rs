#![allow(clippy::missing_safety_doc, clippy::too_many_arguments)]

// Lean C API bindings (wrappers for inline functions compiled via shim.c)
pub mod lean {
    use std::ffi::c_void;

    #[repr(C)]
    pub struct LeanObject {
        _private: [u8; 0],
    }

    pub type LeanObjArg = *mut LeanObject;
    pub type BLeanObjArg = *mut LeanObject;
    pub type LeanObjRes = *mut LeanObject;

    #[repr(C)]
    pub struct LeanExternalClass {
        _private: [u8; 0],
    }

    pub type FinalizeFn = Option<unsafe extern "C" fn(*mut c_void)>;
    pub type ForeachFn = Option<unsafe extern "C" fn(*mut c_void, BLeanObjArg)>;

    extern "C" {
        // Exported by Lean runtime
        pub fn lean_register_external_class(
            finalize: FinalizeFn,
            foreach: ForeachFn,
        ) -> *mut LeanExternalClass;

        pub fn lean_mk_string_from_bytes(s: *const u8, sz: usize) -> LeanObjRes;

        pub fn lean_internal_panic(msg: *const i8) -> !;

        // Shim wrappers (from shim.c)
        pub fn faermat_lean_alloc_external(
            cls: *mut LeanExternalClass,
            data: *mut c_void,
        ) -> LeanObjRes;

        pub fn faermat_lean_get_external_data(o: LeanObjArg) -> *mut c_void;

        pub fn faermat_lean_box(n: usize) -> LeanObjRes;

        #[allow(dead_code)]
        pub fn faermat_lean_unbox(o: BLeanObjArg) -> usize;

        pub fn faermat_lean_box_float(v: f64) -> LeanObjRes;

        pub fn faermat_lean_unbox_float(o: BLeanObjArg) -> f64;

        pub fn faermat_lean_array_size(o: BLeanObjArg) -> usize;

        pub fn faermat_lean_array_get_core(o: BLeanObjArg, i: usize)
            -> BLeanObjArg;

        pub fn faermat_lean_mk_empty_array_with_capacity(cap: LeanObjArg)
            -> LeanObjRes;

        pub fn faermat_lean_array_push(a: LeanObjArg, v: LeanObjArg)
            -> LeanObjRes;

        pub fn faermat_lean_io_result_mk_ok(a: LeanObjArg) -> LeanObjRes;

        pub fn faermat_lean_inc(o: LeanObjArg);
        pub fn faermat_lean_dec(o: LeanObjArg);

        pub fn faermat_lean_alloc_ctor(tag: u32, num_objs: u32, scalar_sz: u32)
            -> LeanObjRes;

        pub fn faermat_lean_ctor_set(o: BLeanObjArg, i: u32, v: LeanObjArg);

        pub fn faermat_lean_ctor_get(o: BLeanObjArg, i: u32) -> BLeanObjArg;

        pub fn faermat_lean_box_float32(v: f32) -> LeanObjRes;

        pub fn faermat_lean_unbox_float32(o: BLeanObjArg) -> f32;

        pub fn faermat_lean_is_exclusive(o: LeanObjArg) -> bool;
    }

    // create a Lean string from a Rust &str
    pub unsafe fn mk_string(s: &str) -> LeanObjRes {
        lean_mk_string_from_bytes(s.as_ptr(), s.len())
    }

    // create Lean Option.some(v)
    pub unsafe fn mk_option_some(v: LeanObjArg) -> LeanObjRes {
        let r = faermat_lean_alloc_ctor(1, 1, 0);
        faermat_lean_ctor_set(r, 0, v);
        r
    }

    // create Lean Option.none
    pub unsafe fn mk_option_none() -> LeanObjRes {
        faermat_lean_alloc_ctor(0, 0, 0)
    }

    // extract Array Float into Vec<f64>
    pub unsafe fn array_float_to_vec(a: BLeanObjArg) -> Vec<f64> {
        let n = faermat_lean_array_size(a);
        let mut v = Vec::with_capacity(n);
        for i in 0 .. n {
            let elem = faermat_lean_array_get_core(a, i);
            v.push(faermat_lean_unbox_float(elem));
        }
        v
    }

    // Vec<f64> into Lean Array Float
    pub unsafe fn vec_to_array_float(v: &[f64]) -> LeanObjRes {
        let cap = faermat_lean_box(v.len());
        let mut arr = faermat_lean_mk_empty_array_with_capacity(cap);
        for &x in v {
            let elem = faermat_lean_box_float(x);
            arr = faermat_lean_array_push(arr, elem);
        }
        arr
    }

    // extract Array Float32 into Vec<f32>
    pub unsafe fn array_float32_to_vec(a: BLeanObjArg) -> Vec<f32> {
        let n = faermat_lean_array_size(a);
        let mut v = Vec::with_capacity(n);
        for i in 0 .. n {
            let elem = faermat_lean_array_get_core(a, i);
            v.push(faermat_lean_unbox_float32(elem));
        }
        v
    }

    // Vec<f32> into Lean Array Float32
    pub unsafe fn vec_to_array_float32(v: &[f32]) -> LeanObjRes {
        let cap = faermat_lean_box(v.len());
        let mut arr = faermat_lean_mk_empty_array_with_capacity(cap);
        for &x in v {
            let elem = faermat_lean_box_float32(x);
            arr = faermat_lean_array_push(arr, elem);
        }
        arr
    }

    // extract Complex from a Lean ctor {re, im}
    // for C64: fields are boxed Float (f64)
    pub unsafe fn unbox_complex_f64(o: BLeanObjArg)
        -> num_complex::Complex<f64>
    {
        let re = faermat_lean_unbox_float(faermat_lean_ctor_get(o, 0));
        let im = faermat_lean_unbox_float(faermat_lean_ctor_get(o, 1));
        num_complex::Complex::new(re, im)
    }

    // box a Complex<f64> into Lean ctor {re, im}
    pub unsafe fn box_complex_f64(c: num_complex::Complex<f64>) -> LeanObjRes {
        let r = faermat_lean_alloc_ctor(0, 2, 0);
        faermat_lean_ctor_set(r, 0, faermat_lean_box_float(c.re));
        faermat_lean_ctor_set(r, 1, faermat_lean_box_float(c.im));
        r
    }

    // extract Array C64 into Vec<Complex<f64>>
    pub unsafe fn array_complex_f64_to_vec(a: BLeanObjArg)
        -> Vec<num_complex::Complex<f64>>
    {
        let n = faermat_lean_array_size(a);
        let mut v = Vec::with_capacity(n);
        for i in 0 .. n {
            let elem = faermat_lean_array_get_core(a, i);
            v.push(unbox_complex_f64(elem));
        }
        v
    }

    // Vec<Complex<f64>> into Lean Array C64
    pub unsafe fn vec_to_array_complex_f64(v: &[num_complex::Complex<f64>])
        -> LeanObjRes
    {
        let cap = faermat_lean_box(v.len());
        let mut arr = faermat_lean_mk_empty_array_with_capacity(cap);
        for &x in v {
            arr = faermat_lean_array_push(arr, box_complex_f64(x));
        }
        arr
    }

    // extract Complex<f32> from Lean ctor
    pub unsafe fn unbox_complex_f32(o: BLeanObjArg)
        -> num_complex::Complex<f32>
    {
        let re = faermat_lean_unbox_float32(faermat_lean_ctor_get(o, 0));
        let im = faermat_lean_unbox_float32(faermat_lean_ctor_get(o, 1));
        num_complex::Complex::new(re, im)
    }

    // box Complex<f32> into Lean ctor
    pub unsafe fn box_complex_f32(c: num_complex::Complex<f32>) -> LeanObjRes {
        let r = faermat_lean_alloc_ctor(0, 2, 0);
        faermat_lean_ctor_set(r, 0, faermat_lean_box_float32(c.re));
        faermat_lean_ctor_set(r, 1, faermat_lean_box_float32(c.im));
        r
    }

    // extract Array C32 into Vec<Complex<f32>>
    pub unsafe fn array_complex_f32_to_vec(a: BLeanObjArg)
        -> Vec<num_complex::Complex<f32>>
    {
        let n = faermat_lean_array_size(a);
        let mut v = Vec::with_capacity(n);
        for i in 0 .. n {
            let elem = faermat_lean_array_get_core(a, i);
            v.push(unbox_complex_f32(elem));
        }
        v
    }

    // Vec<Complex<f32>> into Lean Array C32
    pub unsafe fn vec_to_array_complex_f32(v: &[num_complex::Complex<f32>])
        -> LeanObjRes
    {
        let cap = faermat_lean_box(v.len());
        let mut arr = faermat_lean_mk_empty_array_with_capacity(cap);
        for &x in v {
            arr = faermat_lean_array_push(arr, box_complex_f32(x));
        }
        arr
    }
}

pub mod scalar;
pub mod matrix;
pub mod vector;
pub mod decomp;
pub mod fmt;
