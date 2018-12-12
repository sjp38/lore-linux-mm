Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6A68E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 11:44:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so15787450pfj.15
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 08:44:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v13si15094775pgn.355.2018.12.12.08.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 08:44:00 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 12 Dec 2018 16:43:54 +0000
Message-ID: <42cb695e947e2c98a989285778d56a241fe67e7f.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
	 <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
	 <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
In-Reply-To: <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <87DD9A480BEDC748BA363349C285C8C1@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gV2VkLCAyMDE4LTEyLTEyIGF0IDA4OjI5IC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IE9uIFdlZCwgRGVjIDEyLCAyMDE4IGF0IDc6MzEgQU0gU2Fra2luZW4sIEphcmtrbw0KPiA8
amFya2tvLnNha2tpbmVuQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gT24gRnJpLCAyMDE4LTEyLTA3
IGF0IDE1OjQ1IC0wODAwLCBKYXJra28gU2Fra2luZW4gd3JvdGU6DQo+ID4gPiBUaGUgYnJ1dGFs
IGZhY3QgaXMgdGhhdCBhIHBoeXNpY2FsIGFkZHJlc3MgaXMgYW4gYXN0cm9ub21pY2FsIHN0cmV0
Y2gNCj4gPiA+IGZyb20gYSByYW5kb20gdmFsdWUgb3IgaW5jcmVhc2luZyBjb3VudGVyLiBUaHVz
LCBpdCBpcyBmYWlyIHRvIHNheSB0aGF0DQo+ID4gPiBNS1RNRSBwcm92aWRlcyBvbmx5IG5haXZl
IG1lYXN1cmVzIGFnYWluc3QgcmVwbGF5IGF0dGFja3MuLi4NCj4gPiANCj4gPiBJJ2xsIHRyeSB0
byBzdW1tYXJpemUgaG93IEkgdW5kZXJzdGFuZCB0aGUgaGlnaCBsZXZlbCBzZWN1cml0eQ0KPiA+
IG1vZGVsIG9mIE1LVE1FIGJlY2F1c2UgKHdvdWxkIGJlIGdvb2QgaWRlYSB0byBkb2N1bWVudCBp
dCkuDQo+ID4gDQo+ID4gQXNzdW1wdGlvbnM6DQo+ID4gDQo+ID4gMS4gVGhlIGh5cGVydmlzb3Ig
aGFzIG5vdCBiZWVuIGluZmlsdHJhdGVkLg0KPiA+IDIuIFRoZSBoeXBlcnZpc29yIGRvZXMgbm90
IGxlYWsgc2VjcmV0cy4NCj4gPiANCj4gPiBXaGVuICgxKSBhbmQgKDIpIGhvbGQgWzFdLCB3ZSBo
YXJkZW4gVk1zIGluIHR3byBkaWZmZXJlbnQgd2F5czoNCj4gPiANCj4gPiBBLiBWTXMgY2Fubm90
IGxlYWsgZGF0YSB0byBlYWNoIG90aGVyIG9yIGNhbiB0aGV5IHdpdGggTDFURiB3aGVuIEhUDQo+
ID4gICAgaXMgZW5hYmxlZD8NCj4gDQo+IEkgc3Ryb25nbHkgc3VzcGVjdCB0aGF0LCBvbiBMMVRG
LXZ1bG5lcmFibGUgQ1BVcywgTUtUTUUgcHJvdmlkZXMgbm8NCj4gcHJvdGVjdGlvbiB3aGF0c29l
dmVyLiAgSXQgc291bmRzIGxpa2UgTUtUTUUgaXMgaW1wbGVtZW50ZWQgaW4gdGhlDQo+IG1lbW9y
eSBjb250cm9sbGVyIC0tIGFzIGZhciBhcyB0aGUgcmVzdCBvZiB0aGUgQ1BVIGFuZCB0aGUgY2Fj
aGUNCj4gaGllcmFyY2h5IGFyZSBjb25jZXJuZWQsIHRoZSBNS1RNRSBrZXkgc2VsY3Rpb24gYml0
cyBhcmUganVzdCBwYXJ0IG9mDQo+IHRoZSBwaHlzaWNhbCBhZGRyZXNzLiAgU28gYW4gYXR0YWNr
IGxpa2UgTDFURiB0aGF0IGxlYWtzIGEgY2FjaGVsaW5lDQo+IHRoYXQncyBzZWxlY3RlZCBieSBw
aHlzaWNhbCBhZGRyZXNzIHdpbGwgbGVhayB0aGUgY2xlYXJ0ZXh0IGlmIHRoZSBrZXkNCj4gc2Vs
ZWN0aW9uIGJpdHMgYXJlIHNldCBjb3JyZWN0bHkuDQo+IA0KPiAoSSBzdXBwb3NlIHRoYXQsIGlm
IHRoZSBhdHRhY2tlciBuZWVkcyB0byBicnV0ZS1mb3JjZSB0aGUgcGh5c2ljYWwNCj4gYWRkcmVz
cywgdGhlbiBNS1RNRSBtYWtlcyBpdCBhIGJpdCBoYXJkZXIgYmVjYXVzZSB0aGUgZWZmZWN0aXZl
DQo+IHBoeXNpY2FsIGFkZHJlc3Mgc3BhY2UgaXMgbGFyZ2VyLikNCj4gDQo+ID4gQi4gUHJvdGVj
dHMgYWdhaW5zdCBjb2xkIGJvb3QgYXR0YWNrcy4NCj4gDQo+IFRNRSBkb2VzIHRoaXMsIEFGQUlL
LiAgTUtUTUUgZG9lcywgdG9vLCB1bmxlc3MgdGhlICJ1c2VyIiBtb2RlIGlzDQo+IHVzZWQsIGlu
IHdoaWNoIGNhc2UgdGhlIHByb3RlY3Rpb24gaXMgd2Vha2VyLg0KPiANCj4gPiBJc24ndCB0aGlz
IHdoYXQgdGhpcyBhYm91dCBpbiB0aGUgbnV0c2hlbGwgcm91Z2hseT8NCj4gPiANCj4gPiBbMV0g
WFBGTyBjb3VsZCBwb3RlbnRpYWxseSBiZSBhbiBvcHQtaW4gZmVhdHVyZSB0aGF0IHJlZHVjZXMg
dGhlDQo+ID4gICAgIGRhbWFnZSB3aGVuIGVpdGhlciBvZiB0aGVzZSBhc3N1bXB0aW9ucyBoYXMg
YmVlbiBicm9rZW4uDQoNClRoaXMgYWxsIHNob3VsZCBiZSBzdW1tYXJpemVkIGluIHRoZSBkb2N1
bWVudGF0aW9uIChoaWdoLWxldmVsIG1vZGVsDQphbmQgY29ybmVyIGNhc2VzKS4NCg0KL0phcmtr
bw0K
