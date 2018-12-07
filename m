Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 906986B7D91
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 20:59:44 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so1580872pls.21
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 17:59:44 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d9si1602255plr.127.2018.12.06.17.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 17:59:43 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Fri, 7 Dec 2018 01:55:45 +0000
Message-ID: <1544147742.28511.18.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
	 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
In-Reply-To: <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <49D1575746A191458BCF298E4A0C0D8E@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "peterz@infradead.org" <peterz@infradead.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "Schofield, Alison" <alison.schofield@intel.com>, Nakajima,

DQo+IA0KPiBUTUUgaXRzZWxmIHByb3ZpZGVzIGEgdG9uIG9mIHByb3RlY3Rpb24gLS0geW91IGNh
bid0IGp1c3QgYmFyZ2UgaW50bw0KPiB0aGUgZGF0YWNlbnRlciwgcmVmcmlnZXJhdGUgdGhlIERJ
TU1zLCB3YWxrIGF3YXkgd2l0aCB0aGVtLCBhbmQgcmVhZA0KPiBvZmYgZXZlcnlvbmUncyBkYXRh
Lg0KPiANCj4gQW0gSSBtaXNzaW5nIHNvbWV0aGluZz8NCg0KSSB0aGluayB3ZSBjYW4gbWFrZSBz
dWNoIGFzc3VtcHRpb24gaW4gbW9zdCBjYXNlcywgYnV0IEkgdGhpbmsgaXQncyBiZXR0ZXIgdGhh
dCB3ZSBkb24ndCBtYWtlIGFueQ0KYXNzdW1wdGlvbiBhdCBhbGwuIEZvciBleGFtcGxlLCB0aGUg
YWRtaW4gb2YgZGF0YSBjZW50ZXIgKG9yIGFueW9uZSkgd2hvIGhhcyBwaHlzaWNhbCBhY2Nlc3Mg
dG8NCnNlcnZlcnMgbWF5IGRvIHNvbWV0aGluZyBtYWxpY2lvdXMuIEkgYW0gbm90IGV4cGVydCBi
dXQgdGhlcmUgc2hvdWxkIGJlIG90aGVyIHBoeXNpY2FsIGF0dGFjaw0KbWV0aG9kcyBiZXNpZGVz
IGNvbGRib290IGF0dGFjaywgaWYgdGhlIG1hbGljaW91cyBlbXBsb3llZSBjYW4gZ2V0IHBoeXNp
Y2FsIGFjY2VzcyB0byBzZXJ2ZXIgdy9vDQpiZWluZyBkZXRlY3RlZC4NCg0KPiANCj4gPiANCj4g
PiBCdXQsIEkgdGhpbmsgd2hhdCB5b3UncmUgaW1wbHlpbmcgaXMgdGhhdCB0aGUgc2VjdXJpdHkg
cHJvcGVydGllcyBvZg0KPiA+IHVzZXItc3VwcGxpZWQga2V5cyBjYW4gb25seSBiZSAqd29yc2Uq
IHRoYW4gdXNpbmcgQ1BVLWdlbmVyYXRlZCBrZXlzDQo+ID4gKGFzc3VtaW5nIHRoZSBDUFUgZG9l
cyBhIGdvb2Qgam9iIGdlbmVyYXRpbmcgaXQpLiAgU28sIHdoeSBib3RoZXINCj4gPiBhbGxvd2lu
ZyB1c2VyLXNwZWNpZmllZCBrZXlzIGluIHRoZSBmaXJzdCBwbGFjZT8NCj4gDQo+IFRoYXQgdG9v
IDopDQoNCkkgdGhpbmsgb25lIHVzYWdlIG9mIHVzZXItc3BlY2lmaWVkIGtleSBpcyBmb3IgTlZE
SU1NLCBzaW5jZSBDUFUga2V5IHdpbGwgYmUgZ29uZSBhZnRlciBtYWNoaW5lDQpyZWJvb3QsIHRo
ZXJlZm9yZSBpZiBOVkRJTU0gaXMgZW5jcnlwdGVkIGJ5IENQVSBrZXkgd2UgYXJlIG5vdCBhYmxl
IHRvIHJldHJpZXZlIGl0IG9uY2UNCnNodXRkb3duL3JlYm9vdCwgZXRjLg0KDQpUaGVyZSBhcmUg
c29tZSBvdGhlciB1c2UgY2FzZXMgdGhhdCBhbHJlYWR5IHJlcXVpcmUgdGVuYW50IHRvIHNlbmQg
a2V5IHRvIENTUC4gRm9yIGV4YW1wbGUsIHRoZSBWTQ0KaW1hZ2UgY2FuIGJlIHByb3ZpZGVkIGJ5
IHRlbmFudCBhbmQgZW5jcnlwdGVkIGJ5IHRlbmFudCdzIG93biBrZXksIGFuZCB0ZW5hbnQgbmVl
ZHMgdG8gc2VuZCBrZXkgdG8NCkNTUCB3aGVuIGFza2luZyBDU1AgdG8gcnVuIHRoYXQgZW5jcnlw
dGVkIGltYWdlLiBCdXQgdGVuYW50IHdpbGwgbmVlZCB0byB0cnVzdCBDU1AgaW4gc3VjaCBjYXNl
LA0Kd2hpY2ggYnJpbmdzIHVzIHdoeSB0ZW5hbnQgd2FudHMgdG8gdXNlIGhpcyBvd24gaW1hZ2Ug
YXQgZmlyc3QgcGxhY2UgKEkgaGF2ZSB0byBzYXkgSSBteXNlbGYgaXMgbm90DQpjb252aW5jZWQg
dGhlIHZhbHVlIG9mIHN1Y2ggdXNlIGNhc2UpLiBJIHRoaW5rIHRoZXJlIGFyZSB0d28gbGV2ZWxz
IG9mIHRydXN0aW5lc3MgaW52b2x2ZWQgaGVyZTogMSkNCnRlbmFudCBuZWVkcyB0byB0cnVzdCBD
U1AgYW55d2F5OyAyKSBidXQgQ1NQIG5lZWRzIHRvIGNvbnZpbmNlIHRlbmFudCB0aGF0IENTUCBj
YW4gYmUgdHJ1c3RlZCwgaWUsDQpieSBwcm92aW5nIGl0IGNhbiBwcmV2ZW50IHBvdGVudGlhbCBh
dHRhY2sgZnJvbSBtYWxpY2lvdXMgZW1wbG95ZWUgKGllLCBieSByYWlzaW5nIGJhciBieSB1c2lu
Zw0KTUtUTUUpLCBldGMuDQoNClRoYW5rcywNCi1LYWk=
