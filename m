Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73ADA6B7916
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:54:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so12890955pgb.7
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:54:48 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r8si19326807pgr.252.2018.12.06.00.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:54:47 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 10/13] keys/mktme: Add the MKTME Key Service type for
 memory encryption
Date: Thu, 6 Dec 2018 08:54:42 +0000
Message-ID: <e73fc3886a4a954bbc06b85e2da7728159cea9a7.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <42d44fb5ddbbf7241a2494fc688e274ade641965.1543903910.git.alison.schofield@intel.com>
	 <a19a48ae1d6434a1764b02c2376a99130ce15174.camel@intel.com>
In-Reply-To: <a19a48ae1d6434a1764b02c2376a99130ce15174.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7A158F3A3734834F8EAA294A3119720E@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Jun

T24gVGh1LCAyMDE4LTEyLTA2IGF0IDAwOjUxIC0wODAwLCBKYXJra28gU2Fra2luZW4gd3JvdGU6
DQo+IE9uIE1vbiwgMjAxOC0xMi0wMyBhdCAyMzozOSAtMDgwMCwgQWxpc29uIFNjaG9maWVsZCB3
cm90ZToNCj4gPiBNS1RNRSAoTXVsdGktS2V5IFRvdGFsIE1lbW9yeSBFbmNyeXB0aW9uKSBpcyBh
IHRlY2hub2xvZ3kgdGhhdCBhbGxvd3MNCj4gPiB0cmFuc3BhcmVudCBtZW1vcnkgZW5jcnlwdGlv
biBpbiB1cGNvbWluZyBJbnRlbCBwbGF0Zm9ybXMuIE1LVE1FIHdpbGwNCj4gPiBzdXBwb3J0IG11
bGl0cGxlIGVuY3J5cHRpb24gZG9tYWlucywgZWFjaCBoYXZpbmcgdGhlaXIgb3duIGtleS4gVGhl
IG1haW4NCj4gPiB1c2UgY2FzZSBmb3IgdGhlIGZlYXR1cmUgaXMgdmlydHVhbCBtYWNoaW5lIGlz
b2xhdGlvbi4gVGhlIEFQSSBuZWVkcyB0aGUNCj4gPiBmbGV4aWJpbGl0eSB0byB3b3JrIGZvciBh
IHdpZGUgcmFuZ2Ugb2YgdXNlcy4NCj4gDQo+IFNvbWUsIG1heWJlIGJydXRhbCwgaG9uZXN0eSAo
YXBvbG9naWVzKS4uLg0KPiANCj4gSGF2ZSBuZXZlciByZWFsbHkgZ290IHRoZSBncmlwIHdoeSBl
aXRoZXIgU01FIG9yIFRNRSB3b3VsZCBtYWtlDQo+IGlzb2xhdGlvbiBhbnkgYmV0dGVyLiBJZiB5
b3UgY2FuIGJyZWFrIGludG8gaHlwZXJ2aXNvciwgeW91J2xsDQo+IGhhdmUgdGhlc2UgdG9vbHMg
YXZhaWxhYmU6DQo+IA0KPiAxLiBSZWFkIHBhZ2UgKGluIGVuY3J5cHRlZCBmb3JtKS4NCj4gMi4g
V3JpdGUgcGFnZSAoZm9yIGV4YW1wbGUgcmVwbGF5IGFzIHBhZ2VzIGFyZSBub3QgdmVyc2lvbmVk
KS4NCj4gDQo+IHdpdGggYWxsIHRoZSBzaWRlLWNoYW5uZWwgcG9zc2liaWxpdGllcyBvZiBjb3Vy
c2Ugc2luY2UgeW91IGNhbg0KPiBjb250cm9sIHRoZSBWTXMgKGluIHdoaWNoIGNvcmUgdGhleSBl
eGVjdXRlIGV0Yy4pLg0KPiANCj4gSSd2ZSBzZWVuIG5vdyBTTUUgcHJlc2VudGF0aW9uIHRocmVl
IHRpbWVzIGFuZCBpdCBhbHdheXMgbGVhdmVzDQo+IG1lIGFuIGVtcHR5IGZlZWxpbmcuIFRoaXMg
ZmVlbHMgdGhlIHNhbWUgc2FtZS4NCg0KSS5lLiBuZWVkIHRvIHRlbGwgdmVyeSBleHBsaWNpdGx5
IHRoZSBzY2VuYXJpbyB3aGVyZSB0aGlzIHdpbGwNCmhlbHAuIE5vdCBzYXlpbmcgdGhhdCB0aGlz
IHNob3VsZCByZXNvbHZlIGV2ZXJ5dGhpbmcgYnV0IGl0IG11c3QNCnJlc29sdmUgc29tZXRoaW5n
Lg0KDQovSmFya2tvDQo=
