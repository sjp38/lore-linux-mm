Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC5B6B769B
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 17:19:27 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s14so17889991pfk.16
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 14:19:27 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j91si22168873pld.395.2018.12.05.14.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 14:19:25 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 5 Dec 2018 22:19:20 +0000
Message-ID: <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
In-Reply-To: <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C0A385B248C0EA4EA1FC987E003E176F@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "luto@kernel.org" <luto@kernel.org>, "willy@infradead.org" <willy@infradead.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "peterz@infradead.org" <peterz@infradead.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gVHVlLCAyMDE4LTEyLTA0IGF0IDExOjE5IC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IEknbSBub3QgVGhvbWFzLCBidXQgSSB0aGluayBpdCdzIHRoZSB3cm9uZyBkaXJlY3Rpb24u
ICBBcyBpdCBzdGFuZHMsDQo+IGVuY3J5cHRfbXByb3RlY3QoKSBpcyBhbiBpbmNvbXBsZXRlIHZl
cnNpb24gb2YgbXByb3RlY3QoKSAoc2luY2UgaXQncw0KPiBtaXNzaW5nIHRoZSBwcm90ZWN0aW9u
IGtleSBzdXBwb3J0KSwgYW5kIGl0J3MgYWxzbyBmdW5jdGlvbmFsbHkganVzdA0KPiBNQURWX0RP
TlRORUVELiAgSW4gb3RoZXIgd29yZHMsIHRoZSBzb2xlIHVzZXItdmlzaWJsZSBlZmZlY3QgYXBw
ZWFycw0KPiB0byBiZSB0aGF0IHRoZSBleGlzdGluZyBwYWdlcyBhcmUgYmxvd24gYXdheS4gIFRo
ZSBmYWN0IHRoYXQgaXQNCj4gY2hhbmdlcyB0aGUga2V5IGluIHVzZSBkb2Vzbid0IHNlZW0gdGVy
cmlibHkgdXNlZnVsLCBzaW5jZSBpdCdzDQo+IGFub255bW91cyBtZW1vcnksIGFuZCB0aGUgbW9z
dCBzZWN1cmUgY2hvaWNlIGlzIHRvIHVzZSBDUFUtbWFuYWdlZA0KPiBrZXlpbmcsIHdoaWNoIGFw
cGVhcnMgdG8gYmUgdGhlIGRlZmF1bHQgYW55d2F5IG9uIFRNRSBzeXN0ZW1zLiAgSXQNCj4gYWxz
byBoYXMgdG90YWxseSB1bmNsZWFyIHNlbWFudGljcyBXUlQgc3dhcCwgYW5kLCBvZmYgdGhlIHRv
cCBvZiBteQ0KPiBoZWFkLCBpdCBsb29rcyBsaWtlIGl0IG1heSBoYXZlIHNlcmlvdXMgY2FjaGUt
Y29oZXJlbmN5IGlzc3VlcyBhbmQNCj4gbGlrZSBzd2FwcGluZyB0aGUgcGFnZXMgbWlnaHQgY29y
cnVwdCB0aGVtLCBib3RoIGJlY2F1c2UgdGhlcmUgYXJlIG5vDQo+IGZsdXNoZXMgYW5kIGJlY2F1
c2UgdGhlIGRpcmVjdC1tYXAgYWxpYXMgbG9va3MgbGlrZSBpdCB3aWxsIHVzZSB0aGUNCj4gZGVm
YXVsdCBrZXkgYW5kIHRoZXJlZm9yZSBhcHBlYXIgdG8gY29udGFpbiB0aGUgd3JvbmcgZGF0YS4N
Cj4gDQo+IEkgd291bGQgcHJvcG9zZSBhIHZlcnkgZGlmZmVyZW50IGRpcmVjdGlvbjogZG9uJ3Qg
dHJ5IHRvIHN1cHBvcnQgTUtUTUUNCj4gYXQgYWxsIGZvciBhbm9ueW1vdXMgbWVtb3J5LCBhbmQg
aW5zdGVhZCBmaWd1cmUgb3V0IHRoZSBpbXBvcnRhbnQgdXNlDQo+IGNhc2VzIGFuZCBzdXBwb3J0
IHRoZW0gZGlyZWN0bHkuICBUaGUgdXNlIGNhc2VzIHRoYXQgSSBjYW4gdGhpbmsgb2YNCj4gb2Zm
IHRoZSB0b3Agb2YgbXkgaGVhZCBhcmU6DQo+IA0KPiAxLiBwbWVtLiAgVGhpcyBzaG91bGQgcHJv
YmFibHkgdXNlIGEgdmVyeSBkaWZmZXJlbnQgQVBJLg0KPiANCj4gMi4gU29tZSBraW5kIG9mIFZN
IGhhcmRlbmluZywgd2hlcmUgYSBWTSdzIG1lbW9yeSBjYW4gYmUgcHJvdGVjdGVkIGENCj4gbGl0
dGxlIHRpbnkgYml0IGZyb20gdGhlIG1haW4ga2VybmVsLiAgQnV0IEkgZG9uJ3Qgc2VlIHdoeSB0
aGlzIGlzIGFueQ0KPiBiZXR0ZXIgdGhhbiBYUE8gKGVYY2x1c2l2ZSBQYWdlLWZyYW1lIE93bmVy
c2hpcCksIHdoaWNoIGJyaW5ncyB0bw0KPiBtaW5kOg0KDQpXaGF0IGlzIHRoZSB0aHJlYXQgbW9k
ZWwgYW55d2F5IGZvciBBTUQgYW5kIEludGVsIHRlY2hub2xvZ2llcz8NCg0KRm9yIG1lIGl0IGxv
b2tzIGxpa2UgdGhhdCB5b3UgY2FuIHJlYWQsIHdyaXRlIGFuZCBldmVuIHJlcGxheSANCmVuY3J5
cHRlZCBwYWdlcyBib3RoIGluIFNNRSBhbmQgVE1FLiANCg0KL0phcmtrbw0K
