from django.contrib import admin
from django.urls import path, re_path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(
        title="4E4 API",
        default_version='v1',
        description="Swagger UI for backend_4e4 endpoints",
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),

        re_path(r'^swagger(?P<format>\.json|\.yaml)$',
        schema_view.without_ui(cache_timeout=0),
        name='schema-json'),
    # Swagger UI
    path('swagger/', 
        schema_view.with_ui('swagger', cache_timeout=0),
        name='schema-swagger-ui'),
    # ReDoc UI (optional)
    path('redoc/',
        schema_view.with_ui('redoc', cache_timeout=0),
        name='schema-redoc'),
]
