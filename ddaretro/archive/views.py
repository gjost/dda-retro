# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render
from django.views import View

import requests

from . import queries

HEADERS = {
    #'user-agent': 'dda-retro',
    #'content-type': 'application/json',
}
TIMEOUT = 5


class Index(View):
    template = 'archive/index.html'
    def get(self, request, *args, **kwargs):
        return render(request, self.template, {})

class Nav(View):
    template = 'archive/nav.html'
    def get(self, request, *args, **kwargs):
        return render(request, self.template, {
            'topics': queries.TOPICS,
            'doc': queries.PHOTO_DOC_COLLECTIONS,
            'vh': queries.VISUAL_HISTORY_COLLECTIONS,
            'facilities': queries.FACILITIES,
            'campnews': queries.CAMP_NEWS_COLLECTIONS,
        })

class nolist(View):
    template = 'archive/nolist.html'
    def get(self, request, *args, **kwargs):
        return render(request, self.template, {})

class Content(View):
    template = 'archive/content.html'
    def get(self, request, *args, **kwargs):
        return render(request, self.template, {})


# detail ---------------------------------------------------------------

class term_detail(View):
    template = 'archive/term-detail.html'
    def get(self, request, *args, **kwargs):
        assert False

class facility_type(View):
    template = 'archive/facility-type.html'
    def get(self, request, *args, **kwargs):
        fid = int(request.GET.get('id'))
        for t in queries.FACILITIES:
            if t['id'] == fid:
                return render(request, self.template, {'object': t})
        return render(request, self.template, {})
    
class facility_detail(View):
    template = 'archive/facility-detail.html'
    def get(self, request, *args, **kwargs):
        fid = request.GET.get('id')
        url = '%s/facet/facility/%s/' % (settings.DDR_API, fid)
        r = requests.get(url=url, headers=HEADERS, timeout=TIMEOUT)
        if (r.status_code not in [200]):
            raise requests.exceptions.ConnectionError(
                'Error %s' % (r.status_code))
        return render(request, self.template, {'object': r.json(),})

class collection_detail(View):
    template = 'archive/collection-detail.html'
    def get(self, request, *args, **kwargs):
        cid = request.GET.get('id')
        url = '%s/%s/' % (settings.DDR_API, cid)
        r = requests.get(url=url, headers=HEADERS, timeout=TIMEOUT)
        if (r.status_code not in [200]):
            raise requests.exceptions.ConnectionError(
                'Error %s' % (r.status_code))
        return render(request, self.template, {'object': r.json(),})

class person_detail(View):
    template = 'archive/person-detail.html'
    def get(self, request, *args, **kwargs):
        oid = request.GET.get('id')
        url = '%s/%s/' % (settings.DDR_API, oid)
        r = requests.get(url=url, headers=HEADERS, timeout=TIMEOUT)
        if (r.status_code not in [200]):
            raise requests.exceptions.ConnectionError(
                'Error %s' % (r.status_code))
        return render(request, self.template, {'object': r.json(),})

class interview_detail(View):
    template = 'archive/segment-detail.html'
    def get(self, request, *args, **kwargs):
        oid = request.GET.get('id')
        url = '%s/%s/' % (settings.DDR_API, oid)
        r = requests.get(url=url, headers=HEADERS, timeout=TIMEOUT)
        if (r.status_code not in [200]):
            raise requests.exceptions.ConnectionError(
                'Error %s' % (r.status_code))
        return render(request, self.template, {'object': r.json(),})


# objects --------------------------------------------------------------

class term_objects(View):
    template = 'archive/search-results.html'
    def get(self, request, *args, **kwargs):
        tid = request.GET.get('id')
        # http://ddr.densho.org/api/0.2/facet/topics/40/objects/
        url = '%s/facet/topics/%s/objects/' % (settings.DDR_API, tid)
        r = requests.get(
            # http://ddr.densho.org/api/0.2/facet/topics/40/
            url,
            headers=HEADERS,
            timeout=TIMEOUT,
        )
        if (r.status_code not in [200]):
            #raise requests.exceptions.ConnectionError(
            #    'Error %s' % (r.status_code))
            assert False
        return render(request, self.template, {'results': r.json()})

class collection_objects(View):
    template = 'archive/search-results.html'
    def get(self, request, *args, **kwargs):
        oid = request.GET.get('id')
        query = {
            "fulltext": oid,
            "models": ["entity", "segment"],
        }
        r = requests.get(
            '%s/%s/children/' % (settings.DDR_API, oid),
            headers=HEADERS,
            timeout=TIMEOUT,
        )
        if (r.status_code not in [200]):
            #raise requests.exceptions.ConnectionError(
            #    'Error %s' % (r.status_code))
            assert False
        return render(request, self.template, {'results': r.json()})

class facility_objects(View):
    template = 'archive/search-results.html'
    def get(self, request, *args, **kwargs):
        fid = request.GET.get('id')
        # http://ddr.densho.org/api/0.2/facet/facility/7/objects/
        r = requests.get(
            '%s/facet/facility/%s/objects/' % (settings.DDR_API, fid),
            headers=HEADERS,
            timeout=TIMEOUT,
        )
        if (r.status_code not in [200]):
            #raise requests.exceptions.ConnectionError(
            #    'Error %s' % (r.status_code))
            assert False
        return render(request, self.template, {'results': r.json()})


# search ---------------------------------------------------------------

class search_form(View):
    template = 'archive/search-form.html'
    
    def get(self, request, *args, **kwargs):
        return render(request, self.template, {})
    
    def post(self, request, *args, **kwargs):
        assert False
        return render(request, self.template, {})

class search_results(View):
    template = 'archive/search-results.html'
    
    def get(self, request, *args, **kwargs):
        assert False
        template = 'archive/search-results-form.html'
        return render(request, self.template, {})
    
    def post(self, request, *args, **kwargs):
        fulltext = request.POST.get('fulltext')
        query = {
            "fulltext": fulltext,
            "models": ["collection", "entity", "segment", "file"],
        }

        r = requests.post(
            '%s/search/' % settings.DDR_API,
            json=query,
            headers=HEADERS,
            timeout=TIMEOUT,
        )
        if (r.status_code not in [200]):
            #raise requests.exceptions.ConnectionError(
            #    'Error %s' % (r.status_code))
            assert False
        return render(request, self.template, {'results': r.json()})


class object_detail(View):
    template = 'archive/object-detail.html'
    def get(self, request, *args, **kwargs):
        url = '%s/%s/' % (settings.DDR_API, request.GET.get('i')) # 
        r = requests.get(url=url, headers=HEADERS, timeout=TIMEOUT)
        if (r.status_code not in [200]):
            raise requests.exceptions.ConnectionError(
                'Error %s' % (r.status_code))
        return render(request, self.template, {'object': r.json(),})
