from rest_framework import serializers
from .models import Category

class CategorySerializer(serializers.ModelSerializer):
    label = serializers.SerializerMethodField()
    def get_label(self, obj):
        lang = self.context['request'].query_params.get('lang', 'en')
        return obj.label_fr if lang == 'fr' else obj.label_en

    class Meta:
        model = Category
        fields = ['id', 'key', 'label']