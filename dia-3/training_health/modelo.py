from trytond.model import ModelSQL, ModelView, fields


class Professional(ModelSQL, ModelView):
    "Training Health - Professional"
    __name__ = "training_health.professional"

    name = fields.Char("Nombre")
    license_number = fields.Char("Matrícula")
    specialty = fields.Char("Especialidad")
    state = fields.Selection(
    [
        ("active", "Activo"),
        ("inactive", "Inactivo"),
    ],
    "Estado"
    )

    entry_date = fields.Date("Fecha de ingreso")

class Patient(ModelSQL, ModelView):
    "Training Health - Patient"
    __name__ = "training_health.patient"

    code = fields.Char("Código")
    name = fields.Char("Nombre")
    birth_date = fields.Date("Fecha de nacimiento")
    active = fields.Boolean("Activo")
    observations = fields.Char("Observaciones")

    professional = fields.Many2One(
        "training_health.professional",
        "Profesional"
    )