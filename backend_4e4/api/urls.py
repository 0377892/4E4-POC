from django.urls import path
from .views import hello_world
from .views import list_categories, pick_image, gen_text, make_meme

urlpatterns = [
    path('', hello_world, name='hello'),
    path('hello/', hello_world, name='hello_world'),
    path('categories/', list_categories),
    path('images/',       pick_image),
    path('text/',         gen_text),
    path('meme/',         make_meme),
]
