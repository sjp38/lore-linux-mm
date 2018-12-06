Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 016136B78E8
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:08:42 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so16693005plb.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:08:41 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l66si22747620pfl.258.2018.12.06.00.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:08:40 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 02/13] mm: Generalize the mprotect implementation to
 support extensions
Date: Thu, 6 Dec 2018 08:08:35 +0000
Message-ID: <056ae50739536a0f6aea3d3c0f2706baa50178c4.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <3389bc8e46479ba102f88c157aebd49b905ac289.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <3389bc8e46479ba102f88c157aebd49b905ac289.1543903910.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7145A7DA804676499A3393B3376851B8@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Jun

T24gTW9uLCAyMDE4LTEyLTAzIGF0IDIzOjM5IC0wODAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBUb2RheSBtcHJvdGVjdCBpcyBpbXBsZW1lbnRlZCB0byBzdXBwb3J0IGxlZ2FjeSBtcHJv
dGVjdCBiZWhhdmlvcg0KPiBwbHVzIGFuIGV4dGVuc2lvbiBmb3IgbWVtb3J5IHByb3RlY3Rpb24g
a2V5cy4gTWFrZSBpdCBtb3JlIGdlbmVyaWMNCj4gc28gdGhhdCBpdCBjYW4gc3VwcG9ydCBhZGRp
dGlvbmFsIGV4dGVuc2lvbnMgaW4gdGhlIGZ1dHVyZS4NCj4gDQo+IFRoaXMgaXMgZG9uZSBpcyBw
cmVwYXJhdGlvbiBmb3IgYWRkaW5nIGEgbmV3IHN5c3RlbSBjYWxsIGZvciBtZW1vcnkNCj4gZW5j
eXB0aW9uIGtleXMuIFRoZSBpbnRlbnQgaXMgdGhhdCB0aGUgbmV3IGVuY3J5cHRlZCBtcHJvdGVj
dCB3aWxsIGJlDQo+IGFub3RoZXIgZXh0ZW5zaW9uIHRvIGxlZ2FjeSBtcHJvdGVjdC4NCj4gDQo+
IENoYW5nZS1JZDogSWIwOWI5ZDFiNjA1YjEyZDAyNTRkN2ZiNDk2OGRmY2M4ZTNjNzlkZDcNCg0K
V2hhdCBpcyB0aGlzPz8NCg0KPiBTaWduZWQtb2ZmLWJ5OiBBbGlzb24gU2Nob2ZpZWxkIDxhbGlz
b24uc2Nob2ZpZWxkQGludGVsLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogS2lyaWxsIEEuIFNodXRl
bW92IDxraXJpbGwuc2h1dGVtb3ZAbGludXguaW50ZWwuY29tPg0KPiAtLS0NCj4gIG1tL21wcm90
ZWN0LmMgfCAxMCArKysrKystLS0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCsp
LCA0IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL21tL21wcm90ZWN0LmMgYi9tbS9t
cHJvdGVjdC5jDQo+IGluZGV4IGRmNDA4OTU2ZGNjYy4uYjU3MDc1ZTI3OGZiIDEwMDY0NA0KPiAt
LS0gYS9tbS9tcHJvdGVjdC5jDQo+ICsrKyBiL21tL21wcm90ZWN0LmMNCj4gQEAgLTM1LDYgKzM1
LDggQEANCj4gIA0KPiAgI2luY2x1ZGUgImludGVybmFsLmgiDQo+ICANCj4gKyNkZWZpbmUgTk9f
S0VZCS0xDQo+ICsNCj4gIHN0YXRpYyB1bnNpZ25lZCBsb25nIGNoYW5nZV9wdGVfcmFuZ2Uoc3Ry
dWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHBtZF90ICpwbWQsDQo+ICAJCXVuc2lnbmVkIGxvbmcg
YWRkciwgdW5zaWduZWQgbG9uZyBlbmQsIHBncHJvdF90IG5ld3Byb3QsDQo+ICAJCWludCBkaXJ0
eV9hY2NvdW50YWJsZSwgaW50IHByb3RfbnVtYSkNCj4gQEAgLTQ1MSw5ICs0NTMsOSBAQCBtcHJv
dGVjdF9maXh1cChzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgc3RydWN0DQo+IHZtX2FyZWFf
c3RydWN0ICoqcHByZXYsDQo+ICB9DQo+ICANCj4gIC8qDQo+IC0gKiBwa2V5PT0tMSB3aGVuIGRv
aW5nIGEgbGVnYWN5IG1wcm90ZWN0KCkNCj4gKyAqIFdoZW4gcGtleT09Tk9fS0VZIHdlIGdldCBs
ZWdhY3kgbXByb3RlY3QgYmVoYXZpb3IgaGVyZS4NCj4gICAqLw0KPiAtc3RhdGljIGludCBkb19t
cHJvdGVjdF9wa2V5KHVuc2lnbmVkIGxvbmcgc3RhcnQsIHNpemVfdCBsZW4sDQo+ICtzdGF0aWMg
aW50IGRvX21wcm90ZWN0X2V4dCh1bnNpZ25lZCBsb25nIHN0YXJ0LCBzaXplX3QgbGVuLA0KPiAg
CQl1bnNpZ25lZCBsb25nIHByb3QsIGludCBwa2V5KQ0KPiAgew0KPiAgCXVuc2lnbmVkIGxvbmcg
bnN0YXJ0LCBlbmQsIHRtcCwgcmVxcHJvdDsNCj4gQEAgLTU3Nyw3ICs1NzksNyBAQCBzdGF0aWMg
aW50IGRvX21wcm90ZWN0X3BrZXkodW5zaWduZWQgbG9uZyBzdGFydCwgc2l6ZV90DQo+IGxlbiwN
Cj4gIFNZU0NBTExfREVGSU5FMyhtcHJvdGVjdCwgdW5zaWduZWQgbG9uZywgc3RhcnQsIHNpemVf
dCwgbGVuLA0KPiAgCQl1bnNpZ25lZCBsb25nLCBwcm90KQ0KPiAgew0KPiAtCXJldHVybiBkb19t
cHJvdGVjdF9wa2V5KHN0YXJ0LCBsZW4sIHByb3QsIC0xKTsNCj4gKwlyZXR1cm4gZG9fbXByb3Rl
Y3RfZXh0KHN0YXJ0LCBsZW4sIHByb3QsIE5PX0tFWSk7DQo+ICB9DQo+ICANCj4gICNpZmRlZiBD
T05GSUdfQVJDSF9IQVNfUEtFWVMNCj4gQEAgLTU4NSw3ICs1ODcsNyBAQCBTWVNDQUxMX0RFRklO
RTMobXByb3RlY3QsIHVuc2lnbmVkIGxvbmcsIHN0YXJ0LCBzaXplX3QsDQo+IGxlbiwNCj4gIFNZ
U0NBTExfREVGSU5FNChwa2V5X21wcm90ZWN0LCB1bnNpZ25lZCBsb25nLCBzdGFydCwgc2l6ZV90
LCBsZW4sDQo+ICAJCXVuc2lnbmVkIGxvbmcsIHByb3QsIGludCwgcGtleSkNCj4gIHsNCj4gLQly
ZXR1cm4gZG9fbXByb3RlY3RfcGtleShzdGFydCwgbGVuLCBwcm90LCBwa2V5KTsNCj4gKwlyZXR1
cm4gZG9fbXByb3RlY3RfZXh0KHN0YXJ0LCBsZW4sIHByb3QsIHBrZXkpOw0KPiAgfQ0KPiAgDQo+
ICBTWVNDQUxMX0RFRklORTIocGtleV9hbGxvYywgdW5zaWduZWQgbG9uZywgZmxhZ3MsIHVuc2ln
bmVkIGxvbmcsIGluaXRfdmFsKQ0KDQpXb3VsZCBzcXVhc2ggdGhpcyB3aGF0ZXZlciB0aGlzIGlz
IHJlcXVpcmVkIGZvci4gVGhpcyBzcGxpdCBtYWtlcw0KcmV2aWV3IG1vcmUgY29tcGxleCAoSU1I
TykuDQoNCi9KYXJra28NCg==
