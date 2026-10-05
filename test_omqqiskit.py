import unittest
import ctypes
import os

class TestOMQqiskitBridge(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        lib_path = os.path.abspath("./libomqqiskit.so")
        cls.lib = ctypes.CDLL(lib_path)
        
        # Structure definition
        class QC(ctypes.Structure):
            _fields_ = [
                ("n", ctypes.c_int),
                ("dim", ctypes.c_size_t),
                ("re", ctypes.POINTER(ctypes.c_double)),
                ("im", ctypes.POINTER(ctypes.c_double))
            ]
        cls.QC = QC

        # Bindings
        cls.lib.q_new.argtypes = [ctypes.c_int]
        cls.lib.q_new.restype = QC
        cls.lib.q_free.argtypes = [QC]
        cls.lib.q_free.restype = None

    def test_circuit_initialization(self):
        q = self.lib.q_new(2)
        self.assertEqual(q.n, 2)
        self.assertEqual(q.dim, 4)
        self.assertIsNotNone(q.re)
        self.assertIsNotNone(q.im)
        self.lib.q_free(q)

if __name__ == "__main__":
    unittest.main()
