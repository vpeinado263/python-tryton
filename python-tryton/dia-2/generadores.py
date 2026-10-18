def generar_pacientes():
    print("Preparando Victor")
    yield "Victor"

    print("Preparando Ana")
    yield "Ana"

    print("Preparando Carlos")
    yield "Carlos"


pacientes = generar_pacientes()

print(next(pacientes))
print(next(pacientes))
print(next(pacientes))

