Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE7958E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 20:33:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so3992547plk.9
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 17:33:46 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j191si4203204pgc.15.2018.12.07.17.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 17:33:45 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Sat, 8 Dec 2018 01:33:39 +0000
Message-ID: <1544232812.28511.39.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
In-Reply-To: <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <46E7BAFAD6900E49A15D0F2333E48D4E@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTEyLTA3IGF0IDIzOjQ1ICswMDAwLCBTYWtraW5lbiwgSmFya2tvIHdyb3Rl
Og0KPiBPbiBGcmksIDIwMTgtMTItMDcgYXQgMTM6NTkgLTA4MDAsIEphcmtrbyBTYWtraW5lbiB3
cm90ZToNCj4gPiBPbiBGcmksIDIwMTgtMTItMDcgYXQgMTQ6NTcgKzAzMDAsIEtpcmlsbCBBLiBT
aHV0ZW1vdiB3cm90ZToNCj4gPiA+ID4gV2hhdCBpcyB0aGUgdGhyZWF0IG1vZGVsIGFueXdheSBm
b3IgQU1EIGFuZCBJbnRlbCB0ZWNobm9sb2dpZXM/DQo+ID4gPiA+IA0KPiA+ID4gPiBGb3IgbWUg
aXQgbG9va3MgbGlrZSB0aGF0IHlvdSBjYW4gcmVhZCwgd3JpdGUgYW5kIGV2ZW4gcmVwbGF5IA0K
PiA+ID4gPiBlbmNyeXB0ZWQgcGFnZXMgYm90aCBpbiBTTUUgYW5kIFRNRS4gDQo+ID4gPiANCj4g
PiA+IFdoYXQgcmVwbGF5IGF0dGFjayBhcmUgeW91IHRhbGtpbmcgYWJvdXQ/IE1LVE1FIHVzZXMg
QUVTLVhUUyB3aXRoIHBoeXNpY2FsDQo+ID4gPiBhZGRyZXNzIHR3ZWFrLiBTbyB0aGUgZGF0YSBp
cyB0aWVkIHRvIHRoZSBwbGFjZSBpbiBwaHlzaWNhbCBhZGRyZXNzIHNwYWNlDQo+ID4gPiBhbmQN
Cj4gPiA+IHJlcGxhY2luZyBvbmUgZW5jcnlwdGVkIHBhZ2Ugd2l0aCBhbm90aGVyIGVuY3J5cHRl
ZCBwYWdlIGZyb20gZGlmZmVyZW50DQo+ID4gPiBhZGRyZXNzIHdpbGwgcHJvZHVjZSBnYXJiYWdl
IG9uIGRlY3J5cHRpb24uDQo+ID4gDQo+ID4gSnVzdCB0cnlpbmcgdG8gdW5kZXJzdGFuZCBob3cg
dGhpcyB3b3Jrcy4NCj4gPiANCj4gPiBTbyB5b3UgdXNlIHBoeXNpY2FsIGFkZHJlc3MgbGlrZSBh
IG5vbmNlL3ZlcnNpb24gZm9yIHRoZSBwYWdlIGFuZA0KPiA+IHRodXMgcHJldmVudCByZXBsYXk/
IFdhcyBub3QgYXdhcmUgb2YgdGhpcy4NCj4gDQo+IFRoZSBicnV0YWwgZmFjdCBpcyB0aGF0IGEg
cGh5c2ljYWwgYWRkcmVzcyBpcyBhbiBhc3Ryb25vbWljYWwgc3RyZXRjaA0KPiBmcm9tIGEgcmFu
ZG9tIHZhbHVlIG9yIGluY3JlYXNpbmcgY291bnRlci4gVGh1cywgaXQgaXMgZmFpciB0byBzYXkg
dGhhdA0KPiBNS1RNRSBwcm92aWRlcyBvbmx5IG5haXZlIG1lYXN1cmVzIGFnYWluc3QgcmVwbGF5
IGF0dGFja3MuLi4NCj4gDQo+IC9KYXJra28NCg0KQ3VycmVudGx5IHRoZXJlJ3Mgbm8gbm9uY2Ug
dG8gcHJvdGVjdCBjYWNoZSBsaW5lIHNvIFRNRS9NS1RNRSBpcyBub3QgYWJsZSB0byBwcmV2ZW50
IHJlcGxheSBhdHRhY2sNCnlvdSBtZW50aW9uZWQuIEN1cnJlbnRseSBNS1RNRSBvbmx5IGludm9s
dmVzIEFFUy1YVFMtMTI4IGVuY3J5cHRpb24gYnV0IG5vdGhpbmcgZWxzZS4gQnV0IGxpa2UgSQ0K
c2FpZCBpZiBJIHVuZGVyc3RhbmQgY29ycmVjdGx5IGV2ZW4gU0VWIGRvZXNuJ3QgaGF2ZSBpbnRl
Z3JpdHkgcHJvdGVjdGlvbiBzbyBub3QgYWJsZSB0byBwcmV2ZW50DQpyZXBseSBhdHRhY2sgYXMg
d2VsbC4NCg0KVGhhbmtzLA0KLUthaQ==
