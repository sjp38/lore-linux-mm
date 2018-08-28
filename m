Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF63A6B46A3
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:04:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h20-v6so1412619iob.20
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:04:23 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0105.outbound.protection.outlook.com. [104.47.32.105])
        by mx.google.com with ESMTPS id 65-v6si792760jat.123.2018.08.28.07.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 07:04:22 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v4 3/4] mm/memory_hotplug: Define nodemask_t as a stack
 variable
Date: Tue, 28 Aug 2018 14:04:18 +0000
Message-ID: <cc7e1bac-2efb-b23f-bd76-8e836abeba0e@microsoft.com>
References: <20180817090017.17610-1-osalvador@techadventures.net>
 <20180817090017.17610-4-osalvador@techadventures.net>
In-Reply-To: <20180817090017.17610-4-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4625BC5878357146B66649E77C2C3028@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "david@redhat.com" <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDgvMTcvMTggNTowMCBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IEZyb206IE9z
Y2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gDQo+IEN1cnJlbnRseSwgdW5yZWdp
c3Rlcl9tZW1fc2VjdF91bmRlcl9ub2RlcygpIHRyaWVzIHRvIGFsbG9jYXRlIGEgbm9kZW1hc2tf
dA0KPiBpbiBvcmRlciB0byBjaGVjayB3aGl0aGluIHRoZSBsb29wIHdoaWNoIG5vZGVzIGhhdmUg
YWxyZWFkeSBiZWVuIHVubGlua2VkLA0KPiBzbyB3ZSBkbyBub3QgcmVwZWF0IHRoZSBvcGVyYXRp
b24gb24gdGhlbS4NCj4gDQo+IE5PREVNQVNLX0FMTE9DIGNhbGxzIGttYWxsb2MoKSBpZiBOT0RF
U19TSElGVCA+IDgsIG90aGVyd2lzZQ0KPiBpdCBqdXN0IGRlY2xhcmVzIGEgbm9kZW1hc2tfdCB2
YXJpYWJsZSB3aGl0aGluIHRoZSBzdGFjay4NCj4gDQo+IFNpbmNlIGttYWxsb2MoKSBjYW4gZmFp
bCwgd2UgYWN0dWFsbHkgY2hlY2sgd2hldGhlciBOT0RFTUFTS19BTExPQyBmYWlsZWQNCj4gb3Ig
bm90LCBhbmQgd2UgcmV0dXJuIC1FTk9NRU0gYWNjb3JkaW5nbHkuDQo+IHJlbW92ZV9tZW1vcnlf
c2VjdGlvbigpIGRvZXMgbm90IGNoZWNrIGZvciB0aGUgcmV0dXJuIHZhbHVlIHRob3VnaC4NCj4g
SXQgaXMgcHJldHR5IHJhcmUgdGhhdCBzdWNoIGEgdGlueSBhbGxvY2F0aW9uIGNhbiBmYWlsLCBi
dXQgaWYgaXQgZG9lcywNCj4gd2Ugd2lsbCBiZSBsZWZ0IHdpdGggZGFuZ2xlZCBzeW1saW5rcyB1
bmRlciAvc3lzL2RldmljZXMvc3lzdGVtL25vZGUvLA0KPiBzaW5jZSB0aGUgbWVtX2JsaydzIGRp
cmVjdG9yaWVzIHdpbGwgYmUgcmVtb3ZlZCBubyBtYXR0ZXIgd2hhdA0KPiB1bnJlZ2lzdGVyX21l
bV9zZWN0X3VuZGVyX25vZGVzKCkgcmV0dXJucy4NCj4gDQo+IE9uZSB3YXkgdG8gc29sdmUgdGhp
cyBpcyB0byBjaGVjayB3aGV0aGVyIHVubGlua2VkX25vZGVzIGlzIE5VTEwgb3Igbm90Lg0KPiBJ
biB0aGUgY2FzZSBpdCBpcyBub3QsIHdlIGNhbiBqdXN0IHVzZSBpdCBhcyBiZWZvcmUsIGJ1dCBp
ZiBpdCBpcyBOVUxMLA0KPiB3ZSBjYW4ganVzdCBza2lwIHRoZSBub2RlX3Rlc3RfYW5kX3NldCBj
aGVjaywgYW5kIGNhbGwgc3lzZnNfcmVtb3ZlX2xpbmsoKQ0KPiB1bmNvbmRpdGlvbmFsbHkuDQo+
IFRoaXMgaXMgaGFybWxlc3MgYXMgc3lzZnNfcmVtb3ZlX2xpbmsoKSBiYWNrcyBvZmYgc29tZXdo
ZXJlIGRvd24gdGhlIGNoYWluDQo+IGluIGNhc2UgdGhlIGxpbmsgaGFzIGFscmVhZHkgYmVlbiBy
ZW1vdmVkLg0KPiBUaGlzIG1ldGhvZCB3YXMgcHJlc2VudGVkIGluIHYzIG9mIHRoZSBwYXRoIFsx
XS4NCj4gDQo+IEJ1dCBzaW5jZSB0aGUgbWF4aW11bSBudW1iZXIgb2Ygbm9kZXMgd2UgY2FuIGhh
dmUgaXMgMTAyNCwNCj4gd2hlbiBOT0RFU19TSElGVCA9IDEwLCB0aGF0IGdpdmVzIHVzIGEgbm9k
ZW1hc2tfdCBvZiAxMjggYnl0ZXMuDQo+IEFsdGhvdWdoIGV2ZXJ5dGhpbmcgZGVwZW5kcyBvbiBo
b3cgZGVlcCB0aGUgc3RhY2sgaXMsIEkgdGhpbmsgd2UgY2FuIGFmZm9yZA0KPiB0byBkZWZpbmUg
dGhlIG5vZGVtYXNrX3QgdmFyaWFibGUgd2hpdGhpbiB0aGUgc3RhY2suDQo+IA0KPiBUaGF0IHNp
bXBsaWZpZXMgdGhlIGNvZGUsIGFuZCB3ZSBkbyBub3QgbmVlZCB0byB3b3JyeSBhYm91dCB1bnRl
c3RlZCBlcnJvcg0KPiBjb2RlIHBhdGhzLg0KPiANCj4gSWYgd2Ugc2VlIHRoYXQgdGhpcyBjYXVz
ZXMgdHJvdWJsZXMgd2l0aCB0aGUgc3RhY2ssIHdlIGNhbiBhbHdheXMgcmV0dXJuIHRvIFsxXS4N
Cj4gDQo+IFNpZ25lZC1vZmYtYnk6IE9zY2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4N
Cg0KTEdUTToNCg0KUmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBt
aWNyb3NvZnQuY29tPg0KDQpUaGFuayB5b3UsDQpQYXZlbA==
