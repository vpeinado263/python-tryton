def mi_decorador(funcion):

    def envoltura(*args, **kwargs):
        print("Iniciando función...")
        funcion(*args, **kwargs)

    return envoltura


@mi_decorador
def saludar(nombre):
    print(f"Hola, {nombre}")

@mi_decorador
def presentar(nombre, profesion):
    print(f"{nombre} es {profesion}")


saludar("Victor")
presentar(nombre="Victor", profesion="Enfermero")