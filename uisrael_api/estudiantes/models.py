from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager


class EstudianteLoginManager(BaseUserManager):
    def create_user(self, cedula, password=None, **extra_fields):
        if not cedula:
            raise ValueError('El campo cedula es obligatorio')
        user = self.model(cedula=cedula, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, cedula, password=None, **extra_fields):
        extra_fields.setdefault('rol', 'admin')
        return self.create_user(cedula, password, **extra_fields)


class EstudianteLogin(AbstractBaseUser):
    cedula = models.CharField(max_length=10, unique=True)
    rol = models.CharField(max_length=10, choices=[('estudiante', 'Estudiante'), ('admin', 'Admin')], default='estudiante')
    username = models.CharField(max_length=150, unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=150, blank=True, null=True)
    last_name = models.CharField(max_length=150, blank=True, null=True)
    email = models.EmailField(unique=True, blank=True, null=True)
    is_staff = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)
     
    USERNAME_FIELD = 'cedula'
    # REQUIRED_FIELDS = ['email', 'first_name', 'last_name']
    
    objects = EstudianteLoginManager()
    
    def __str__(self):
        return f"{self.cedula} - {self.get_rol_display()}"
    
    def save(self, *args, **kwargs):
        if not self.username:
            self.username = self.cedula
        super().save(*args, **kwargs)
    
    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser

class Estudiante(models.Model):
    user = models.OneToOneField(EstudianteLogin, on_delete=models.CASCADE, related_name='estudiante_profile')
    cedula = models.CharField(max_length=10, unique=True)
    nombre = models.CharField(max_length=100)
    apellido = models.CharField(max_length=100)
    fecha_nacimiento = models.DateField(blank=True, null=True)
    genero = models.CharField(max_length=10, choices=[('Masculino', 'Masculino'), ('Femenino', 'Femenino'), ('Otro', 'Otro')], null=True, blank=True)
    email = models.EmailField(unique=True)
    direccion = models.CharField(max_length=255, null=True, blank=True)
    telefono = models.CharField(max_length=15, blank=True, null=True)
    carrera = models.CharField(max_length=100, null=True, blank=True)
    nivel = models.CharField(max_length=50, null=True, blank=True)
    fecha_registro = models.DateTimeField(auto_now_add=True)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.nombre} {self.apellido} ({self.cedula})"

