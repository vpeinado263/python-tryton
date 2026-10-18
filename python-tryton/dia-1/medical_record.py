class MedicalRecord:

    def __init__(self, patient_name, diagnosis, date, active):
        self.patient_name = patient_name
        self.diagnosis = diagnosis
        self.date = date
        self.active = active

    @property
    def patient_name(self):
        return self._patient_name

    @patient_name.setter
    def patient_name(self, value):
        if value == "":
            raise ValueError("El nombre del paciente no puede estar vacío")

        self._patient_name = value

    def __repr__(self):
        return (
            f"MedicalRecord("
            f"patient='{self.patient_name}', "
            f"diagnosis='{self.diagnosis}', "
            f"date='{self.date}', "
            f"active={self.active}"
            f")"
        )

    def __eq__(self, other):
        return (
            self.patient_name == other.patient_name
            and self.diagnosis == other.diagnosis
            and self.date == other.date
            and self.active == other.active
        )

    def validar(self):
        if self.patient_name == "":
            return False

        if self.diagnosis == "":
            return False

        if self.date == "":
            return False

        return True


record1 = MedicalRecord(
    "Juan",
    "Hipertensión",
    "03/09/2026",
    True
)

record2 = MedicalRecord(
    "Maria",
    "Hipertensión",
    "03/09/2026",
    True
)

record4 = MedicalRecord(
    "Ana",
    "Diabetes",
    "03/09/2026",
    False
)

print(record1)
print(record2)
print(record1 == record2)
print(record1.validar())
print(record4.validar())