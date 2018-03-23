Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A469F6B0030
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:15:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i127so5115203pgc.22
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:15:58 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0067.outbound.protection.outlook.com. [104.47.34.67])
        by mx.google.com with ESMTPS id m10-v6si9966695pln.595.2018.03.23.12.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 12:15:57 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
Date: Fri, 23 Mar 2018 19:15:55 +0000
Message-ID: <224464E0-1D3A-4ED8-88E0-A8E84C4265FC@vmware.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174454.CD00F614@viggo.jf.intel.com>
In-Reply-To: <20180323174454.CD00F614@viggo.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3B296758DCC6A84AADBA6B1318CE501A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

RGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGxpbnV4LmludGVsLmNvbT4gd3JvdGU6DQoNCj4gDQo+
IEZyb206IERhdmUgSGFuc2VuIDxkYXZlLmhhbnNlbkBsaW51eC5pbnRlbC5jb20+DQo+IA0KPiBB
IFBURSBpcyBjb25zdHJ1Y3RlZCBmcm9tIGEgcGh5c2ljYWwgYWRkcmVzcyBhbmQgYSBwZ3Byb3R2
YWxfdC4NCj4gX19QQUdFX0tFUk5FTCwgZm9yIGluc3RhbmNlLCBpcyBhIHBncHJvdF90IGFuZCBt
dXN0IGJlIGNvbnZlcnRlZA0KPiBpbnRvIGEgcGdwcm90dmFsX3QgYmVmb3JlIGl0IGNhbiBiZSB1
c2VkIHRvIGNyZWF0ZSBhIFBURS4gIFRoaXMgaXMNCj4gZG9uZSBpbXBsaWNpdGx5IHdpdGhpbiBm
dW5jdGlvbnMgbGlrZSBzZXRfcHRlKCkgYnkgbWFzc2FnZV9wZ3Byb3QoKS4NCj4gDQo+IEhvd2V2
ZXIsIHRoaXMgbWFrZXMgaXQgdmVyeSBjaGFsbGVuZ2luZyB0byBzZXQgYml0cyAoYW5kIGtlZXAg
dGhlbQ0KPiBzZXQpIGlmIHlvdXIgYml0IGlzIGJlaW5nIGZpbHRlcmVkIG91dCBieSBtYXNzYWdl
X3BncHJvdCgpLg0KPiANCj4gVGhpcyBtb3ZlcyB0aGUgYml0IGZpbHRlcmluZyBvdXQgb2Ygc2V0
X3B0ZSgpIGFuZCBmcmllbmRzLiAgRm9yDQoNCkkgZG9u4oCZdCBzZWUgdGhhdCBzZXRfcHRlKCkg
ZmlsdGVycyB0aGUgYml0cywgc28gSSBhbSBjb25mdXNlZCBieSB0aGlzDQpzZW50ZW5jZS4uLg0K
DQo+ICtzdGF0aWMgaW5saW5lIHBncHJvdHZhbF90IGNoZWNrX3BncHJvdChwZ3Byb3RfdCBwZ3By
b3QpDQo+ICt7DQo+ICsJcGdwcm90dmFsX3QgbWFzc2FnZWRfdmFsID0gbWFzc2FnZV9wZ3Byb3Qo
cGdwcm90KTsNCj4gKw0KPiArCS8qIG1tZGVidWcuaCBjYW4gbm90IGJlIGluY2x1ZGVkIGhlcmUg
YmVjYXVzZSBvZiBkZXBlbmRlbmNpZXMgKi8NCj4gKyNpZmRlZiBDT05GSUdfREVCVUdfVk0NCj4g
KwlXQVJOX09OQ0UocGdwcm90X3ZhbChwZ3Byb3QpICE9IG1hc3NhZ2VkX3ZhbCwNCj4gKwkJICAi
YXR0ZW1wdGVkIHRvIHNldCB1bnN1cHBvcnRlZCBwZ3Byb3Q6ICUwMTZseCAiDQo+ICsJCSAgImJp
dHM6ICUwMTZseCBzdXBwb3J0ZWQ6ICUwMTZseFxuIiwNCj4gKwkJICBwZ3Byb3RfdmFsKHBncHJv
dCksDQo+ICsJCSAgcGdwcm90X3ZhbChwZ3Byb3QpIF4gbWFzc2FnZWRfdmFsLA0KPiArCQkgIF9f
c3VwcG9ydGVkX3B0ZV9tYXNrKTsNCj4gKyNlbmRpZg0KV2h5IG5vdCB0byB1c2UgVk1fV0FSTl9P
Tl9PTkNFKCkgYW5kIGF2b2lkIHRoZSBpZmRlZj8NCg0K
