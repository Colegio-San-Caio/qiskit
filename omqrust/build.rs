fn main() {
    cc::Build::new()
        .file("csrc/omqqiskit.c")
        .define("OMQ_LIB", None)
        .compile("omqqiskit");
    println!("cargo:rerun-if-changed=csrc/omqqiskit.c");
}
