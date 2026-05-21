import Lake
open Lake DSL System

package faermat where
  version := v!"0.1.0"

@[default_target]
lean_lib Faermat where
  srcDir := "src"
  moreLinkObjs := #[⟨BuildKey.packageTarget .anonymous `ffi⟩]

lean_exe faermat_test where
  root := `Test

require Fmtl from
  git "https://gitlab.com/whooie/fmtl" @ "v0.1.0"

require Numplex from
  git "https://gitlab.com/whooie/numplex" @ "v0.1.1"

/--
Build the Rust FFI static library via cargo.
-/
target ffi pkg : FilePath := do
  let ffiDir := pkg.dir / "ffi"
  let result <- IO.Process.output {
    cmd := "cargo"
    args := #[
      "build",
      "--release",
      "--manifest-path",
      (ffiDir / "Cargo.toml").toString
    ]
  }
  if result.exitCode != 0 then
    IO.eprintln s!"cargo build failed:\n{result.stderr}"
    IO.Process.exit result.exitCode.toUInt8
  else pure ()
  let name := nameToStaticLib "faermat_ffi"
  return .pure (ffiDir / "target" / "release" / name)
