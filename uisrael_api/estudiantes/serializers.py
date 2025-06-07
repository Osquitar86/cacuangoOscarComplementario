from rest_framework import serializers
from .models import Estudiante, EstudianteLogin
from django.contrib.auth.hashers import make_password

class EstudianteLoginSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    first_name = serializers.CharField(required=True)
    last_name = serializers.CharField(required=True)
    email = serializers.EmailField(required=True)
    cedula = serializers.CharField(required=True, max_length=10)
    
    class Meta:
        model = EstudianteLogin
        fields = ['id', 'cedula', 'password', 'first_name', 'last_name', 'email', 'rol'] 
        extra_kwargs = {
            'password': {'write_only': True},
            'id': {'read_only': True},
            'rol': {'required': False},
        }


    
    def create(self, validated_data):
        cedula = validated_data.pop('cedula')
        password = validated_data.pop('password')
        first_name = validated_data.pop('first_name', '')
        last_name = validated_data.pop('last_name', '')
        email = validated_data.pop('email', '')
        rol = validated_data.pop('rol', 'estudiante') 

        
        user = EstudianteLogin.objects.create(
            cedula=cedula,
            first_name=first_name,
            last_name=last_name,
            email=email,
            rol=rol,           
            username=cedula, 
        )
        user.set_password(password) 
        user.save()
        return user

class EstudianteSerializer(serializers.ModelSerializer):
    cedula = serializers.CharField(source='user.cedula', read_only=True)
    nombres = serializers.CharField(source='user.first_name', read_only=True)
    apellidos = serializers.CharField(source='user.last_name', read_only=True)
    correo = serializers.EmailField(source='user.email', read_only=True)
    
    class Meta:
        model = Estudiante
        fields = [
            'id', 
            'cedula', 
            'nombres', 
            'apellidos', 
            'correo', 
            'fecha_nacimiento',
            'genero',
            'direccion',
            'telefono',
            'carrera',
            'nivel',
            'fecha_registro',
            'activo',
            
        ]
        extra_kwargs = {
            'fecha_registro': {'read_only': True}, 
            'activo': {'required': False}, 
        }

    
    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        user_instance = instance.user 

        
        for attr, value in user_data.items():
            if attr == 'first_name':
                user_instance.first_name = value
            elif attr == 'last_name':
                user_instance.last_name = value
            elif attr == 'email':
                user_instance.email = value
           
        user_instance.save()

       
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        return instance