Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2174E8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 16:53:52 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k18-v6so9865463otl.16
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 13:53:52 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0107.outbound.protection.outlook.com. [104.47.42.107])
        by mx.google.com with ESMTPS id b34-v6si8690316oth.451.2018.09.20.13.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 13:53:50 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 1/5] mm/memory_hotplug: Spare unnecessary calls to
 node_set_state
Date: Thu, 20 Sep 2018 20:53:48 +0000
Message-ID: <b04deb3f-bc3c-c78d-2774-125fa450ac42@microsoft.com>
References: <20180919100819.25518-1-osalvador@techadventures.net>
 <20180919100819.25518-2-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-2-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <482BA3A9FCB2114BB20BA8C62017EB83@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDkvMTkvMTggNjowOCBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IEZyb206IE9z
Y2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gDQo+IEluIG5vZGVfc3RhdGVzX2No
ZWNrX2NoYW5nZXNfb25saW5lLCB3ZSBjaGVjayBpZiB0aGUgbm9kZSB3aWxsDQo+IGhhdmUgdG8g
YmUgc2V0IGZvciBhbnkgb2YgdGhlIE5fKl9NRU1PUlkgc3RhdGVzIGFmdGVyIHRoZSBwYWdlcw0K
PiBoYXZlIGJlZW4gb25saW5lZC4NCj4gDQo+IExhdGVyIG9uLCB3ZSBwZXJmb3JtIHRoZSBhY3Rp
dmF0aW9uIGluIG5vZGVfc3RhdGVzX3NldF9ub2RlLg0KPiBDdXJyZW50bHksIGluIG5vZGVfc3Rh
dGVzX3NldF9ub2RlIHdlIHNldCB0aGUgbm9kZSB0byBOX01FTU9SWQ0KPiB1bmNvbmRpdGlvbmFs
bHkuDQo+IFRoaXMgbWVhbnMgdGhhdCB3ZSBjYWxsIG5vZGVfc2V0X3N0YXRlIGZvciBOX01FTU9S
WSBldmVyeSB0aW1lDQo+IHBhZ2VzIGdvIG9ubGluZSwgYnV0IHdlIG9ubHkgbmVlZCB0byBkbyBp
dCBpZiB0aGUgbm9kZSBoYXMgbm90IHlldCBiZWVuDQo+IHNldCBmb3IgTl9NRU1PUlkuDQo+IA0K
PiBGaXggdGhpcyBieSBjaGVja2luZyBzdGF0dXNfY2hhbmdlX25pZC4NCj4gDQo+IFNpZ25lZC1v
ZmYtYnk6IE9zY2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCg0KUmV2aWV3ZWQtYnk6
IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg0KDQo+IC0tLQ0K
PiAgbW0vbWVtb3J5X2hvdHBsdWcuYyB8IDMgKystDQo+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNl
cnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5X2hv
dHBsdWcuYyBiL21tL21lbW9yeV9ob3RwbHVnLmMNCj4gaW5kZXggMzhkOTRiNzAzZTlkLi42M2Zh
Y2ZjNTcyMjQgMTAwNjQ0DQo+IC0tLSBhL21tL21lbW9yeV9ob3RwbHVnLmMNCj4gKysrIGIvbW0v
bWVtb3J5X2hvdHBsdWcuYw0KPiBAQCAtNzUzLDcgKzc1Myw4IEBAIHN0YXRpYyB2b2lkIG5vZGVf
c3RhdGVzX3NldF9ub2RlKGludCBub2RlLCBzdHJ1Y3QgbWVtb3J5X25vdGlmeSAqYXJnKQ0KPiAg
CWlmIChhcmctPnN0YXR1c19jaGFuZ2VfbmlkX2hpZ2ggPj0gMCkNCj4gIAkJbm9kZV9zZXRfc3Rh
dGUobm9kZSwgTl9ISUdIX01FTU9SWSk7DQo+ICANCj4gLQlub2RlX3NldF9zdGF0ZShub2RlLCBO
X01FTU9SWSk7DQo+ICsJaWYgKGFyZy0+c3RhdHVzX2NoYW5nZV9uaWQgPj0gMCkNCj4gKwkJbm9k
ZV9zZXRfc3RhdGUobm9kZSwgTl9NRU1PUlkpOw0KPiAgfQ0KPiAgDQo+ICBzdGF0aWMgdm9pZCBf
X21lbWluaXQgcmVzaXplX3pvbmVfcmFuZ2Uoc3RydWN0IHpvbmUgKnpvbmUsIHVuc2lnbmVkIGxv
bmcgc3RhcnRfcGZuLA0KPiA=
