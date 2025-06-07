# estudiantes/views.py
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated

from .models import Estudiante, EstudianteLogin
from .serializers import EstudianteSerializer, EstudianteLoginSerializer

class AuthViewSet(viewsets.GenericViewSet):
    queryset = EstudianteLogin.objects.all()
    serializer_class = EstudianteLoginSerializer

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        print("Datos recibidos en el registro:", request.data)  # Debugging line
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True) 
        print(serializer.is_valid())  # Debugging line
        try:
            user = serializer.save()
            Estudiante.objects.create(
                cedula=user.cedula,
                email=request.data.get('email', ''),
                nombre=user.first_name,
                apellido=user.last_name,
                user=user,
                activo=True
            )
            return Response({'message': 'Registro exitoso', 'user_id': user.id, 'cedula': user.cedula}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': f'Error durante el registro: {e}'}, status=status.HTTP_400_BAD_REQUEST)


class EstudianteViewSet(viewsets.ModelViewSet):
    queryset = Estudiante.objects.all()
    serializer_class = EstudianteSerializer
    lookup_field = 'user__cedula' 

    permission_classes = [IsAuthenticated]

    def retrieve(self, request, *args, **kwargs):
        cedula = kwargs.get(self.lookup_field)
        try:
            estudiante_profile = Estudiante.objects.get(user__cedula=cedula)
        except Estudiante.DoesNotExist:
            return Response({'detail': 'Estudiante no encontrado.'}, status=status.HTTP_404_NOT_FOUND)

        if not request.user.is_staff and not request.user.is_superuser:
            if str(request.user.cedula) != str(cedula): 
                return Response({'detail': 'No tienes permiso para ver este perfil.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = self.get_serializer(estudiante_profile)
        return Response(serializer.data)

    
    def update(self, request, *args, **kwargs):
        cedula = kwargs.get(self.lookup_field)
        try:
            estudiante_profile = Estudiante.objects.get(user__cedula=cedula)
        except Estudiante.DoesNotExist:
            return Response({'detail': 'Estudiante no encontrado.'}, status=status.HTTP_404_NOT_FOUND)

        if not request.user.is_staff and not request.user.is_superuser:
            if str(request.user.cedula) != str(cedula):
                return Response({'detail': 'No tienes permiso para actualizar este perfil.'}, status=status.HTTP_403_FORBIDDEN)

        # Para PUT, partial=False por defecto. Para PATCH, partial=True
        partial = kwargs.pop('partial', False)
        serializer = self.get_serializer(estudiante_profile, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer) 

        if getattr(estudiante_profile, '_prefetched_objects_cache', None):
            estudiante_profile._prefetched_objects_cache = {}

        return Response(serializer.data)

    
    def destroy(self, request, *args, **kwargs):
        cedula = kwargs.get(self.lookup_field)
        try:
            estudiante_profile = Estudiante.objects.get(user__cedula=cedula)
            estudiante_profile.activo = False
            estudiante_profile.save() 
        except Estudiante.DoesNotExist:
            return Response({'detail': 'Estudiante no encontrado.'}, status=status.HTTP_404_NOT_FOUND)

        return Response(status=status.HTTP_204_NO_CONTENT)

    
    def list(self, request, *args, **kwargs):
        if not request.user.is_staff and not request.user.is_superuser:
           
            try:
                estudiante_profile = Estudiante.objects.get(user=request.user)
                serializer = self.get_serializer(estudiante_profile)
                return Response([serializer.data]) 
            except Estudiante.DoesNotExist:
                return Response({'detail': 'Perfil de estudiante no encontrado para este usuario.'}, status=status.HTTP_404_NOT_FOUND)
        
        
        return super().list(request, *args, **kwargs)


    def create(self, request, *args, **kwargs):
        if not request.user.is_staff and not request.user.is_superuser:
            return Response({'detail': 'Solo los administradores pueden crear estudiantes directamente desde aquí. Utilice el endpoint de registro para usuarios regulares.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)