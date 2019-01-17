Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 600808E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:48:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so7069077plb.1
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:48:35 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r18si2923785pls.115.2019.01.17.15.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 15:48:34 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Date: Thu, 17 Jan 2019 23:48:30 +0000
Message-ID: <3c12f9b3328ee32d04a6ed3990fdf0cd3cb27532.camel@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	 <20190117003259.23141-15-rick.p.edgecombe@intel.com>
	 <20190117093950.GA17930@amd>
	 <b224d88d91a5c45c44e176ea06dea558a8939ccf.camel@intel.com>
	 <20190117234111.GA27661@amd>
In-Reply-To: <20190117234111.GA27661@amd>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <303A1B4A3E7D644A826569E054F1E051@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "pavel@ucw.cz" <pavel@ucw.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com" <linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>

T24gRnJpLCAyMDE5LTAxLTE4IGF0IDAwOjQxICswMTAwLCBQYXZlbCBNYWNoZWsgd3JvdGU6DQo+
IEhpIQ0KPiANCj4gPiA+ID4gRm9yIGFyY2hpdGVjdHVyZXMgd2l0aCBDT05GSUdfQVJDSF9IQVNf
U0VUX0FMSUFTLCBwYWdlcyBjYW4gYmUgdW5tYXBwZWQNCj4gPiA+ID4gYnJpZWZseSBvbiB0aGUg
ZGlyZWN0bWFwLCBldmVuIHdoZW4gQ09ORklHX0RFQlVHX1BBR0VBTExPQyBpcyBub3QNCj4gPiA+
ID4gY29uZmlndXJlZC4NCj4gPiA+ID4gU28gdGhpcyBjaGFuZ2VzIGtlcm5lbF9tYXBfcGFnZXMg
YW5kIGtlcm5lbF9wYWdlX3ByZXNlbnQgdG8gYmUgZGVmaW5lZA0KPiA+ID4gPiB3aGVuDQo+ID4g
PiA+IENPTkZJR19BUkNIX0hBU19TRVRfQUxJQVMgaXMgZGVmaW5lZCBhcyB3ZWxsLiBJdCBhbHNv
IGNoYW5nZXMgcGxhY2VzDQo+ID4gPiA+IChwYWdlX2FsbG9jLmMpIHdoZXJlIHRob3NlIGZ1bmN0
aW9ucyBhcmUgYXNzdW1lZCB0byBvbmx5IGJlIGltcGxlbWVudGVkDQo+ID4gPiA+IHdoZW4NCj4g
PiA+ID4gQ09ORklHX0RFQlVHX1BBR0VBTExPQyBpcyBkZWZpbmVkLg0KPiA+ID4gDQo+ID4gPiBX
aGljaCBhcmNoaXRlY3R1cmVzIGFyZSB0aGF0Pw0KPiA+ID4gDQo+ID4gPiBTaG91bGQgdGhpcyBi
ZSBtZXJnZWQgdG8gdGhlIHBhdGNoIHdoZXJlIEhBU19TRVRfQUxJQVMgaXMgaW50cm9kdWNlZD8g
V2UNCj4gPiA+IGRvbid0IHdhbnQgYnJva2VuIGhpYmVybmF0aW9uIGluIGJldHdlZW4uLi4uDQo+
ID4gDQo+ID4gVGhhbmtzIGZvciB0YWtpbmcgYSBsb29rLiBJdCB3YXMgYWRkZWQgZm9yIHg4NiBm
b3IgcGF0Y2ggMTMgaW4gdGhpcyBwYXRjaHNldA0KPiA+IGFuZA0KPiA+IHRoZXJlIHdhcyBpbnRl
cmVzdCBleHByZXNzZWQgZm9yIGFkZGluZyBmb3IgYXJtNjQuIElmIHlvdSBkaWRuJ3QgZ2V0IHRo
ZQ0KPiA+IHdob2xlDQo+ID4gc2V0IGFuZCB3YW50IHRvIHNlZSBsZXQgbWUga25vdyBhbmQgSSBj
YW4gc2VuZCBpdC4NCj4gDQo+IEkgZ29vZ2xlZCBpbiBpbiB0aGUgbWVhbnRpbWUuDQo+IA0KPiBB
bnl3YXksIGlmIHNvbWV0aGluZyBpcyBicm9rZW4gYmV0d2VlbiBwYXRjaCAxMyBhbmQgMTQsIHRo
ZW4gdGhleQ0KPiBzaG91bGQgYmUgc2FtZSBwYXRjaC4NCkdyZWF0LiBJdCBzaG91bGQgYmUgb2sg
YmVjYXVzZSB0aGUgbmV3IGZ1bmN0aW9ucyBhcmUgbm90IHVzZWQgYW55d2hlcmUgdW50aWwNCmFm
dGVyIHRoaXMgcGF0Y2guDQoNClRoYW5rcywNCg0KUmljaw0KDQo+ID4gPiA+IC0jaWZkZWYgQ09O
RklHX0RFQlVHX1BBR0VBTExPQw0KPiA+ID4gPiAgZXh0ZXJuIGJvb2wgX2RlYnVnX3BhZ2VhbGxv
Y19lbmFibGVkOw0KPiA+ID4gPiAtZXh0ZXJuIHZvaWQgX19rZXJuZWxfbWFwX3BhZ2VzKHN0cnVj
dCBwYWdlICpwYWdlLCBpbnQgbnVtcGFnZXMsIGludA0KPiA+ID4gPiBlbmFibGUpOw0KPiA+ID4g
PiAgDQo+ID4gPiA+ICBzdGF0aWMgaW5saW5lIGJvb2wgZGVidWdfcGFnZWFsbG9jX2VuYWJsZWQo
dm9pZCkNCj4gPiA+ID4gIHsNCj4gPiA+ID4gLQlyZXR1cm4gX2RlYnVnX3BhZ2VhbGxvY19lbmFi
bGVkOw0KPiA+ID4gPiArCXJldHVybiBJU19FTkFCTEVEKENPTkZJR19ERUJVR19QQUdFQUxMT0Mp
ICYmDQo+ID4gPiA+IF9kZWJ1Z19wYWdlYWxsb2NfZW5hYmxlZDsNCj4gPiA+ID4gIH0NCj4gPiA+
IA0KPiA+ID4gVGhpcyB3aWxsIGJyZWFrIGJ1aWxkIEFGQUlDVC4gX2RlYnVnX3BhZ2VhbGxvY19l
bmFibGVkIHZhcmlhYmxlIGRvZXMNCj4gPiA+IG5vdCBleGlzdCBpbiAhQ09ORklHX0RFQlVHX1BB
R0VBTExPQyBjYXNlLg0KPiA+ID4gDQo+ID4gPiAJCQkJCQkJCQlQYXZlbA0KPiA+IA0KPiA+IEFm
dGVyIGFkZGluZyBpbiB0aGUgQ09ORklHX0FSQ0hfSEFTX1NFVF9BTElBUyBjb25kaXRpb24gdG8g
dGhlIGlmZGVmcyBpbg0KPiA+IHRoaXMNCj4gPiBhcmVhIGl0IGxvb2tlZCBhIGxpdHRsZSBoYXJk
IHRvIHJlYWQgdG8gbWUsIHNvIEkgbW92ZWQNCj4gPiBkZWJ1Z19wYWdlYWxsb2NfZW5hYmxlZA0K
PiA+IGFuZCBleHRlcm4gYm9vbCBfZGVidWdfcGFnZWFsbG9jX2VuYWJsZWQgb3V0c2lkZSB0byBt
YWtlIGl0IGVhc2llci4gSSB0aGluaw0KPiA+IHlvdQ0KPiA+IGFyZSByaWdodCwgdGhlIGFjdHVh
bCBub24tZXh0ZXJuIHZhcmlhYmxlIGNhbiBub3QgYmUgdGhlcmUsIGJ1dCB0aGUNCj4gPiByZWZl
cmVuY2UNCj4gPiBoZXJlIGdldHMgb3B0aW1pemVkIG91dCBpbiB0aGF0IGNhc2UuDQo+ID4gDQo+
ID4gSnVzdCBkb3VibGUgY2hlY2tlZCBhbmQgaXQgYnVpbGRzIGZvciBib3RoIENPTkZJR19ERUJV
R19QQUdFQUxMT0M9biBhbmQNCj4gPiBDT05GSUdfREVCVUdfUEFHRUFMTE9DPXkgZm9yIG1lLg0K
PiANCj4gT2suDQo+IA0KPiBUaGFua3MsDQo+IAkJCQkJCQkJCVBhdmVsDQo=
