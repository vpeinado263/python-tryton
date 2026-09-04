class Paciente:

    def __init__(self, nombre):
        self.nombre = nombre

    @staticmethod
    def validar_nombre(nombre):
        if nombre == "":
            return False

        return True


print(Paciente.validar_nombre("Victor"))
print(Paciente.validar_nombre(""))