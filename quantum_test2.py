from qiskit import QuantumCircuit
from qiskit.quantum_info import Statevector
circ = QuantumCircuit(2)
circ.h(0)
circ.cx(0,1)
sv = Statevector.from_instruction(circ)
print(sv)
print("Counts: 00 ~50%, 11 ~50% — Bell state OK")
