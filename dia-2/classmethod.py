class Paciente:

    cantidad = 0

    def __init__(self, nombre):
        self.nombre = nombre
        Paciente.cantidad += 1

    @classmethod
    def mostrar_cantidad(cls):
        print(f"Pacientes registrados: {cls.cantidad}")


paciente1 = Paciente("Victor")
paciente2 = Paciente("Ana")

Paciente.mostrar_cantidad()