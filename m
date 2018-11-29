Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 072616B4FA4
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 19:02:19 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so81275plt.7
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 16:02:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j20si113705pgh.224.2018.11.28.16.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 16:02:17 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 2/2] x86/modules: Make x86 allocs to flush when free
Date: Thu, 29 Nov 2018 00:02:15 +0000
Message-ID: <c4d6ce8af83ab9f92e76f36bce7ffa5574f7104b.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181128000754.18056-3-rick.p.edgecombe@intel.com>
	 <20181128151145.78a3d8b1f66f6b8fd66f0629@linux-foundation.org>
In-Reply-To: <20181128151145.78a3d8b1f66f6b8fd66f0629@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DD3C3FE40262C94EB56C735C4EBC5A4F@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gV2VkLCAyMDE4LTExLTI4IGF0IDE1OjExIC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBUdWUsIDI3IE5vdiAyMDE4IDE2OjA3OjU0IC0wODAwIFJpY2sgRWRnZWNvbWJlIDxyaWNr
LnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiA+IENoYW5nZSB0aGUgbW9k
dWxlIGFsbG9jYXRpb25zIHRvIGZsdXNoIGJlZm9yZSBmcmVlaW5nIHRoZSBwYWdlcy4NCj4gPiAN
Cj4gPiAuLi4NCj4gPiANCj4gPiAtLS0gYS9hcmNoL3g4Ni9rZXJuZWwvbW9kdWxlLmMNCj4gPiAr
KysgYi9hcmNoL3g4Ni9rZXJuZWwvbW9kdWxlLmMNCj4gPiBAQCAtODcsOCArODcsOCBAQCB2b2lk
ICptb2R1bGVfYWxsb2ModW5zaWduZWQgbG9uZyBzaXplKQ0KPiA+ICAJcCA9IF9fdm1hbGxvY19u
b2RlX3JhbmdlKHNpemUsIE1PRFVMRV9BTElHTiwNCj4gPiAgCQkJCSAgICBNT0RVTEVTX1ZBRERS
ICsgZ2V0X21vZHVsZV9sb2FkX29mZnNldCgpLA0KPiA+ICAJCQkJICAgIE1PRFVMRVNfRU5ELCBH
RlBfS0VSTkVMLA0KPiA+IC0JCQkJICAgIFBBR0VfS0VSTkVMX0VYRUMsIDAsIE5VTUFfTk9fTk9E
RSwNCj4gPiAtCQkJCSAgICBfX2J1aWx0aW5fcmV0dXJuX2FkZHJlc3MoMCkpOw0KPiA+ICsJCQkJ
ICAgIFBBR0VfS0VSTkVMX0VYRUMsIFZNX0lNTUVESUFURV9VTk1BUCwNCj4gPiArCQkJCSAgICBO
VU1BX05PX05PREUsIF9fYnVpbHRpbl9yZXR1cm5fYWRkcmVzcygwKSk7DQo+ID4gIAlpZiAocCAm
JiAoa2FzYW5fbW9kdWxlX2FsbG9jKHAsIHNpemUpIDwgMCkpIHsNCj4gPiAgCQl2ZnJlZShwKTsN
Cj4gPiAgCQlyZXR1cm4gTlVMTDsNCj4gDQo+IFNob3VsZCBhbnkgb3RoZXIgYXJjaGl0ZWN0dXJl
cyBkbyB0aGlzPw0KDQpJIHdvdWxkIHRoaW5rIGV2ZXJ5dGhpbmcgdGhhdCBoYXMgc29tZXRoaW5n
IGxpa2UgYW4gTlggYml0IGFuZCBkb2Vzbid0IHVzZSB0aGUNCmRlZmF1bHQgbW9kdWxlX2FsbG9j
IGltcGxlbWVudGF0aW9uLg0KDQpJIGNvdWxkIGFkZCB0aGUgZmxhZyBmb3IgZXZlcnkgYXJjaCB0
aGF0IGRlZmluZXMgUEFHRV9LRVJORUxfRVhFQywgYnV0IEkgZG9uJ3QNCmhhdmUgYSBnb29kIHdh
eSB0byB0ZXN0IG9uIGFsbCBvZiB0aG9zZSBhcmNoaXRlY3R1cmVzLg0KDQpUaGFua3MsDQoNClJp
Y2sNCg==
