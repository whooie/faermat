use std::process::Command;

fn main() {
    let output = Command::new("lean")
        .args(["--print-prefix"])
        .output()
        .expect("failed to run `lean --print-prefix`");
    let prefix = String::from_utf8(output.stdout)
        .expect("non-utf8 lean prefix")
        .trim()
        .to_string();
    let lean_include = format!("{prefix}/include");

    cc::Build::new()
        .file("src/shim.c")
        .include(&lean_include)
        .opt_level(2)
        .compile("lean_shim");
}
