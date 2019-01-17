Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2175B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:16:51 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so7060790pgj.21
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 14:16:51 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i2si2649835pgl.153.2019.01.17.14.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 14:16:49 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Date: Thu, 17 Jan 2019 22:16:47 +0000
Message-ID: <b224d88d91a5c45c44e176ea06dea558a8939ccf.camel@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	 <20190117003259.23141-15-rick.p.edgecombe@intel.com>
	 <20190117093950.GA17930@amd>
In-Reply-To: <20190117093950.GA17930@amd>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D73C986B5765A64C9EB296CBE671BE1A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "pavel@ucw.cz" <pavel@ucw.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com" <linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>

T24gVGh1LCAyMDE5LTAxLTE3IGF0IDEwOjM5ICswMTAwLCBQYXZlbCBNYWNoZWsgd3JvdGU6DQo+
IEhpIQ0KPiANCj4gPiBGb3IgYXJjaGl0ZWN0dXJlcyB3aXRoIENPTkZJR19BUkNIX0hBU19TRVRf
QUxJQVMsIHBhZ2VzIGNhbiBiZSB1bm1hcHBlZA0KPiA+IGJyaWVmbHkgb24gdGhlIGRpcmVjdG1h
cCwgZXZlbiB3aGVuIENPTkZJR19ERUJVR19QQUdFQUxMT0MgaXMgbm90DQo+ID4gY29uZmlndXJl
ZC4NCj4gPiBTbyB0aGlzIGNoYW5nZXMga2VybmVsX21hcF9wYWdlcyBhbmQga2VybmVsX3BhZ2Vf
cHJlc2VudCB0byBiZSBkZWZpbmVkIHdoZW4NCj4gPiBDT05GSUdfQVJDSF9IQVNfU0VUX0FMSUFT
IGlzIGRlZmluZWQgYXMgd2VsbC4gSXQgYWxzbyBjaGFuZ2VzIHBsYWNlcw0KPiA+IChwYWdlX2Fs
bG9jLmMpIHdoZXJlIHRob3NlIGZ1bmN0aW9ucyBhcmUgYXNzdW1lZCB0byBvbmx5IGJlIGltcGxl
bWVudGVkIHdoZW4NCj4gPiBDT05GSUdfREVCVUdfUEFHRUFMTE9DIGlzIGRlZmluZWQuDQo+IA0K
PiBXaGljaCBhcmNoaXRlY3R1cmVzIGFyZSB0aGF0Pw0KPiANCj4gU2hvdWxkIHRoaXMgYmUgbWVy
Z2VkIHRvIHRoZSBwYXRjaCB3aGVyZSBIQVNfU0VUX0FMSUFTIGlzIGludHJvZHVjZWQ/IFdlDQo+
IGRvbid0IHdhbnQgYnJva2VuIGhpYmVybmF0aW9uIGluIGJldHdlZW4uLi4uDQpUaGFua3MgZm9y
IHRha2luZyBhIGxvb2suIEl0IHdhcyBhZGRlZCBmb3IgeDg2IGZvciBwYXRjaCAxMyBpbiB0aGlz
IHBhdGNoc2V0IGFuZA0KdGhlcmUgd2FzIGludGVyZXN0IGV4cHJlc3NlZCBmb3IgYWRkaW5nIGZv
ciBhcm02NC4gSWYgeW91IGRpZG4ndCBnZXQgdGhlIHdob2xlDQpzZXQgYW5kIHdhbnQgdG8gc2Vl
IGxldCBtZSBrbm93IGFuZCBJIGNhbiBzZW5kIGl0Lg0KDQo+IA0KPiA+IC0jaWZkZWYgQ09ORklH
X0RFQlVHX1BBR0VBTExPQw0KPiA+ICBleHRlcm4gYm9vbCBfZGVidWdfcGFnZWFsbG9jX2VuYWJs
ZWQ7DQo+ID4gLWV4dGVybiB2b2lkIF9fa2VybmVsX21hcF9wYWdlcyhzdHJ1Y3QgcGFnZSAqcGFn
ZSwgaW50IG51bXBhZ2VzLCBpbnQNCj4gPiBlbmFibGUpOw0KPiA+ICANCj4gPiAgc3RhdGljIGlu
bGluZSBib29sIGRlYnVnX3BhZ2VhbGxvY19lbmFibGVkKHZvaWQpDQo+ID4gIHsNCj4gPiAtCXJl
dHVybiBfZGVidWdfcGFnZWFsbG9jX2VuYWJsZWQ7DQo+ID4gKwlyZXR1cm4gSVNfRU5BQkxFRChD
T05GSUdfREVCVUdfUEFHRUFMTE9DKSAmJiBfZGVidWdfcGFnZWFsbG9jX2VuYWJsZWQ7DQo+ID4g
IH0NCj4gDQo+IFRoaXMgd2lsbCBicmVhayBidWlsZCBBRkFJQ1QuIF9kZWJ1Z19wYWdlYWxsb2Nf
ZW5hYmxlZCB2YXJpYWJsZSBkb2VzDQo+IG5vdCBleGlzdCBpbiAhQ09ORklHX0RFQlVHX1BBR0VB
TExPQyBjYXNlLg0KPiANCj4gCQkJCQkJCQkJUGF2ZWwNCkFmdGVyIGFkZGluZyBpbiB0aGUgQ09O
RklHX0FSQ0hfSEFTX1NFVF9BTElBUyBjb25kaXRpb24gdG8gdGhlIGlmZGVmcyBpbiB0aGlzDQph
cmVhIGl0IGxvb2tlZCBhIGxpdHRsZSBoYXJkIHRvIHJlYWQgdG8gbWUsIHNvIEkgbW92ZWQgZGVi
dWdfcGFnZWFsbG9jX2VuYWJsZWQNCmFuZCBleHRlcm4gYm9vbCBfZGVidWdfcGFnZWFsbG9jX2Vu
YWJsZWQgb3V0c2lkZSB0byBtYWtlIGl0IGVhc2llci4gSSB0aGluayB5b3UNCmFyZSByaWdodCwg
dGhlIGFjdHVhbCBub24tZXh0ZXJuIHZhcmlhYmxlIGNhbiBub3QgYmUgdGhlcmUsIGJ1dCB0aGUg
cmVmZXJlbmNlDQpoZXJlIGdldHMgb3B0aW1pemVkIG91dCBpbiB0aGF0IGNhc2UuDQoNCkp1c3Qg
ZG91YmxlIGNoZWNrZWQgYW5kIGl0IGJ1aWxkcyBmb3IgYm90aCBDT05GSUdfREVCVUdfUEFHRUFM
TE9DPW4gYW5kDQpDT05GSUdfREVCVUdfUEFHRUFMTE9DPXkgZm9yIG1lLg0KDQpUaGFua3MsDQoN
ClJpY2sNCg==
