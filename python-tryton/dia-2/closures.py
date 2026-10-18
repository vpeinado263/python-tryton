def crear_saludo(nombre):

    def saludo():
        print(f"Hola, {nombre}")

    return saludo


saludar = crear_saludo("Victor")

saludar()