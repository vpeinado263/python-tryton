class Paciente:
    def __init__(self, nombre, edad):
        self.nombre = nombre
        self.edad = edad

    @property
    def edad(self):
        return self._edad

    @edad.setter
    def edad(self, valor):
        if valor < 0:
            raise ValueError("La edad no puede ser negativa")

        self._edad = valor


paciente1 = Paciente("Victor", 30)


print(paciente1.nombre)
print(paciente1.edad)