# -*- coding: utf-8 -*-
from django.conf.urls import url
from django.views.generic import TemplateView

from . import views

urlpatterns = [
    url(r'^Resource/Nav.aspx$', views.Nav.as_view(), name='nav'),
    url(r'^Resource/Content.aspx$', views.Content.as_view(), name='content'),
    
    url(r'^Static/Topics.aspx$', TemplateView.as_view(template_name="archive/topics.html"), name='topics'),
    url(r'^Core/TopicDetail.aspx$', views.term_detail.as_view(), name='term-detail'),
    url(r'^Core/ArchiveObjectsByTopic.aspx$', views.term_objects.as_view(), name='term-objects'),
    
    url(r'^Static/PDCollections.aspx$', TemplateView.as_view(template_name="archive/doc-collections.html"), name='doc-collections'),
    url(r'^Static/InstitutionalCollections.aspx$', TemplateView.as_view(template_name="archive/institutional-collections.html"), name='institutional-collections'),
    url(r'^Static/PrivateCollections.aspx$', TemplateView.as_view(template_name="archive/private-collections.html"), name='private-collections'),
    
    url(r'^Static/VHCollections.aspx$', TemplateView.as_view(template_name="archive/vh-collections.html"), name='vh-collections'),
    url(r'^Core/VHCollectionDetail.aspx$', views.collection_detail.as_view(), name='collection-detail'),
    url(r'^Core/PersonDetail.aspx$', views.person_detail.as_view(), name='person-detail'),
    url(r'^Core/InterviewDetail.aspx$', views.interview_detail.as_view(), name='interview-detail'),
    url(r'^Core/SegmentsByInterview.aspx$', views.collection_objects.as_view(), name='interview-segments'),
    
    url(r'^Core/CollectionDetail.aspx$', views.collection_detail.as_view(), name='collection-detail'),
    url(r'^Core/DAObjectsByCollection.aspx$', views.collection_objects.as_view(), name='collection-objects'),
    
    url(r'^Static/Facilities.aspx$', TemplateView.as_view(template_name="archive/facilities.html"), name='facilities'),
    url(r'^Core/FacilityTypeDetail.aspx$', views.facility_type.as_view(), name='facility-type'),
    url(r'^Core/FacilityDetail.aspx$', views.facility_detail.as_view(), name='facility-detail'),
    url(r'^Core/ArchiveObjectsByFacility.aspx$', views.facility_objects.as_view(), name='facility-objects'),

    url(r'^Static/NewspaperCollections.aspx$', TemplateView.as_view(template_name="archive/newspaper-collections.html"), name='newspaper-collections'),
    
    url(r'^Resource/Search.aspx$', views.search_form.as_view(), name='search-form'),
    url(r'^Resource/SearchArchiveObjects.aspx$', views.search_results.as_view(), name='search-results'),
    
    url(r'^Resource/SearchArchiveItem.aspx$', views.object_detail.as_view(), name='object-detail'),
    
    url(r'^Resource/nolist.aspx$', views.nolist.as_view(), name='nolist'),
    url(r'^$', views.Index.as_view(), name='index'),
]
