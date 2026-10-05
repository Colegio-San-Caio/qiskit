import ctypes
import os

# Load the shared library
lib_path = os.path.abspath("./libomqqiskit.so")
lib = ctypes.CDLL(lib_path)

# Define the C structure for quantum circuits (qc)
class QC(ctypes.Structure):
    _fields_ = [
        ("n", ctypes.c_int),
        ("dim", ctypes.c_size_t),
        ("re", ctypes.POINTER(ctypes.c_double)),
        ("im", ctypes.POINTER(ctypes.c_double))
    ]

# Setup function signatures
lib.q_new.argtypes = [ctypes.c_int]
lib.q_new.restype = QC

lib.q_free.argtypes = [QC]
lib.q_free.restype = None

lib.q_h.argtypes = [ctypes.POINTER(QC), ctypes.c_int]
lib.q_h.restype = None

lib.q_cx.argtypes = [ctypes.POINTER(QC), ctypes.c_int, ctypes.c_int]
lib.q_cx.restype = None

lib.q_counts.argtypes = [ctypes.POINTER(QC), ctypes.c_int]
lib.q_counts.restype = None

# Initialize circuit (2 qubits) and run a Bell state simulation
print("Initializing 2-qubit circuit via Python -> C bridge...")
q = lib.q_new(2)
lib.q_h(ctypes.byref(q), 0)
lib.q_cx(ctypes.byref(q), 0, 1)

print("Running 1024 measurement shots:")
lib.q_counts(ctypes.byref(q), 1024)

lib.q_free(q)
print("Bridge execution completed successfully.")
