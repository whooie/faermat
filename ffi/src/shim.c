#include <lean/lean.h>

/* Wrappers for inline Lean C API functions needed by the
 * Rust FFI layer. */

lean_object *faermat_lean_alloc_external(lean_external_class *cls, void *data) {
    return lean_alloc_external(cls, data);
}

void *faermat_lean_get_external_data(lean_object *o) {
    return lean_get_external_data(o);
}

lean_object *faermat_lean_box(size_t n) {
    return lean_box(n);
}

size_t faermat_lean_unbox(lean_object *o) {
    return lean_unbox(o);
}

lean_object *faermat_lean_box_float(double v) {
    return lean_box_float(v);
}

double faermat_lean_unbox_float(lean_object *o) {
    return lean_unbox_float(o);
}

size_t faermat_lean_array_size(lean_object *o) {
    return lean_array_size(o);
}

lean_object *faermat_lean_array_get_core(lean_object *o, size_t i) {
    return lean_array_get_core(o, i);
}

lean_object *faermat_lean_mk_empty_array_with_capacity(lean_object *cap) {
    return lean_mk_empty_array_with_capacity(cap);
}

lean_object *faermat_lean_array_push(lean_object *a, lean_object *v) {
    return lean_array_push(a, v);
}

lean_object *faermat_lean_io_result_mk_ok(lean_object *a) {
    return lean_io_result_mk_ok(a);
}

void faermat_lean_inc(lean_object *o) { lean_inc(o); }
void faermat_lean_dec(lean_object *o) { lean_dec(o); }

lean_object *faermat_lean_alloc_ctor(
    unsigned tag,
    unsigned num_objs,
    unsigned scalar_sz
)
{
    return lean_alloc_ctor(tag, num_objs, scalar_sz);
}

void faermat_lean_ctor_set(lean_object *o, unsigned i, lean_object *v)
{
    lean_ctor_set(o, i, v);
}

lean_object *faermat_lean_ctor_get(lean_object *o, unsigned i) {
    return lean_ctor_get(o, i);
}

lean_object *faermat_lean_box_float32(float v) {
    return lean_box_float32(v);
}

float faermat_lean_unbox_float32(lean_object *o) {
    return lean_unbox_float32(o);
}

bool faermat_lean_is_exclusive(lean_object *o) {
    return lean_is_exclusive(o);
}
