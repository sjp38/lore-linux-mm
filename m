Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 149AD6B7CE5
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:56:32 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o17so1206060pgi.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:56:32 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q9si1282536pgh.92.2018.12.06.14.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 14:56:30 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 10/13] keys/mktme: Add the MKTME Key Service type for
 memory encryption
Date: Thu, 6 Dec 2018 22:56:25 +0000
Message-ID: <c9082287a6e146b69de9be857eef4a1069d473fe.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <42d44fb5ddbbf7241a2494fc688e274ade641965.1543903910.git.alison.schofield@intel.com>
	 <a19a48ae1d6434a1764b02c2376a99130ce15174.camel@intel.com>
	 <986544e1-ffd1-1cd2-f0d3-4b1a4e8e8f3b@intel.com>
In-Reply-To: <986544e1-ffd1-1cd2-f0d3-4b1a4e8e8f3b@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3AA4A8306800BA439316DD225EB71575@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gVGh1LCAyMDE4LTEyLTA2IGF0IDA3OjExIC0wODAwLCBEYXZlIEhhbnNlbiB3cm90ZToNCj4g
T24gMTIvNi8xOCAxMjo1MSBBTSwgU2Fra2luZW4sIEphcmtrbyB3cm90ZToNCj4gPiBPbiBNb24s
IDIwMTgtMTItMDMgYXQgMjM6MzkgLTA4MDAsIEFsaXNvbiBTY2hvZmllbGQgd3JvdGU6DQo+ID4g
PiBNS1RNRSAoTXVsdGktS2V5IFRvdGFsIE1lbW9yeSBFbmNyeXB0aW9uKSBpcyBhIHRlY2hub2xv
Z3kgdGhhdCBhbGxvd3MNCj4gPiA+IHRyYW5zcGFyZW50IG1lbW9yeSBlbmNyeXB0aW9uIGluIHVw
Y29taW5nIEludGVsIHBsYXRmb3Jtcy4gTUtUTUUgd2lsbA0KPiA+ID4gc3VwcG9ydCBtdWxpdHBs
ZSBlbmNyeXB0aW9uIGRvbWFpbnMsIGVhY2ggaGF2aW5nIHRoZWlyIG93biBrZXkuIFRoZSBtYWlu
DQo+ID4gPiB1c2UgY2FzZSBmb3IgdGhlIGZlYXR1cmUgaXMgdmlydHVhbCBtYWNoaW5lIGlzb2xh
dGlvbi4gVGhlIEFQSSBuZWVkcyB0aGUNCj4gPiA+IGZsZXhpYmlsaXR5IHRvIHdvcmsgZm9yIGEg
d2lkZSByYW5nZSBvZiB1c2VzLg0KPiA+IFNvbWUsIG1heWJlIGJydXRhbCwgaG9uZXN0eSAoYXBv
bG9naWVzKS4uLg0KPiA+IA0KPiA+IEhhdmUgbmV2ZXIgcmVhbGx5IGdvdCB0aGUgZ3JpcCB3aHkg
ZWl0aGVyIFNNRSBvciBUTUUgd291bGQgbWFrZQ0KPiA+IGlzb2xhdGlvbiBhbnkgYmV0dGVyLiBJ
ZiB5b3UgY2FuIGJyZWFrIGludG8gaHlwZXJ2aXNvciwgeW91J2xsDQo+ID4gaGF2ZSB0aGVzZSB0
b29scyBhdmFpbGFiZToNCj4gDQo+IEZvciBzeXN0ZW1zIHVzaW5nIE1LVE1FLCB0aGUgaHlwZXJ2
aXNvciBpcyB3aXRoaW4gdGhlICJ0cnVzdCBib3VuZGFyeSIuDQo+ICBGcm9tIHdoYXQgSSd2ZSBy
ZWFkLCBpdCBpcyBhIGJpdCBfbW9yZV8gdHJ1c3RlZCB0aGFuIHdpdGggQU1EJ3Mgc2NoZW1lLg0K
PiANCj4gQnV0LCB5ZXMsIGlmIHlvdSBjYW4gbW91bnQgYSBzdWNjZXNzZnVsIGFyYml0cmFyeSBj
b2RlIGV4ZWN1dGlvbiBhdHRhY2sNCj4gYWdhaW5zdCB0aGUgTUtUTUUgaHlwZXJ2aXNvciwgeW91
IGNhbiBkZWZlYXQgTUtUTUUncyBwcm90ZWN0aW9ucy4gIElmDQo+IHRoZSBrZXJuZWwgY3JlYXRl
cyBub24tZW5jcnlwdGVkIG1hcHBpbmdzIG9mIG1lbW9yeSB0aGF0J3MgYmVpbmcNCj4gZW5jcnlw
dGVkIHdpdGggTUtUTUUsIGFuIGFyYml0cmFyeSByZWFkIHByaW1pdGl2ZSBjb3VsZCBhbHNvIGJl
IGEgdmVyeQ0KPiB2YWx1YWJsZSBpbiBkZWZlYXRpbmcgTUtUTUUncyBwcm90ZWN0aW9ucy4gIFRo
YXQncyB3aHkgQW5keSBpcyBwcm9wb3NpbmcNCj4gZG9pbmcgc29tZXRoaW5nIGxpa2UgZVhjbHVz
aXZlLVBhZ2UtRnJhbWUtT3duZXJzaGlwIChnb29nbGUgWFBGTykuDQoNClRoYW5rcywgSSB3YXMg
bm90IGF3YXJlIG9mIFhQRk8gYnV0IEkgZm91bmQgYSBuaWNlIH4yIHBhZ2UgYXJ0aWNsZSBhYm91
dCBpdDoNCg0KaHR0cHM6Ly9sd24ubmV0L0FydGljbGVzLzcwMDY0Ny8NCg0KSSB0aGluayB0aGUg
cGVyZm9ybWFuY2UgaGl0IGlzIHRoZSBuZWNlc3NhcnkgcHJpY2UgdG8gcGF5IChpZiB5b3Ugd2Fu
dA0Kc29tZXRoaW5nIG1vcmUgb3BhcXVlIHRoYW4ganVzdCB0aGUgdXN1YWwgIm1pbGl0YXJ5IGdy
YWRlIHNlY3VyaXR5IikuIEF0DQptaW5pbXVtLCBpdCBzaG91bGQgYmUgYW4gb3B0LWluIGZlYXR1
cmUuDQoNCi9KYXJra28NCg==
