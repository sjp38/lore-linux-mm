Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99E4F6B78FF
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:31:30 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so12858311pgb.7
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:31:30 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 64si21590775pfe.74.2018.12.06.00.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:31:29 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 04/13] x86/mm: Add helper functions for MKTME memory
 encryption keys
Date: Thu, 6 Dec 2018 08:31:24 +0000
Message-ID: <6cabe09dd085f74a3111faebeb285cf0cac1146d.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <216ECE3FADEC4042AABDCAEF5A292CDA@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Jun

T24gTW9uLCAyMDE4LTEyLTAzIGF0IDIzOjM5IC0wODAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiArZXh0ZXJuIGludCBta3RtZV9tYXBfYWxsb2Modm9pZCk7DQo+ICtleHRlcm4gdm9pZCBt
a3RtZV9tYXBfZnJlZSh2b2lkKTsNCj4gK2V4dGVybiB2b2lkIG1rdG1lX21hcF9sb2NrKHZvaWQp
Ow0KPiArZXh0ZXJuIHZvaWQgbWt0bWVfbWFwX3VubG9jayh2b2lkKTsNCj4gK2V4dGVybiBpbnQg
bWt0bWVfbWFwX21hcHBlZF9rZXlpZHModm9pZCk7DQo+ICtleHRlcm4gdm9pZCBta3RtZV9tYXBf
c2V0X2tleWlkKGludCBrZXlpZCwgdm9pZCAqa2V5KTsNCj4gK2V4dGVybiB2b2lkIG1rdG1lX21h
cF9mcmVlX2tleWlkKGludCBrZXlpZCk7DQo+ICtleHRlcm4gaW50IG1rdG1lX21hcF9rZXlpZF9m
cm9tX2tleSh2b2lkICprZXkpOw0KPiArZXh0ZXJuIHZvaWQgKm1rdG1lX21hcF9rZXlfZnJvbV9r
ZXlpZChpbnQga2V5aWQpOw0KPiArZXh0ZXJuIGludCBta3RtZV9tYXBfZ2V0X2ZyZWVfa2V5aWQo
dm9pZCk7DQoNCk5vIG5lZWQgZm9yIGV4dGVybiBrZXl3b3JkIGZvciBmdW5jdGlvbiBkZWNsYXJh
dGlvbnMuIEl0IGlzDQpvbmx5IG5lZWRlZCBmb3IgdmFyaWFibGUgZGVjbGFyYXRpb25zLg0KDQo+
ICsNCj4gIERFQ0xBUkVfU1RBVElDX0tFWV9GQUxTRShta3RtZV9lbmFibGVkX2tleSk7DQo+ICBz
dGF0aWMgaW5saW5lIGJvb2wgbWt0bWVfZW5hYmxlZCh2b2lkKQ0KPiAgew0KPiBkaWZmIC0tZ2l0
IGEvYXJjaC94ODYvbW0vbWt0bWUuYyBiL2FyY2gveDg2L21tL21rdG1lLmMNCj4gaW5kZXggYzgx
NzI3NTQwZTdjLi4zNDIyNGQ0ZTNmNDUgMTAwNjQ0DQo+IC0tLSBhL2FyY2gveDg2L21tL21rdG1l
LmMNCj4gKysrIGIvYXJjaC94ODYvbW0vbWt0bWUuYw0KPiBAQCAtNDAsNiArNDAsOTcgQEAgaW50
IF9fdm1hX2tleWlkKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hKQ0KPiAgCXJldHVybiAocHJv
dCAmIG1rdG1lX2tleWlkX21hc2spID4+IG1rdG1lX2tleWlkX3NoaWZ0Ow0KPiAgfQ0KPiAgDQo+
ICsvKg0KPiArICogc3RydWN0IG1rdG1lX21hcCBhbmQgdGhlIG1rdG1lX21hcF8qIGZ1bmN0aW9u
cyBtYW5hZ2UgdGhlIG1hcHBpbmcNCj4gKyAqIG9mIHVzZXJzcGFjZSBLZXlzIHRvIGhhcmR3YXJl
IEtleUlEcy4gVGhlc2UgYXJlIHVzZWQgYnkgdGhlIE1LVE1FIEtleQ0KDQpXaGF0IGFyZSAidXNl
cnNwYWNlIEtleXMiIGFueXdheSBhbmQgd2h5IEtleSBhbmQgbm90IGtleT8NCg0KPiArICogU2Vy
dmljZSBBUEkgYW5kIHRoZSBlbmNyeXB0X21wcm90ZWN0KCkgc3lzdGVtIGNhbGwuDQo+ICsgKi8N
Cj4gKw0KPiArc3RydWN0IG1rdG1lX21hcHBpbmcgew0KPiArCXN0cnVjdCBtdXRleAlsb2NrOwkJ
LyogcHJvdGVjdCB0aGlzIG1hcCAmIEhXIHN0YXRlICovDQo+ICsJdW5zaWduZWQgaW50CW1hcHBl
ZF9rZXlpZHM7DQo+ICsJdm9pZAkJKmtleVtdOw0KPiArfTsNCg0KUGVyc29uYWxseSwgSSBwcmVm
ZXIgbm90IHRvIGFsaWduIHN0cnVjdCBmaWVsZHMgKEkgZG8gYWxpZ24gZW51bXMNCmJlY2F1c2Ug
dGhlcmUgaXQgbWFrZXMgbW9yZSBzZW5zZSkgYXMgb2Z0ZW4geW91IGVuZCB1cCByZWFsaWduaW5n
DQpldmVyeXRoaW5nLg0KDQpEb2N1bWVudGF0aW9uIHdvdWxkIGJyaW5nIG1vcmUgY2xhcml0eS4g
Rm9yIGV4YW1wbGUsIHdoYXQgZG9lcyBrZXlbXQ0KY29udGFpbiwgd2h5IHRoZXJlIGlzIGEgbG9j
ayBhbmQgd2hhdCBtYXBwZWRfa2V5aWRzIGZpZWxkIGNvbnRhaW5zPw0KDQovSmFya2tvDQo=
