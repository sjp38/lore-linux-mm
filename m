Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 300166B53AD
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:14:06 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l7-v6so10680850qte.2
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:14:06 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0090.outbound.protection.outlook.com. [104.47.36.90])
        by mx.google.com with ESMTPS id f37-v6si7614037qtc.65.2018.08.30.15.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 15:14:05 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 2/5] mm/memory_hotplug: enforce section alignment when
 onlining/offlining
Date: Thu, 30 Aug 2018 22:14:01 +0000
Message-ID: <772774b8-77d8-c09b-f933-5ce29be58fa9@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-3-david@redhat.com>
In-Reply-To: <20180816100628.26428-3-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E4E350E2BB14124E99AA86C091331C71@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>

SGkgRGF2aWQsDQoNCkkgYW0gbm90IHN1cmUgdGhpcyBpcyBuZWVkZWQsIGJlY2F1c2Ugd2UgYWxy
ZWFkeSBoYXZlIGEgc3RyaWN0ZXIgY2hlY2tlcjoNCg0KY2hlY2tfaG90cGx1Z19tZW1vcnlfcmFu
Z2UoKQ0KDQpZb3UgY291bGQgY2FsbCBpdCBmcm9tIG9ubGluZV9wYWdlcygpLCBpZiB5b3UgdGhp
bmsgdGhlcmUgaXMgYSByZWFzb24gdG8NCmRvIGl0LCBidXQgb3RoZXIgdGhhbiB0aGF0IGl0IGlz
IGRvbmUgZnJvbSBhZGRfbWVtb3J5X3Jlc291cmNlKCkgYW5kDQpmcm9tIHJlbW92ZV9tZW1vcnko
KS4NCg0KVGhhbmsgeW91LA0KUGF2ZWwNCg0KT24gOC8xNi8xOCA2OjA2IEFNLCBEYXZpZCBIaWxk
ZW5icmFuZCB3cm90ZToNCj4gb25saW5pbmcvb2ZmbGluaW5nIGNvZGUgd29ya3Mgb24gd2hvbGUg
c2VjdGlvbnMsIHNvIGxldCdzIGVuZm9yY2UgdGhhdC4NCj4gRXhpc3RpbmcgY29kZSBvbmx5IGFs
bG93cyB0byBhZGQgbWVtb3J5IGluIG1lbW9yeSBibG9jayBzaXplLiBBbmQgb25seQ0KPiB3aG9s
ZSBtZW1vcnkgYmxvY2tzIGNhbiBiZSBvbmxpbmVkL29mZmxpbmVkLiBNZW1vcnkgYmxvY2tzIGFy
ZSBhbHdheXMNCj4gYWxpZ25lZCB0byBzZWN0aW9ucywgc28gdGhpcyBzaG91bGQgbm90IGJyZWFr
IGFueXRoaW5nLg0KPiANCj4gb25saW5lX3BhZ2VzL29mZmxpbmVfcGFnZXMgd2lsbCBpbXBsaWNp
dGx5IG1hcmsgd2hvbGUgc2VjdGlvbnMNCj4gb25saW5lL29mZmxpbmUsIHNvIHRoZSBjb2RlIHJl
YWxseSBjYW4gb25seSBoYW5kbGUgc3VjaCBncmFudWxhcml0aWVzLg0KPiANCj4gKGVzcGVjaWFs
bHkgb2ZmbGluaW5nIGNvZGUgY2Fubm90IGRlYWwgd2l0aCBwYWdlYmxvY2tfbnJfcGFnZXMgYnV0
DQo+ICB0aGVvcmV0aWNhbGx5IG9ubHkgTUFYX09SREVSLTEpDQo+IA0KPiBTaWduZWQtb2ZmLWJ5
OiBEYXZpZCBIaWxkZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT4NCj4gLS0tDQo+ICBtbS9tZW1v
cnlfaG90cGx1Zy5jIHwgMTAgKysrKysrKy0tLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDcgaW5zZXJ0
aW9ucygrKSwgMyBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9tZW1vcnlfaG90
cGx1Zy5jIGIvbW0vbWVtb3J5X2hvdHBsdWcuYw0KPiBpbmRleCAwOTBjZjQ3NGRlODcuLjMwZDJm
YTQyYjBiYiAxMDA2NDQNCj4gLS0tIGEvbW0vbWVtb3J5X2hvdHBsdWcuYw0KPiArKysgYi9tbS9t
ZW1vcnlfaG90cGx1Zy5jDQo+IEBAIC04OTcsNiArODk3LDExIEBAIGludCBfX3JlZiBvbmxpbmVf
cGFnZXModW5zaWduZWQgbG9uZyBwZm4sIHVuc2lnbmVkIGxvbmcgbnJfcGFnZXMsIGludCBvbmxp
bmVfdHlwDQo+ICAJc3RydWN0IG1lbW9yeV9ub3RpZnkgYXJnOw0KPiAgCXN0cnVjdCBtZW1vcnlf
YmxvY2sgKm1lbTsNCj4gIA0KPiArCWlmICghSVNfQUxJR05FRChwZm4sIFBBR0VTX1BFUl9TRUNU
SU9OKSkNCj4gKwkJcmV0dXJuIC1FSU5WQUw7DQo+ICsJaWYgKCFJU19BTElHTkVEKG5yX3BhZ2Vz
LCBQQUdFU19QRVJfU0VDVElPTikpDQo+ICsJCXJldHVybiAtRUlOVkFMOw0KPiArDQo+ICAJLyoN
Cj4gIAkgKiBXZSBjYW4ndCB1c2UgcGZuX3RvX25pZCgpIGJlY2F1c2UgbmlkIG1pZ2h0IGJlIHN0
b3JlZCBpbiBzdHJ1Y3QgcGFnZQ0KPiAgCSAqIHdoaWNoIGlzIG5vdCB5ZXQgaW5pdGlhbGl6ZWQu
IEluc3RlYWQsIHdlIGZpbmQgbmlkIGZyb20gbWVtb3J5IGJsb2NrLg0KPiBAQCAtMTYwMCwxMCAr
MTYwNSw5IEBAIGludCBvZmZsaW5lX3BhZ2VzKHVuc2lnbmVkIGxvbmcgc3RhcnRfcGZuLCB1bnNp
Z25lZCBsb25nIG5yX3BhZ2VzKQ0KPiAgCXN0cnVjdCB6b25lICp6b25lOw0KPiAgCXN0cnVjdCBt
ZW1vcnlfbm90aWZ5IGFyZzsNCj4gIA0KPiAtCS8qIGF0IGxlYXN0LCBhbGlnbm1lbnQgYWdhaW5z
dCBwYWdlYmxvY2sgaXMgbmVjZXNzYXJ5ICovDQo+IC0JaWYgKCFJU19BTElHTkVEKHN0YXJ0X3Bm
biwgcGFnZWJsb2NrX25yX3BhZ2VzKSkNCj4gKwlpZiAoIUlTX0FMSUdORUQoc3RhcnRfcGZuLCBQ
QUdFU19QRVJfU0VDVElPTikpDQo+ICAJCXJldHVybiAtRUlOVkFMOw0KPiAtCWlmICghSVNfQUxJ
R05FRChlbmRfcGZuLCBwYWdlYmxvY2tfbnJfcGFnZXMpKQ0KPiArCWlmICghSVNfQUxJR05FRChu
cl9wYWdlcywgUEFHRVNfUEVSX1NFQ1RJT04pKQ0KPiAgCQlyZXR1cm4gLUVJTlZBTDsNCj4gIAkv
KiBUaGlzIG1ha2VzIGhvdHBsdWcgbXVjaCBlYXNpZXIuLi5hbmQgcmVhZGFibGUuDQo+ICAJICAg
d2UgYXNzdW1lIHRoaXMgZm9yIG5vdy4gLiovDQo+IA==
