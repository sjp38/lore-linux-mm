Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 486536B2CB1
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:55:21 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id e62-v6so5687940ywf.21
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:55:21 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810074.outbound.protection.outlook.com. [40.107.81.74])
        by mx.google.com with ESMTPS id n184si22833049ywn.314.2018.11.22.10.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Nov 2018 10:55:20 -0800 (PST)
From: "Koenig, Christian" <Christian.Koenig@amd.com>
Subject: Re: [PATCH 2/3] mm, notifier: Catch sleeping/blocking for !blockable
Date: Thu, 22 Nov 2018 18:55:17 +0000
Message-ID: <f9c39a9a-5afd-4aed-c9ad-0c3fef34a449@amd.com>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-3-daniel.vetter@ffwll.ch>
In-Reply-To: <20181122165106.18238-3-daniel.vetter@ffwll.ch>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4EC4BF4399C95F4382DBAFADB9310725@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

QW0gMjIuMTEuMTggdW0gMTc6NTEgc2NocmllYiBEYW5pZWwgVmV0dGVyOg0KPiBXZSBuZWVkIHRv
IG1ha2Ugc3VyZSBpbXBsZW1lbnRhdGlvbnMgZG9uJ3QgY2hlYXQgYW5kIGRvbid0IGhhdmUgYQ0K
PiBwb3NzaWJsZSBzY2hlZHVsZS9ibG9ja2luZyBwb2ludCBkZWVwbHkgYnVycmllZCB3aGVyZSBy
ZXZpZXcgY2FuJ3QNCj4gY2F0Y2ggaXQuDQo+DQo+IEknbSBub3Qgc3VyZSB3aGV0aGVyIHRoaXMg
aXMgdGhlIGJlc3Qgd2F5IHRvIG1ha2Ugc3VyZSBhbGwgdGhlDQo+IG1pZ2h0X3NsZWVwKCkgY2Fs
bHNpdGVzIHRyaWdnZXIsIGFuZCBpdCdzIGEgYml0IHVnbHkgaW4gdGhlIGNvZGUgZmxvdy4NCj4g
QnV0IGl0IGdldHMgdGhlIGpvYiBkb25lLg0KPg0KPiBDYzogQW5kcmV3IE1vcnRvbiA8YWtwbUBs
aW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gQ2M6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQHN1c2UuY29t
Pg0KPiBDYzogRGF2aWQgUmllbnRqZXMgPHJpZW50amVzQGdvb2dsZS5jb20+DQo+IENjOiAiQ2hy
aXN0aWFuIEvDtm5pZyIgPGNocmlzdGlhbi5rb2VuaWdAYW1kLmNvbT4NCj4gQ2M6IERhbmllbCBW
ZXR0ZXIgPGRhbmllbC52ZXR0ZXJAZmZ3bGwuY2g+DQo+IENjOiAiSsOpcsO0bWUgR2xpc3NlIiA8
amdsaXNzZUByZWRoYXQuY29tPg0KPiBDYzogbGludXgtbW1Aa3ZhY2sub3JnDQo+IFNpZ25lZC1v
ZmYtYnk6IERhbmllbCBWZXR0ZXIgPGRhbmllbC52ZXR0ZXJAaW50ZWwuY29tPg0KPiAtLS0NCj4g
ICBtbS9tbXVfbm90aWZpZXIuYyB8IDggKysrKysrKy0NCj4gICAxIGZpbGUgY2hhbmdlZCwgNyBp
bnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+DQo+IGRpZmYgLS1naXQgYS9tbS9tbXVfbm90
aWZpZXIuYyBiL21tL21tdV9ub3RpZmllci5jDQo+IGluZGV4IDU5ZTEwMjU4OWEyNS4uNGQyODJj
ZmIyOTZlIDEwMDY0NA0KPiAtLS0gYS9tbS9tbXVfbm90aWZpZXIuYw0KPiArKysgYi9tbS9tbXVf
bm90aWZpZXIuYw0KPiBAQCAtMTg1LDcgKzE4NSwxMyBAQCBpbnQgX19tbXVfbm90aWZpZXJfaW52
YWxpZGF0ZV9yYW5nZV9zdGFydChzdHJ1Y3QgbW1fc3RydWN0ICptbSwNCj4gICAJaWQgPSBzcmN1
X3JlYWRfbG9jaygmc3JjdSk7DQo+ICAgCWhsaXN0X2Zvcl9lYWNoX2VudHJ5X3JjdShtbiwgJm1t
LT5tbXVfbm90aWZpZXJfbW0tPmxpc3QsIGhsaXN0KSB7DQo+ICAgCQlpZiAobW4tPm9wcy0+aW52
YWxpZGF0ZV9yYW5nZV9zdGFydCkgew0KPiAtCQkJaW50IF9yZXQgPSBtbi0+b3BzLT5pbnZhbGlk
YXRlX3JhbmdlX3N0YXJ0KG1uLCBtbSwgc3RhcnQsIGVuZCwgYmxvY2thYmxlKTsNCj4gKwkJCWlu
dCBfcmV0Ow0KPiArDQo+ICsJCQlpZiAoSVNfRU5BQkxFRChDT05GSUdfREVCVUdfQVRPTUlDX1NM
RUVQKSAmJiAhYmxvY2thYmxlKQ0KPiArCQkJCXByZWVtcHRfZGlzYWJsZSgpOw0KPiArCQkJX3Jl
dCA9IG1uLT5vcHMtPmludmFsaWRhdGVfcmFuZ2Vfc3RhcnQobW4sIG1tLCBzdGFydCwgZW5kLCBi
bG9ja2FibGUpOw0KPiArCQkJaWYgKElTX0VOQUJMRUQoQ09ORklHX0RFQlVHX0FUT01JQ19TTEVF
UCkgJiYgIWJsb2NrYWJsZSkNCj4gKwkJCQlwcmVlbXB0X2VuYWJsZSgpOw0KDQpKdXN0IGZvciB0
aGUgc2FrZSBvZiBiZXR0ZXIgZG9jdW1lbnRpbmcgdGhpcyBob3cgYWJvdXQgYWRkaW5nIHRoaXMg
dG8gDQppbmNsdWRlL2xpbnV4L2tlcm5lbC5oIHJpZ2h0IG5leHQgdG8gbWlnaHRfc2xlZXAoKToN
Cg0KI2RlZmluZSBkaXNhbGxvd19zbGVlcGluZ19pZihjb25kKcKgwqDCoCBmb3IoKGNvbmQpID8g
cHJlZW1wdF9kaXNhYmxlKCkgOiANCih2b2lkKTA7IChjb25kKTsgcHJlZW1wdF9kaXNhYmxlKCkp
DQoNCihKdXN0IGZyb20gdGhlIGJhY2sgb2YgbXkgaGVhZCwgbWlnaHQgY29udGFpbiBwZWFudXRz
IGFuZC9vciBoaW50cyBvZiANCmVycm9ycykuDQoNCkNocmlzdGlhbi4NCg0KPiAgIAkJCWlmIChf
cmV0KSB7DQo+ICAgCQkJCXByX2luZm8oIiVwUyBjYWxsYmFjayBmYWlsZWQgd2l0aCAlZCBpbiAl
c2Jsb2NrYWJsZSBjb250ZXh0LlxuIiwNCj4gICAJCQkJCQltbi0+b3BzLT5pbnZhbGlkYXRlX3Jh
bmdlX3N0YXJ0LCBfcmV0LA0KDQo=
