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
