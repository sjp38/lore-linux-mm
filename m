Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 660D68E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 19:40:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a26-v6so4753535pgw.7
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 16:40:42 -0700 (PDT)
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690108.outbound.protection.outlook.com. [40.107.69.108])
        by mx.google.com with ESMTPS id 72-v6si2489509pfo.229.2018.09.20.16.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 16:40:41 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 3/5] mm/memory_hotplug: Tidy up node_states_clear_node
Date: Thu, 20 Sep 2018 23:40:39 +0000
Message-ID: <73bf94f3-d53b-0123-0b1e-86fd00f66694@microsoft.com>
References: <20180919100819.25518-1-osalvador@techadventures.net>
 <20180919100819.25518-4-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-4-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <185D7EE10A691F46BD40E305BEFC8A01@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDkvMTkvMTggNjowOCBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IEZyb206IE9z
Y2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gDQo+IG5vZGVfc3RhdGVzX2NsZWFy
IGhhcyB0aGUgZm9sbG93aW5nIGlmIHN0YXRlbWVudHM6DQo+IA0KPiBpZiAoKE5fTUVNT1JZICE9
IE5fTk9STUFMX01FTU9SWSkgJiYNCj4gICAgIChhcmctPnN0YXR1c19jaGFuZ2VfbmlkX2hpZ2gg
Pj0gMCkpDQo+ICAgICAgICAgLi4uDQo+IA0KPiBpZiAoKE5fTUVNT1JZICE9IE5fSElHSF9NRU1P
UlkpICYmDQo+ICAgICAoYXJnLT5zdGF0dXNfY2hhbmdlX25pZCA+PSAwKSkNCj4gICAgICAgICAu
Li4NCj4gDQo+IE5fTUVNT1JZIGNhbiBuZXZlciBiZSBlcXVhbCB0byBuZWl0aGVyIE5fTk9STUFM
X01FTU9SWSBub3INCj4gTl9ISUdIX01FTU9SWS4NCj4gDQo+IFNpbWlsYXIgcHJvYmxlbSB3YXMg
Zm91bmQgaW4gWzFdLg0KPiBTaW5jZSB0aGlzIGlzIHdyb25nLCBsZXQgdXMgZ2V0IHJpZCBvZiBp
dC4NCj4gDQo+IFsxXSBodHRwczovL25hMDEuc2FmZWxpbmtzLnByb3RlY3Rpb24ub3V0bG9vay5j
b20vP3VybD1odHRwcyUzQSUyRiUyRnBhdGNod29yay5rZXJuZWwub3JnJTJGcGF0Y2glMkYxMDU3
OTE1NSUyRiZhbXA7ZGF0YT0wMiU3QzAxJTdDUGF2ZWwuVGF0YXNoaW4lNDBtaWNyb3NvZnQuY29t
JTdDMWUzMWU2YTVjODc1NGFiZTBiNDYwOGQ2MWUxN2UwMWMlN0M3MmY5ODhiZjg2ZjE0MWFmOTFh
YjJkN2NkMDExZGI0NyU3QzElN0MwJTdDNjM2NzI5NDg1MjQxMzY3NTg0JmFtcDtzZGF0YT16dGtQ
TnlSSXYyYzBqNWxydWp3R00lMkZyRDVpbjZHN0F2dmRxeFZYQ3p3R3MlM0QmYW1wO3Jlc2VydmVk
PTANCj4gDQo+IFNpZ25lZC1vZmYtYnk6IE9zY2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5k
ZT4NCg0KUmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3Nv
ZnQuY29tPg0KDQo+IC0tLQ0KPiAgbW0vbWVtb3J5X2hvdHBsdWcuYyB8IDYgKystLS0tDQo+ICAx
IGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlm
ZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1vcnlfaG90cGx1Zy5jDQo+IGlu
ZGV4IGMyYzczNTliZDBhNy4uMTMxYzA4MTA2ZDU0IDEwMDY0NA0KPiAtLS0gYS9tbS9tZW1vcnlf
aG90cGx1Zy5jDQo+ICsrKyBiL21tL21lbW9yeV9ob3RwbHVnLmMNCj4gQEAgLTE1OTAsMTIgKzE1
OTAsMTAgQEAgc3RhdGljIHZvaWQgbm9kZV9zdGF0ZXNfY2xlYXJfbm9kZShpbnQgbm9kZSwgc3Ry
dWN0IG1lbW9yeV9ub3RpZnkgKmFyZykNCj4gIAlpZiAoYXJnLT5zdGF0dXNfY2hhbmdlX25pZF9u
b3JtYWwgPj0gMCkNCj4gIAkJbm9kZV9jbGVhcl9zdGF0ZShub2RlLCBOX05PUk1BTF9NRU1PUlkp
Ow0KPiAgDQo+IC0JaWYgKChOX01FTU9SWSAhPSBOX05PUk1BTF9NRU1PUlkpICYmDQo+IC0JICAg
IChhcmctPnN0YXR1c19jaGFuZ2VfbmlkX2hpZ2ggPj0gMCkpDQo+ICsJaWYgKGFyZy0+c3RhdHVz
X2NoYW5nZV9uaWRfaGlnaCA+PSAwKQ0KPiAgCQlub2RlX2NsZWFyX3N0YXRlKG5vZGUsIE5fSElH
SF9NRU1PUlkpOw0KPiAgDQo+IC0JaWYgKChOX01FTU9SWSAhPSBOX0hJR0hfTUVNT1JZKSAmJg0K
PiAtCSAgICAoYXJnLT5zdGF0dXNfY2hhbmdlX25pZCA+PSAwKSkNCj4gKwlpZiAoYXJnLT5zdGF0
dXNfY2hhbmdlX25pZCA+PSAwKQ0KPiAgCQlub2RlX2NsZWFyX3N0YXRlKG5vZGUsIE5fTUVNT1JZ
KTsNCj4gIH0NCj4gIA0KPiA=
