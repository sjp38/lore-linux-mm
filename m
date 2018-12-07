Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7AAB6B7D99
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 21:05:57 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so1625913pla.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 18:05:57 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c201si1823209pfb.211.2018.12.06.18.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 18:05:56 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Fri, 7 Dec 2018 02:05:50 +0000
Message-ID: <1544148344.28511.21.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
In-Reply-To: <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <44993893C3AA2C4BAD51777EAE072F55@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "luto@kernel.org" <luto@kernel.org>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "willy@infradead.org" <willy@infradead.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "peterz@infradead.org" <peterz@infradead.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gV2VkLCAyMDE4LTEyLTA1IGF0IDIyOjE5ICswMDAwLCBTYWtraW5lbiwgSmFya2tvIHdyb3Rl
Og0KPiBPbiBUdWUsIDIwMTgtMTItMDQgYXQgMTE6MTkgLTA4MDAsIEFuZHkgTHV0b21pcnNraSB3
cm90ZToNCj4gPiBJJ20gbm90IFRob21hcywgYnV0IEkgdGhpbmsgaXQncyB0aGUgd3JvbmcgZGly
ZWN0aW9uLiAgQXMgaXQgc3RhbmRzLA0KPiA+IGVuY3J5cHRfbXByb3RlY3QoKSBpcyBhbiBpbmNv
bXBsZXRlIHZlcnNpb24gb2YgbXByb3RlY3QoKSAoc2luY2UgaXQncw0KPiA+IG1pc3NpbmcgdGhl
IHByb3RlY3Rpb24ga2V5IHN1cHBvcnQpLCBhbmQgaXQncyBhbHNvIGZ1bmN0aW9uYWxseSBqdXN0
DQo+ID4gTUFEVl9ET05UTkVFRC4gIEluIG90aGVyIHdvcmRzLCB0aGUgc29sZSB1c2VyLXZpc2li
bGUgZWZmZWN0IGFwcGVhcnMNCj4gPiB0byBiZSB0aGF0IHRoZSBleGlzdGluZyBwYWdlcyBhcmUg
Ymxvd24gYXdheS4gIFRoZSBmYWN0IHRoYXQgaXQNCj4gPiBjaGFuZ2VzIHRoZSBrZXkgaW4gdXNl
IGRvZXNuJ3Qgc2VlbSB0ZXJyaWJseSB1c2VmdWwsIHNpbmNlIGl0J3MNCj4gPiBhbm9ueW1vdXMg
bWVtb3J5LCBhbmQgdGhlIG1vc3Qgc2VjdXJlIGNob2ljZSBpcyB0byB1c2UgQ1BVLW1hbmFnZWQN
Cj4gPiBrZXlpbmcsIHdoaWNoIGFwcGVhcnMgdG8gYmUgdGhlIGRlZmF1bHQgYW55d2F5IG9uIFRN
RSBzeXN0ZW1zLiAgSXQNCj4gPiBhbHNvIGhhcyB0b3RhbGx5IHVuY2xlYXIgc2VtYW50aWNzIFdS
VCBzd2FwLCBhbmQsIG9mZiB0aGUgdG9wIG9mIG15DQo+ID4gaGVhZCwgaXQgbG9va3MgbGlrZSBp
dCBtYXkgaGF2ZSBzZXJpb3VzIGNhY2hlLWNvaGVyZW5jeSBpc3N1ZXMgYW5kDQo+ID4gbGlrZSBz
d2FwcGluZyB0aGUgcGFnZXMgbWlnaHQgY29ycnVwdCB0aGVtLCBib3RoIGJlY2F1c2UgdGhlcmUg
YXJlIG5vDQo+ID4gZmx1c2hlcyBhbmQgYmVjYXVzZSB0aGUgZGlyZWN0LW1hcCBhbGlhcyBsb29r
cyBsaWtlIGl0IHdpbGwgdXNlIHRoZQ0KPiA+IGRlZmF1bHQga2V5IGFuZCB0aGVyZWZvcmUgYXBw
ZWFyIHRvIGNvbnRhaW4gdGhlIHdyb25nIGRhdGEuDQo+ID4gDQo+ID4gSSB3b3VsZCBwcm9wb3Nl
IGEgdmVyeSBkaWZmZXJlbnQgZGlyZWN0aW9uOiBkb24ndCB0cnkgdG8gc3VwcG9ydCBNS1RNRQ0K
PiA+IGF0IGFsbCBmb3IgYW5vbnltb3VzIG1lbW9yeSwgYW5kIGluc3RlYWQgZmlndXJlIG91dCB0
aGUgaW1wb3J0YW50IHVzZQ0KPiA+IGNhc2VzIGFuZCBzdXBwb3J0IHRoZW0gZGlyZWN0bHkuICBU
aGUgdXNlIGNhc2VzIHRoYXQgSSBjYW4gdGhpbmsgb2YNCj4gPiBvZmYgdGhlIHRvcCBvZiBteSBo
ZWFkIGFyZToNCj4gPiANCj4gPiAxLiBwbWVtLiAgVGhpcyBzaG91bGQgcHJvYmFibHkgdXNlIGEg
dmVyeSBkaWZmZXJlbnQgQVBJLg0KPiA+IA0KPiA+IDIuIFNvbWUga2luZCBvZiBWTSBoYXJkZW5p
bmcsIHdoZXJlIGEgVk0ncyBtZW1vcnkgY2FuIGJlIHByb3RlY3RlZCBhDQo+ID4gbGl0dGxlIHRp
bnkgYml0IGZyb20gdGhlIG1haW4ga2VybmVsLiAgQnV0IEkgZG9uJ3Qgc2VlIHdoeSB0aGlzIGlz
IGFueQ0KPiA+IGJldHRlciB0aGFuIFhQTyAoZVhjbHVzaXZlIFBhZ2UtZnJhbWUgT3duZXJzaGlw
KSwgd2hpY2ggYnJpbmdzIHRvDQo+ID4gbWluZDoNCj4gDQo+IFdoYXQgaXMgdGhlIHRocmVhdCBt
b2RlbCBhbnl3YXkgZm9yIEFNRCBhbmQgSW50ZWwgdGVjaG5vbG9naWVzPw0KPiANCj4gRm9yIG1l
IGl0IGxvb2tzIGxpa2UgdGhhdCB5b3UgY2FuIHJlYWQsIHdyaXRlIGFuZCBldmVuIHJlcGxheSAN
Cj4gZW5jcnlwdGVkIHBhZ2VzIGJvdGggaW4gU01FIGFuZCBUTUUuIA0KDQpSaWdodC4gTmVpdGhl
ciBvZiB0aGVtIChpbmNsdWRpbmcgTUtUTUUpIHByZXZlbnRzIHJlcGxheSBhdHRhY2suIEJ1dCBp
biBteSB1bmRlcnN0YW5kaW5nIFNFViBkb2Vzbid0DQpwcmV2ZW50IHJlcGxheSBhdHRhY2sgZWl0
aGVyIHNpbmNlIGl0IGRvZXNuJ3QgaGF2ZSBpbnRlZ3JpdHkgcHJvdGVjdGlvbi4NCg0KVGhhbmtz
LA0KLUthaQ0K
