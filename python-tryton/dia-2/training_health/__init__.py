from trytond.pool import Pool
from .modelo import Patient


def register():
    pool = Pool()
    pool.register(
        Patient,
        type_="model"
    )