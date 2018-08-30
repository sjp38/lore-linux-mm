Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D47506B531F
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:20:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u45-v6so9940382qte.12
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:20:11 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700126.outbound.protection.outlook.com. [40.107.70.126])
        by mx.google.com with ESMTPS id z74-v6si6348438qkg.148.2018.08.30.13.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 13:20:11 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 1/5] mm/memory_hotplug: drop intermediate
 __offline_pages
Date: Thu, 30 Aug 2018 20:20:08 +0000
Message-ID: <95018407-0c7a-b3b8-8c09-109337f91929@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-2-david@redhat.com>
 <8be94e97-b59a-b66d-f703-3a39510a831b@microsoft.com>
In-Reply-To: <8be94e97-b59a-b66d-f703-3a39510a831b@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F14FC2AD6A6E3543B94507DADA5BC8D7@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDgvMzAvMTggNDoxNyBQTSwgUGFzaGEgVGF0YXNoaW4gd3JvdGU6DQo+IEkgZ3Vlc3Mg
dGhlIHdyYXAgd2FzIGRvbmUgYmVjYXVzZSBvZiBfX3JlZiwgYnV0IG5vIHJlYXNvbiB0byBoYXZl
IHRoaXMNCj4gd3JhcC4gU28gbG9va3MgZ29vZCB0byBtZS4NCj4gDQo+IFJldmlld2VkLWJ5OiBQ
YXZlbCBUYXRhc2hpbiA8cGF2ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNvbT4+DQo+IE9uIDgvMTYv
MTggNjowNiBBTSwgRGF2aWQgSGlsZGVuYnJhbmQgd3JvdGU6DQo+PiBMZXQncyBhdm9pZCB0aGlz
IGluZGlyZWN0aW9uIGFuZCBqdXN0IGNhbGwgdGhlIGZ1bmN0aW9uIG9mZmxpbmVfcGFnZXMoKS4N
Cj4+DQo+PiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBIaWxkZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNv
bT4NCj4+IC0tLQ0KPj4gIG1tL21lbW9yeV9ob3RwbHVnLmMgfCAxMyArKystLS0tLS0tLS0tDQo+
PiAgMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMTAgZGVsZXRpb25zKC0pDQo+Pg0K
Pj4gZGlmZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1vcnlfaG90cGx1Zy5j
DQo+PiBpbmRleCA2YTI3MjY5MjBlZDIuLjA5MGNmNDc0ZGU4NyAxMDA2NDQNCj4+IC0tLSBhL21t
L21lbW9yeV9ob3RwbHVnLmMNCj4+ICsrKyBiL21tL21lbW9yeV9ob3RwbHVnLmMNCj4+IEBAIC0x
NTg5LDEwICsxNTg5LDEwIEBAIHN0YXRpYyB2b2lkIG5vZGVfc3RhdGVzX2NsZWFyX25vZGUoaW50
IG5vZGUsIHN0cnVjdCBtZW1vcnlfbm90aWZ5ICphcmcpDQo+PiAgCQlub2RlX2NsZWFyX3N0YXRl
KG5vZGUsIE5fTUVNT1JZKTsNCj4+ICB9DQo+PiAgDQo+PiAtc3RhdGljIGludCBfX3JlZiBfX29m
ZmxpbmVfcGFnZXModW5zaWduZWQgbG9uZyBzdGFydF9wZm4sDQo+PiAtCQkgIHVuc2lnbmVkIGxv
bmcgZW5kX3BmbikNCj4+ICsvKiBNdXN0IGJlIHByb3RlY3RlZCBieSBtZW1faG90cGx1Z19iZWdp
bigpIG9yIGEgZGV2aWNlX2xvY2sgKi8NCj4+ICtpbnQgb2ZmbGluZV9wYWdlcyh1bnNpZ25lZCBs
b25nIHN0YXJ0X3BmbiwgdW5zaWduZWQgbG9uZyBucl9wYWdlcykNCiAgICAgIF5eXg0KSSBtZWFu
dCB0byBzYXkga2VlcCB0aGUgX19yZWYsIG90aGVyd2lzZSBsb29rcyBnb29kLg0KDQpUaGFuayB5
b3UsDQpQYXZlbA==
