Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0B626B0010
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:34:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id n11-v6so22487plp.22
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:34:56 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0054.outbound.protection.outlook.com. [104.47.36.54])
        by mx.google.com with ESMTPS id k127si426232pga.173.2018.03.23.12.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 12:34:55 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
Date: Fri, 23 Mar 2018 19:34:52 +0000
Message-ID: <D608FB5E-5254-4233-98DC-605EDEF24E9E@vmware.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174454.CD00F614@viggo.jf.intel.com>
 <224464E0-1D3A-4ED8-88E0-A8E84C4265FC@vmware.com>
 <ed72b04d-de86-113e-ab45-e1577e5c4226@linux.intel.com>
In-Reply-To: <ed72b04d-de86-113e-ab45-e1577e5c4226@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <2EB38185BFE5A54390E4C4B9E40A7300@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

RGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGxpbnV4LmludGVsLmNvbT4gd3JvdGU6DQoNCj4gT24g
MDMvMjMvMjAxOCAxMjoxNSBQTSwgTmFkYXYgQW1pdCB3cm90ZToNCj4+PiBBIFBURSBpcyBjb25z
dHJ1Y3RlZCBmcm9tIGEgcGh5c2ljYWwgYWRkcmVzcyBhbmQgYSBwZ3Byb3R2YWxfdC4NCj4+PiBf
X1BBR0VfS0VSTkVMLCBmb3IgaW5zdGFuY2UsIGlzIGEgcGdwcm90X3QgYW5kIG11c3QgYmUgY29u
dmVydGVkDQo+Pj4gaW50byBhIHBncHJvdHZhbF90IGJlZm9yZSBpdCBjYW4gYmUgdXNlZCB0byBj
cmVhdGUgYSBQVEUuICBUaGlzIGlzDQo+Pj4gZG9uZSBpbXBsaWNpdGx5IHdpdGhpbiBmdW5jdGlv
bnMgbGlrZSBzZXRfcHRlKCkgYnkgbWFzc2FnZV9wZ3Byb3QoKS4NCj4+PiANCj4+PiBIb3dldmVy
LCB0aGlzIG1ha2VzIGl0IHZlcnkgY2hhbGxlbmdpbmcgdG8gc2V0IGJpdHMgKGFuZCBrZWVwIHRo
ZW0NCj4+PiBzZXQpIGlmIHlvdXIgYml0IGlzIGJlaW5nIGZpbHRlcmVkIG91dCBieSBtYXNzYWdl
X3BncHJvdCgpLg0KPj4+IA0KPj4+IFRoaXMgbW92ZXMgdGhlIGJpdCBmaWx0ZXJpbmcgb3V0IG9m
IHNldF9wdGUoKSBhbmQgZnJpZW5kcy4gIEZvcg0KPj4gDQo+PiBJIGRvbuKAmXQgc2VlIHRoYXQg
c2V0X3B0ZSgpIGZpbHRlcnMgdGhlIGJpdHMsIHNvIEkgYW0gY29uZnVzZWQgYnkgdGhpcw0KPj4g
c2VudGVuY2UuLi4NCj4gDQo+IFRoaXMgd2FzIGEgdHlwby90aGlua28uICBJdCBzaG91bGQgYmUg
cGZuX3B0ZSgpLg0KPiANCj4+PiArc3RhdGljIGlubGluZSBwZ3Byb3R2YWxfdCBjaGVja19wZ3By
b3QocGdwcm90X3QgcGdwcm90KQ0KPj4+ICt7DQo+Pj4gKwlwZ3Byb3R2YWxfdCBtYXNzYWdlZF92
YWwgPSBtYXNzYWdlX3BncHJvdChwZ3Byb3QpOw0KPj4+ICsNCj4+PiArCS8qIG1tZGVidWcuaCBj
YW4gbm90IGJlIGluY2x1ZGVkIGhlcmUgYmVjYXVzZSBvZiBkZXBlbmRlbmNpZXMgKi8NCj4+PiAr
I2lmZGVmIENPTkZJR19ERUJVR19WTQ0KPj4+ICsJV0FSTl9PTkNFKHBncHJvdF92YWwocGdwcm90
KSAhPSBtYXNzYWdlZF92YWwsDQo+Pj4gKwkJICAiYXR0ZW1wdGVkIHRvIHNldCB1bnN1cHBvcnRl
ZCBwZ3Byb3Q6ICUwMTZseCAiDQo+Pj4gKwkJICAiYml0czogJTAxNmx4IHN1cHBvcnRlZDogJTAx
Nmx4XG4iLA0KPj4+ICsJCSAgcGdwcm90X3ZhbChwZ3Byb3QpLA0KPj4+ICsJCSAgcGdwcm90X3Zh
bChwZ3Byb3QpIF4gbWFzc2FnZWRfdmFsLA0KPj4+ICsJCSAgX19zdXBwb3J0ZWRfcHRlX21hc2sp
Ow0KPj4+ICsjZW5kaWYNCj4+IFdoeSBub3QgdG8gdXNlIFZNX1dBUk5fT05fT05DRSgpIGFuZCBh
dm9pZCB0aGUgaWZkZWY/DQo+IA0KPiBJIHdhbnRlZCBhIG1lc3NhZ2UuICBWTV9XQVJOX09OX09O
Q0UoKSBkb2Vzbid0IGxldCB5b3UgZ2l2ZSBhIG1lc3NhZ2UuDQoNClJpZ2h0IChteSBiYWQpLiBC
dXQgVk1fV0FSTl9PTkNFKCkgbGV0cyB5b3UuDQoNCg0K
