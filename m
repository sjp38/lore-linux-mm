Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBB06B6BB9
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 19:04:24 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so7876514pgc.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 16:04:24 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b17si12695212pgk.581.2018.12.03.16.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 16:04:22 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Date: Tue, 4 Dec 2018 00:04:21 +0000
Message-ID: <f00a7c0b99cb3dae3f42e144c0532a6a299c06a0.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20181128000754.18056-2-rick.p.edgecombe@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DD455A0478EDF040A61027CE85944E93@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Dock, Deneen" T" <deneen.t.dock@intel.com>, "daniel@iogearbox.net, " <daniel@iogearbox.net>, rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "jeyu@kernel.org" <jeyu@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>

SXQgbG9va3MgbGlrZSB0aGlzIG5ldyBmbGFnIGlzIGluIGxpbnV4LW5leHQgbm93LiBBcyBJIGFt
IHJlYWRpbmcgaXQsIHRoZXNlDQphcmNoaXRlY3R1cmVzIGhhdmUgYSBtb2R1bGVfYWxsb2MgdGhh
dCB1c2VzIHNvbWUgc29ydCBvZiBleGVjdXRhYmxlIGZsYWcgYW5kDQphcmUgbm90IHVzaW5nIHRo
ZSBkZWZhdWx0IG1vZHVsZV9hbGxvYyB3aGljaCBpcyBhbHJlYWR5IGNvdmVyZWQsIGFuZCBzbyBt
YXkgbmVlZA0KaXQgcGx1Z2dlZCBpbjoNCmFybQ0KYXJtNjQNCnBhcmlzYw0KczM5MA0KdW5pY29y
ZTMyDQoNClRoYW5rcywNCg0KUmljaw0KDQpPbiBUdWUsIDIwMTgtMTEtMjcgYXQgMTY6MDcgLTA4
MDAsIFJpY2sgRWRnZWNvbWJlIHdyb3RlOg0KPiBTaW5jZSB2ZnJlZSB3aWxsIGxhemlseSBmbHVz
aCB0aGUgVExCLCBidXQgbm90IGxhemlseSBmcmVlIHRoZSB1bmRlcmx5aW5nDQo+IHBhZ2VzLA0K
PiBpdCBvZnRlbiBsZWF2ZXMgc3RhbGUgVExCIGVudHJpZXMgdG8gZnJlZWQgcGFnZXMgdGhhdCBj
b3VsZCBnZXQgcmUtdXNlZC4gVGhpcw0KPiBpcw0KPiB1bmRlc2lyYWJsZSBmb3IgY2FzZXMgd2hl
cmUgdGhlIG1lbW9yeSBiZWluZyBmcmVlZCBoYXMgc3BlY2lhbCBwZXJtaXNzaW9ucw0KPiBzdWNo
DQo+IGFzIGV4ZWN1dGFibGUuDQo+IA0KPiBIYXZpbmcgY2FsbGVycyBmbHVzaCB0aGUgVExCIGFm
dGVyIGNhbGxpbmcgdmZyZWUgc3RpbGwgbGVhdmVzIGEgd2luZG93IHdoZXJlDQo+IHRoZSBwYWdl
cyBhcmUgZnJlZWQsIGJ1dCB0aGUgVExCIGVudHJ5IHJlbWFpbnMuIEFsc28gdGhlIGVudGlyZSBv
cGVyYXRpb24gY2FuDQo+IGJlDQo+IGRlZmVycmVkIGlmIHRoZSB2ZnJlZSBpcyBjYWxsZWQgZnJv
bSBhbiBpbnRlcnJ1cHQgYW5kIHNvIGEgVExCIGZsdXNoIGFmdGVyDQo+IGNhbGxpbmcgdmZyZWUg
d291bGQgbWlzcyB0aGUgZW50aXJlIG9wZXJhdGlvbi4gU28gaW4gb3JkZXIgdG8gc3VwcG9ydCB0
aGlzIHVzZQ0KPiBjYXNlLCBhIG5ldyBmbGFnIFZNX0lNTUVESUFURV9VTk1BUCBpcyBhZGRlZCwg
dGhhdCB3aWxsIGNhdXNlIHRoZSBmcmVlDQo+IG9wZXJhdGlvbg0KPiB0byB0YWtlIHBsYWNlIGxp
a2UgdGhpczoNCj4gICAgICAgICAxLiBVbm1hcA0KPiAgICAgICAgIDIuIEZsdXNoIFRMQi9Vbm1h
cCBhbGlhc2VzDQo+ICAgICAgICAgMy4gRnJlZSBwYWdlcw0KPiBJbiB0aGUgZGVmZXJyZWQgY2Fz
ZSB0aGVzZSBzdGVwcyBhcmUgYWxsIGRvbmUgYnkgdGhlIHdvcmsgcXVldWUuDQo+IA0KPiBUaGlz
IGltcGxlbWVudGF0aW9uIGRlcml2ZXMgZnJvbSB0d28gc2tldGNoZXMgZnJvbSBEYXZlIEhhbnNl
biBhbmQNCj4gQW5keSBMdXRvbWlyc2tpLg0KPiANCj4gU3VnZ2VzdGVkLWJ5OiBEYXZlIEhhbnNl
biA8ZGF2ZS5oYW5zZW5AaW50ZWwuY29tPg0KPiBTdWdnZXN0ZWQtYnk6IEFuZHkgTHV0b21pcnNr
aSA8bHV0b0BrZXJuZWwub3JnPg0KPiBTdWdnZXN0ZWQtYnk6IFdpbGwgRGVhY29uIDx3aWxsLmRl
YWNvbkBhcm0uY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBSaWNrIEVkZ2Vjb21iZSA8cmljay5wLmVk
Z2Vjb21iZUBpbnRlbC5jb20+DQo+IC0tLQ0KPiAgaW5jbHVkZS9saW51eC92bWFsbG9jLmggfCAg
MSArDQo+ICBtbS92bWFsbG9jLmMgICAgICAgICAgICB8IDEzICsrKysrKysrKysrLS0NCj4gIDIg
ZmlsZXMgY2hhbmdlZCwgMTIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRp
ZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L3ZtYWxsb2MuaCBiL2luY2x1ZGUvbGludXgvdm1hbGxv
Yy5oDQo+IGluZGV4IDM5OGU5Yzk1Y2Q2MS4uY2NhNmI2YjgzY2YwIDEwMDY0NA0KPiAtLS0gYS9p
bmNsdWRlL2xpbnV4L3ZtYWxsb2MuaA0KPiArKysgYi9pbmNsdWRlL2xpbnV4L3ZtYWxsb2MuaA0K
PiBAQCAtMjEsNiArMjEsNyBAQCBzdHJ1Y3Qgbm90aWZpZXJfYmxvY2s7CQkvKiBpbiBub3RpZmll
ci5oICovDQo+ICAjZGVmaW5lIFZNX1VOSU5JVElBTElaRUQJMHgwMDAwMDAyMAkvKiB2bV9zdHJ1
Y3QgaXMgbm90IGZ1bGx5DQo+IGluaXRpYWxpemVkICovDQo+ICAjZGVmaW5lIFZNX05PX0dVQVJE
CQkweDAwMDAwMDQwICAgICAgLyogZG9uJ3QgYWRkIGd1YXJkIHBhZ2UgKi8NCj4gICNkZWZpbmUg
Vk1fS0FTQU4JCTB4MDAwMDAwODAgICAgICAvKiBoYXMgYWxsb2NhdGVkIGthc2FuIHNoYWRvdw0K
PiBtZW1vcnkgKi8NCj4gKyNkZWZpbmUgVk1fSU1NRURJQVRFX1VOTUFQCTB4MDAwMDAyMDAJLyog
Zmx1c2ggYmVmb3JlIHJlbGVhc2luZw0KPiBwYWdlcyAqLw0KPiAgLyogYml0cyBbMjAuLjMyXSBy
ZXNlcnZlZCBmb3IgYXJjaCBzcGVjaWZpYyBpb3JlbWFwIGludGVybmFscyAqLw0KPiAgDQo+ICAv
Kg0KPiBkaWZmIC0tZ2l0IGEvbW0vdm1hbGxvYy5jIGIvbW0vdm1hbGxvYy5jDQo+IGluZGV4IDk3
ZDRiMjVkMDM3My4uNjg3NjY2NTFiNWE3IDEwMDY0NA0KPiAtLS0gYS9tbS92bWFsbG9jLmMNCj4g
KysrIGIvbW0vdm1hbGxvYy5jDQo+IEBAIC0xNTE2LDYgKzE1MTYsMTQgQEAgc3RhdGljIHZvaWQg
X192dW5tYXAoY29uc3Qgdm9pZCAqYWRkciwgaW50DQo+IGRlYWxsb2NhdGVfcGFnZXMpDQo+ICAJ
ZGVidWdfY2hlY2tfbm9fb2JqX2ZyZWVkKGFyZWEtPmFkZHIsIGdldF92bV9hcmVhX3NpemUoYXJl
YSkpOw0KPiAgDQo+ICAJcmVtb3ZlX3ZtX2FyZWEoYWRkcik7DQo+ICsNCj4gKwkvKg0KPiArCSAq
IE5lZWQgdG8gZmx1c2ggdGhlIFRMQiBiZWZvcmUgZnJlZWluZyBwYWdlcyBpbiB0aGUgY2FzZSBv
ZiB0aGlzIGZsYWcuDQo+ICsJICogQXMgbG9uZyBhcyB0aGF0J3MgaGFwcGVuaW5nLCB1bm1hcCBh
bGlhc2VzLg0KPiArCSAqLw0KPiArCWlmIChhcmVhLT5mbGFncyAmIFZNX0lNTUVESUFURV9VTk1B
UCkNCj4gKwkJdm1fdW5tYXBfYWxpYXNlcygpOw0KPiArDQo+ICAJaWYgKGRlYWxsb2NhdGVfcGFn
ZXMpIHsNCj4gIAkJaW50IGk7DQo+ICANCj4gQEAgLTE5MjUsOCArMTkzMyw5IEBAIEVYUE9SVF9T
WU1CT0wodnphbGxvY19ub2RlKTsNCj4gIA0KPiAgdm9pZCAqdm1hbGxvY19leGVjKHVuc2lnbmVk
IGxvbmcgc2l6ZSkNCj4gIHsNCj4gLQlyZXR1cm4gX192bWFsbG9jX25vZGUoc2l6ZSwgMSwgR0ZQ
X0tFUk5FTCwgUEFHRV9LRVJORUxfRVhFQywNCj4gLQkJCSAgICAgIE5VTUFfTk9fTk9ERSwgX19i
dWlsdGluX3JldHVybl9hZGRyZXNzKDApKTsNCj4gKwlyZXR1cm4gX192bWFsbG9jX25vZGVfcmFu
Z2Uoc2l6ZSwgMSwgVk1BTExPQ19TVEFSVCwgVk1BTExPQ19FTkQsDQo+ICsJCQlHRlBfS0VSTkVM
LCBQQUdFX0tFUk5FTF9FWEVDLCBWTV9JTU1FRElBVEVfVU5NQVAsDQo+ICsJCQlOVU1BX05PX05P
REUsIF9fYnVpbHRpbl9yZXR1cm5fYWRkcmVzcygwKSk7DQo+ICB9DQo+ICANCj4gICNpZiBkZWZp
bmVkKENPTkZJR182NEJJVCkgJiYgZGVmaW5lZChDT05GSUdfWk9ORV9ETUEzMikNCg==
