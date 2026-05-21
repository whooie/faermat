# Faermat

Lean 4 linear algebra library backed by [faer][faer] via Rust FFI. Provides
opaque `Matrix` and `Vector` types with support for `Float`, `Float32`, `Complex
Float`, and `Complex Float32` scalar types.

## Features

This library provides high-level bindings to a basic subset of faer's matrix
operations, including:

- **Matrix and vector arithmetic**: addition, subtraction, multiplication,
  transpose, adjoint, Kronecker product, matrix power
- **Basic allocation management**: zero-copy submatrix, row, and column views
  backed by shared ownership
- **Matrix decompositions**: LU (partial pivoting), QR, Cholesky, SVD,
  self-adjoint and general eigenvalue decomposition
- **Matrix functions**: `expm`, `sqrtm`, and `logm` via eigenvalue
  decomposition

## Using this library

Use of faermat requires `cargo` to be locally available to build the FFI, which
can be installed via [rustup][rustup]. After installing, this project can be
added as a dependency in a [Lake project][elan] by inserting the following in
your `lakefile.toml`:
```toml
[[require]]
name = "Faermat"
git = "https://gitlab.com/whooie/faermat"
rev = "v0.1.0"
```

## Dependencies

### Lean packages (fetched automatically by Lake)

- [Numplex](https://gitlab.com/whooie/numplex) v0.1.1 for complex number types
- [Fmtl](https://gitlab.com/whooie/fmtl) v0.1.0 for string formatting support

### Rust crates (fetched automatically by Cargo)

- [faer](https://crates.io/crates/faer) 0.24 for underlying linear algebra (duh)
- [num-complex](https://crates.io/crates/num-complex) 0.4 for Rust-side complex
  numbers

## Building

To build locally, install [Lake][elan] and [cargo][rustup]. Then run
```sh
lake build Faermat
```
Lake automatically invokes `cargo build --release` in the `ffi/` directory as
part of the build, so no separate Rust build step is needed.

For the test executable, run:
```sh
lake build faermat_test && .lake/build/bin/faermat_test
```

## Usage

All types and functions live in the `Faermat` namespace. The following example
solves a 3x3 linear system `A x = b`, computes the matrix exponential, and
verifies that the LU-factored solution matches a direct solve:

```lean
import Faermat

open Faermat in
def main : IO Unit := do
  -- Build a 3x3 matrix from row-major data.
  let some a := Matrix.ofRowArray 3 3
    #[ 2.0, -1.0,  0.0,
      -1.0,  2.0, -1.0,
       0.0, -1.0,  2.0 ]
    | IO.eprintln "bad matrix data"; return ()

  -- Right-hand side vector.
  let some b := Vector.ofArray #[1.0, 0.0, 0.0]
    | IO.eprintln "bad vector data"; return ()

  -- Solve via LU decomposition.
  let lu := LU.new a
  let x := lu.solveVec b

  -- Verify: compute the residual r = A * x - b.
  let r := a * x - b
  IO.println s!"solution x = {x}"
  IO.println s!"residual norm = {r.norm}"

  -- Matrix exponential: exp(A) is real for real A.
  let some ea := Matrix.expm a
    | IO.eprintln "expm failed"; return ()
  IO.println s!"exp(A) =\n{ea}"

  -- Eigenvalues of A (real symmetric, so all real).
  let some evals := Matrix.selfAdjointEigenvalues a
    | IO.eprintln "eigenvalue computation failed"; return
  IO.println s!"eigenvalues = {evals}"

  -- Kronecker product: A (x) I_2 is 6x6.
  let i2 := Matrix.identity (a := Float) 2
  let ak := a.kron i2
  IO.println s!"A (x) I_2 has shape {ak.shape}"

  -- Matrix power via binary exponentiation.
  let a4 := a ^ 4
  let a4_check := a * a * a * a
  -- Compare element-wise: the difference should be near zero.
  let diff := (a4 - a4_check).norm
  IO.println s!"||A^4 - A*A*A*A|| = {diff}"
```

## AI disclosure

Portions of this library were written with the assistance of AI.

[faer]: https://crates.io/crates/faer
[elan]: https://github.com/leanprover/elan
[rustup]: https://rustup.rs
[numplex]: https://gitlab.com/whooie/numplex
[fmtl]: https://gitlab.com/whooie/fmtl
[num-complex]: https://crates.io/crates/num-complex

