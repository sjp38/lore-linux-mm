Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA986B537E
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:17:39 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d12-v6so10654023qtk.13
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:17:39 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0095.outbound.protection.outlook.com. [104.47.36.95])
        by mx.google.com with ESMTPS id z3-v6si5450414qth.129.2018.08.30.15.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 15:17:38 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 3/5] mm/memory_hotplug: check if sections are already
 online/offline
Date: Thu, 30 Aug 2018 22:17:35 +0000
Message-ID: <b294506a-9007-be11-f477-5b2a0011b2ba@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-4-david@redhat.com>
 <20180816104736.GA16861@techadventures.net>
 <62da84ee-090f-29e4-0a39-fcfd543ee81d@redhat.com>
In-Reply-To: <62da84ee-090f-29e4-0a39-fcfd543ee81d@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1952BA0C898C7448A231EA724B9CAE68@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>

T24gOC8xNi8xOCA3OjAwIEFNLCBEYXZpZCBIaWxkZW5icmFuZCB3cm90ZToNCj4gT24gMTYuMDgu
MjAxOCAxMjo0NywgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+PiBPbiBUaHUsIEF1ZyAxNiwgMjAx
OCBhdCAxMjowNjoyNlBNICswMjAwLCBEYXZpZCBIaWxkZW5icmFuZCB3cm90ZToNCj4+DQo+Pj4g
Kw0KPj4+ICsvKiBjaGVjayBpZiBhbGwgbWVtIHNlY3Rpb25zIGFyZSBvZmZsaW5lICovDQo+Pj4g
K2Jvb2wgbWVtX3NlY3Rpb25zX29mZmxpbmUodW5zaWduZWQgbG9uZyBwZm4sIHVuc2lnbmVkIGxv
bmcgZW5kX3BmbikNCj4+PiArew0KPj4+ICsJZm9yICg7IHBmbiA8IGVuZF9wZm47IHBmbiArPSBQ
QUdFU19QRVJfU0VDVElPTikgew0KPj4+ICsJCXVuc2lnbmVkIGxvbmcgc2VjdGlvbl9uciA9IHBm
bl90b19zZWN0aW9uX25yKHBmbik7DQo+Pj4gKw0KPj4+ICsJCWlmIChXQVJOX09OKCF2YWxpZF9z
ZWN0aW9uX25yKHNlY3Rpb25fbnIpKSkNCj4+PiArCQkJY29udGludWU7DQo+Pj4gKwkJaWYgKG9u
bGluZV9zZWN0aW9uX25yKHNlY3Rpb25fbnIpKQ0KPj4+ICsJCQlyZXR1cm4gZmFsc2U7DQo+Pj4g
Kwl9DQo+Pj4gKwlyZXR1cm4gdHJ1ZTsNCj4+PiArfQ0KPj4NCj4+IEFGQUlDUyBwYWdlc19jb3Jy
ZWN0bHlfcHJvYmVkIHdpbGwgY2F0Y2ggdGhpcyBmaXJzdC4NCj4+IHBhZ2VzX2NvcnJlY3RseV9w
cm9iZWQgY2hlY2tzIGZvciB0aGUgc2VjdGlvbiB0byBiZToNCj4+DQo+PiAtIHByZXNlbnQNCj4+
IC0gdmFsaWQNCj4+IC0gIW9ubGluZQ0KPiANCj4gUmlnaHQsIEkgbWlzc2VkIHRoYXQgZnVuY3Rp
b24uDQo+IA0KPj4NCj4+IE1heWJlIGl0IG1ha2VzIHNlbnNlIHRvIHJlbmFtZSBpdCwgYW5kIHdy
aXRlIGFub3RoZXIgcGFnZXNfY29ycmVjdGx5X3Byb2JlZCByb3V0aW5lDQo+PiBmb3IgdGhlIG9m
ZmxpbmUgY2FzZS4NCj4+DQo+PiBTbyBhbGwgY2hlY2tzIHdvdWxkIHN0YXkgaW4gbWVtb3J5X2Js
b2NrX2FjdGlvbiBsZXZlbCwgYW5kIHdlIHdvdWxkIG5vdCBuZWVkDQo+PiB0aGUgbWVtX3NlY3Rp
b25zX29mZmxpbmUvb25saW5lIHN0dWZmLg0KDQpJIGFtIE9LIHdpdGggdGhhdCwgYnV0IHdpbGwg
d2FpdCBmb3IgYSBwYXRjaCB0byByZXZpZXcuDQoNClBhdmVs
