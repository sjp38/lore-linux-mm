Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1446B054A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:03:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f9so7050492pgs.13
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:03:48 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q21-v6si1664949plr.359.2018.11.07.12.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:03:47 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v8 1/4] vmalloc: Add __vmalloc_node_try_addr function
Date: Wed, 7 Nov 2018 20:03:45 +0000
Message-ID: <7e7fdb81bd2ed9ca9514a97d44683bfa1267a55d.camel@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	 <20181102192520.4522-2-rick.p.edgecombe@intel.com>
	 <20181106130511.9ebeb5a09aba15dfee2f7f3d@linux-foundation.org>
In-Reply-To: <20181106130511.9ebeb5a09aba15dfee2f7f3d@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C165EA883338BB4599B26B6BAD25AFBC@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "jannh@google.com" <jannh@google.com>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVHVlLCAyMDE4LTExLTA2IGF0IDEzOjA1IC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBGcmksICAyIE5vdiAyMDE4IDEyOjI1OjE3IC0wNzAwIFJpY2sgRWRnZWNvbWJlIDxyaWNr
LnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiA+IENyZWF0ZSBfX3ZtYWxs
b2Nfbm9kZV90cnlfYWRkciBmdW5jdGlvbiB0aGF0IHRyaWVzIHRvIGFsbG9jYXRlIGF0IGEgc3Bl
Y2lmaWMNCj4gPiBhZGRyZXNzIHdpdGhvdXQgdHJpZ2dlcmluZyBhbnkgbGF6eSBwdXJnaW5nLiBJ
biBvcmRlciB0byBzdXBwb3J0IHRoaXMNCj4gPiBiZWhhdmlvcg0KPiA+IGEgdHJ5X2FkZHIgYXJn
dW1lbnQgd2FzIHBsdWdnZWQgaW50byBzZXZlcmFsIG9mIHRoZSBzdGF0aWMgaGVscGVycy4NCj4g
DQo+IFBsZWFzZSBleHBsYWluIChpbiB0aGUgY2hhbmdlbG9nKSB3aHkgbGF6eSBwdXJnaW5nIGlz
IGNvbnNpZGVyZWQgdG8gYmUNCj4gYSBwcm9ibGVtLiAgUHJlZmVyYWJseSB3aXRoIHNvbWUgZm9y
bSBvZiBtZWFzdXJlbWVudHMsIG9yIGF0IGxlYXN0IGENCj4gaGFuZC13YXZ5IGd1ZXNzdGltYXRl
IG9mIHRoZSBjb3N0Lg0KU3VyZSwgSWxsIHVwZGF0ZSBpdCB0byBiZSBtb3JlIGNsZWFyLiBUaGUg
cHJvYmxlbSBpcyB0aGF0IHdoZW4NCl9fdm1hbGxvY19ub2RlX3JhbmdlIGZhaWxzIHRvIGFsbG9j
YXRlIChpbiB0aGlzIGNhc2UgdHJpZXMgaW4gYSBzaW5nbGUgcmFuZG9tDQpzcG90IHRoYXQgZG9l
c24ndCBmaXQpLCBpdCB0cmlnZ2VycyBhIHB1cmdlX3ZtYXBfYXJlYV9sYXp5IGFuZCB0aGVuIHJl
dHJpZXMgdGhlDQphbGxvY2F0aW9uIGluIHRoZSBzYW1lIHNwb3QuIEl0IGRvZXNuJ3QgbWFrZSBh
cyBtdWNoIHNlbnNlIGluIHRoaXMgY2FzZSB3aGVuIHdlDQphcmUgbm90IHRyeWluZyBvdmVyIGEg
bGFyZ2UgYXJlYS4gV2hpbGUgaXQgd2lsbCB1c3VhbGx5IG5vdCBmbHVzaCB0aGUgVExCLCBpdA0K
ZG9lcyBkbyBleHRyYSB3b3JrIGV2ZXJ5IHRpbWUgZm9yIGFuIHVubGlrZWx5IGNhc2UgaW4gdGhp
cyBzaXR1YXRpb24gb2YgYSBsYXp5DQpmcmVlIGFyZWEgYmxvY2tpbmcgdGhlIGFsbG9jYXRpb24u
DQoNClRoZSBhdmVyYWdlIGFsbG9jYXRpb24gdGltZSBpbiBucyBmb3IgZGlmZmVyZW50IHZlcnNp
b25zIG1lYXN1cmVkIGJ5IHRoZQ0KaW5jbHVkZWQga3NlbGZ0ZXN0Og0KDQpNb2R1bGVzCVZtYWxs
b2Mgb3B0aW1pemF0aW9uCU5vIFZtYWxsb2MgT3B0aW1pemF0aW9uCUV4aXN0aW5nIE1vZHVsZSBL
QVNMUg0KMTAwMAkxNDMzCQkJMTk5MwkJCTM4MjENCjIwMDAJMjI5NQkJCTM2ODEJCQk3ODMwDQoz
MDAwCTQ0MjQJCQk3NDUwCQkJMTMwMTINCjQwMDAJNzc0NgkJCTEzODI0CQkJMTgxMDYNCjUwMDAJ
MTI3MjEJCQkyMTg1MgkJCTIyNTcyDQo2MDAwCTE5NzI0CQkJMzM5MjYJCQkyNjQ0Mw0KNzAwMAky
NzYzOAkJCTQ3NDI3CQkJMzA0NzMNCjgwMDAJMzc3NDUJCQk2NDQ0MwkJCTM0MjAwDQoNClRoZSBv
dGhlciBvcHRpbWl6YXRpb24gaXMgbm90IGttYWxsb2MtaW5nIGluIF9fZ2V0X3ZtX2FyZWFfbm9k
ZSB1bnRpbCBhZnRlciB0aGUNCmFkZHJlc3Mgd2FzIHRyaWVkLCB3aGljaCBJSVJDIGhhZCBhIHNt
YWxsZXIgYnV0IHN0aWxsIG5vdGljZWFibGUgcGVyZm9ybWFuY2UNCmJvb3N0Lg0KDQpUaGVzZSBh
bGxvY2F0aW9ucyBhcmUgbm90IHRha2luZyB2ZXJ5IGxvbmcsIGJ1dCBpdCBtYXkgc2hvdyB1cCBv
biBzeXN0ZW1zIHdpdGgNCnZlcnkgaGlnaCB1c2FnZSBvZiB0aGUgbW9kdWxlIHNwYWNlIChCUEYg
SklUcykuIElmIHRoZSB0cmFkZS1vZmYgb2YgdG91Y2hpbmcNCnZtYWxsb2MgZG9lc24ndCBzZWVt
IHdvcnRoIGl0IHRvIHBlb3BsZSwgSSdtIGhhcHB5IHRvIHJlbW92ZSB0aGUgb3B0aW1pemF0aW9u
cy4NCg0KPiA+IFRoaXMgYWxzbyBjaGFuZ2VzIGxvZ2ljIGluIF9fZ2V0X3ZtX2FyZWFfbm9kZSB0
byBiZSBmYXN0ZXIgaW4gY2FzZXMgd2hlcmUNCj4gPiBhbGxvY2F0aW9ucyBmYWlsIGR1ZSB0byBu
byBzcGFjZSwgd2hpY2ggaXMgYSBsb3QgbW9yZSBjb21tb24gd2hlbiB0cnlpbmcNCj4gPiBzcGVj
aWZpYyBhZGRyZXNzZXMuDQo=
