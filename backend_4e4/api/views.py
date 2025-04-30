# api/views.py

import random, base64, io
from pathlib import Path
from tkinter import Image
from PIL import ImageDraw, ImageFont

from django.conf import settings
from django.http import HttpResponse, JsonResponse
from rest_framework.decorators import api_view

from .models import Category
from .serializers import CategorySerializer


@api_view(['GET'])
def list_categories(request):
    # 1) figure out requested language (always fall back to 'en')
    lang = request.query_params.get('lang', 'en').lower()
    if lang not in ('en', 'fr'):
        lang = 'en'

    # 2) your short-key → translations map
    translations = {
        'politics': {'en': 'Politics',   'fr': 'Politique'},
        'sport': {'en': 'Sports',     'fr': 'Sport'},
        # …and so on for each Category.key you have…
    }

    # 3) serialize everything first
    qs = Category.objects.all()
    serializer = CategorySerializer(qs, many=True, context={'request': request})
    data = serializer.data  # this is a list of {'id':…, 'key':…, 'label':…}

    # 4) post-process each item's label
    for item in data:
        key = item.get('key')
        default_label = item.get('label')
        item['label'] = translations.get(key, {}).get(lang, default_label)

    return JsonResponse(data, safe=False)


@api_view(['GET'])
def pick_image(request):
    cats_param = request.query_params.get('cats', '')
    keys = [k for k in cats_param.split(',') if k]

    pool = []
    # try combo folder first (alphabetical)
    if len(keys) == 2:
        combo = '-'.join(sorted(keys))
        combo_dir = Path(settings.BASE_DIR) / 'api' / 'static' / 'images' / combo
        if combo_dir.exists():
            pool = list(combo_dir.iterdir())

    # fallback to single‐category folders
    if not pool:
        for k in keys:
            d = Path(settings.BASE_DIR) / 'api' / 'static' / 'images' / k
            if d.exists():
                pool += list(d.iterdir())

    if not pool:
        return JsonResponse({'error': 'No images found for those categories'}, status=404)

    choice = random.choice(pool)
    data = base64.b64encode(choice.read_bytes()).decode()
    return JsonResponse({'image': f"data:image/png;base64,{data}"})


@api_view(['POST'])
def gen_text(request):
    cats = request.data.get('cats', [])
    lang = request.data.get('lang', 'en').lower()

    # bilingual templates keyed on the same short keys:
    templates = {
        'en': {
            'politics': ["When your MP says \"I'll fix everything\"…"],
            'sport': ["That moment when you miss the goal…"],
        },
        'fr': {
            'politics': ["Quand votre député promet « je vais tout régler »…"],
            'sport': ["Ce moment où vous manquez le but…"],
        },
    }
    combo_tpl = {
        'en': {
            ('politics','sport'): ["When your PM scores a touchdown in parliament…"],
        },
        'fr': {
            ('politics','sport'): ["Quand votre PM marque un touché au parlement…"],
        },
    }

    combo = tuple(sorted(cats))
    if combo in combo_tpl.get(lang, {}):
        text = random.choice(combo_tpl[lang][combo])
    else:
        parts = []
        for k in cats:
            parts.append(random.choice(templates.get(lang, {}).get(k, ["No caption available."])))
        text = "  ".join(parts)

    return JsonResponse({'text': text})


@api_view(['POST'])
def make_meme(request):
    img_data = request.data['image'].split(',',1)[1]
    text     = request.data['text']
    img_bytes= base64.b64decode(img_data)
    img      = Image.open(io.BytesIO(img_bytes))
    draw     = ImageDraw.Draw(img)
    font     = ImageFont.load_default()
    draw.text((10,10), text, font=font, fill='white')
    buffer   = io.BytesIO()
    img.save(buffer, format='PNG')
    out      = base64.b64encode(buffer.getvalue()).decode()
    return JsonResponse({'meme': f"data:image/png;base64,{out}"})


def hello_world(request):
    return HttpResponse("Hello, world!")
