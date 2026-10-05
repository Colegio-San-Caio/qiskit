use std::os::raw::c_int;

#[repr(C)]
pub struct QC {
    pub n: c_int,
    pub dim: usize,
    pub re: *mut f64,
    pub im: *mut f64,
}

unsafe extern "C" {
    pub fn q_new(n: c_int) -> QC;
    pub fn q_free(q: QC);
    pub fn q_h(q: *mut QC, target: c_int);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ffi_quantum_circuit() {
        unsafe {
            let q = q_new(2);
            assert_eq!(q.n, 2);
            assert_eq!(q.dim, 4);
            q_free(q);
        }
    }
}
