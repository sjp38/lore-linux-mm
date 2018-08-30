Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F06F06B532C
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:17:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d1-v6so5333175pfo.16
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:17:37 -0700 (PDT)
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720101.outbound.protection.outlook.com. [40.107.72.101])
        by mx.google.com with ESMTPS id 74-v6si8229857pfz.160.2018.08.30.13.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 13:17:36 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 1/5] mm/memory_hotplug: drop intermediate
 __offline_pages
Date: Thu, 30 Aug 2018 20:17:34 +0000
Message-ID: <8be94e97-b59a-b66d-f703-3a39510a831b@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-2-david@redhat.com>
In-Reply-To: <20180816100628.26428-2-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0D389E49CDC8BF418FAFB9C27991DE93@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>

SSBndWVzcyB0aGUgd3JhcCB3YXMgZG9uZSBiZWNhdXNlIG9mIF9fcmVmLCBidXQgbm8gcmVhc29u
IHRvIGhhdmUgdGhpcw0Kd3JhcC4gU28gbG9va3MgZ29vZCB0byBtZS4NCg0KUmV2aWV3ZWQtYnk6
IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg0KDQpPbiA4LzE2
LzE4IDY6MDYgQU0sIERhdmlkIEhpbGRlbmJyYW5kIHdyb3RlOg0KPiBMZXQncyBhdm9pZCB0aGlz
IGluZGlyZWN0aW9uIGFuZCBqdXN0IGNhbGwgdGhlIGZ1bmN0aW9uIG9mZmxpbmVfcGFnZXMoKS4N
Cj4gDQo+IFNpZ25lZC1vZmYtYnk6IERhdmlkIEhpbGRlbmJyYW5kIDxkYXZpZEByZWRoYXQuY29t
Pg0KPiAtLS0NCj4gIG1tL21lbW9yeV9ob3RwbHVnLmMgfCAxMyArKystLS0tLS0tLS0tDQo+ICAx
IGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCAxMCBkZWxldGlvbnMoLSkNCj4gDQo+IGRp
ZmYgLS1naXQgYS9tbS9tZW1vcnlfaG90cGx1Zy5jIGIvbW0vbWVtb3J5X2hvdHBsdWcuYw0KPiBp
bmRleCA2YTI3MjY5MjBlZDIuLjA5MGNmNDc0ZGU4NyAxMDA2NDQNCj4gLS0tIGEvbW0vbWVtb3J5
X2hvdHBsdWcuYw0KPiArKysgYi9tbS9tZW1vcnlfaG90cGx1Zy5jDQo+IEBAIC0xNTg5LDEwICsx
NTg5LDEwIEBAIHN0YXRpYyB2b2lkIG5vZGVfc3RhdGVzX2NsZWFyX25vZGUoaW50IG5vZGUsIHN0
cnVjdCBtZW1vcnlfbm90aWZ5ICphcmcpDQo+ICAJCW5vZGVfY2xlYXJfc3RhdGUobm9kZSwgTl9N
RU1PUlkpOw0KPiAgfQ0KPiAgDQo+IC1zdGF0aWMgaW50IF9fcmVmIF9fb2ZmbGluZV9wYWdlcyh1
bnNpZ25lZCBsb25nIHN0YXJ0X3BmbiwNCj4gLQkJICB1bnNpZ25lZCBsb25nIGVuZF9wZm4pDQo+
ICsvKiBNdXN0IGJlIHByb3RlY3RlZCBieSBtZW1faG90cGx1Z19iZWdpbigpIG9yIGEgZGV2aWNl
X2xvY2sgKi8NCj4gK2ludCBvZmZsaW5lX3BhZ2VzKHVuc2lnbmVkIGxvbmcgc3RhcnRfcGZuLCB1
bnNpZ25lZCBsb25nIG5yX3BhZ2VzKQ0KPiAgew0KPiAtCXVuc2lnbmVkIGxvbmcgcGZuLCBucl9w
YWdlczsNCj4gKwl1bnNpZ25lZCBsb25nIHBmbiwgZW5kX3BmbiA9IHN0YXJ0X3BmbiArIG5yX3Bh
Z2VzOw0KPiAgCWxvbmcgb2ZmbGluZWRfcGFnZXM7DQo+ICAJaW50IHJldCwgbm9kZTsNCj4gIAl1
bnNpZ25lZCBsb25nIGZsYWdzOw0KPiBAQCAtMTYxMiw3ICsxNjEyLDYgQEAgc3RhdGljIGludCBf
X3JlZiBfX29mZmxpbmVfcGFnZXModW5zaWduZWQgbG9uZyBzdGFydF9wZm4sDQo+ICANCj4gIAl6
b25lID0gcGFnZV96b25lKHBmbl90b19wYWdlKHZhbGlkX3N0YXJ0KSk7DQo+ICAJbm9kZSA9IHpv
bmVfdG9fbmlkKHpvbmUpOw0KPiAtCW5yX3BhZ2VzID0gZW5kX3BmbiAtIHN0YXJ0X3BmbjsNCj4g
IA0KPiAgCS8qIHNldCBhYm92ZSByYW5nZSBhcyBpc29sYXRlZCAqLw0KPiAgCXJldCA9IHN0YXJ0
X2lzb2xhdGVfcGFnZV9yYW5nZShzdGFydF9wZm4sIGVuZF9wZm4sDQo+IEBAIC0xNzAwLDEyICsx
Njk5LDYgQEAgc3RhdGljIGludCBfX3JlZiBfX29mZmxpbmVfcGFnZXModW5zaWduZWQgbG9uZyBz
dGFydF9wZm4sDQo+ICAJdW5kb19pc29sYXRlX3BhZ2VfcmFuZ2Uoc3RhcnRfcGZuLCBlbmRfcGZu
LCBNSUdSQVRFX01PVkFCTEUpOw0KPiAgCXJldHVybiByZXQ7DQo+ICB9DQo+IC0NCj4gLS8qIE11
c3QgYmUgcHJvdGVjdGVkIGJ5IG1lbV9ob3RwbHVnX2JlZ2luKCkgb3IgYSBkZXZpY2VfbG9jayAq
Lw0KPiAtaW50IG9mZmxpbmVfcGFnZXModW5zaWduZWQgbG9uZyBzdGFydF9wZm4sIHVuc2lnbmVk
IGxvbmcgbnJfcGFnZXMpDQo+IC17DQo+IC0JcmV0dXJuIF9fb2ZmbGluZV9wYWdlcyhzdGFydF9w
Zm4sIHN0YXJ0X3BmbiArIG5yX3BhZ2VzKTsNCj4gLX0NCj4gICNlbmRpZiAvKiBDT05GSUdfTUVN
T1JZX0hPVFJFTU9WRSAqLw0KPiAgDQo+ICAvKioNCj4g
