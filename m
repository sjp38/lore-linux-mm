Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0378E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 22:53:57 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so3862205pgu.18
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 19:53:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i20si4277862pgh.187.2018.12.07.19.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 19:53:55 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Sat, 8 Dec 2018 03:53:50 +0000
Message-ID: <405976bf5c6332096e205af1a647d24d03af8c32.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
	 <1544232812.28511.39.camel@intel.com>
In-Reply-To: <1544232812.28511.39.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B43DCB342BCB434BBC4409AEAEB6F6C7@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>, "Huang, Kai" <kai.huang@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gU2F0LCAyMDE4LTEyLTA4IGF0IDA5OjMzICswODAwLCBIdWFuZywgS2FpIHdyb3RlOg0KPiBD
dXJyZW50bHkgdGhlcmUncyBubyBub25jZSB0byBwcm90ZWN0IGNhY2hlIGxpbmUgc28gVE1FL01L
VE1FIGlzIG5vdCBhYmxlIHRvDQo+IHByZXZlbnQgcmVwbGF5IGF0dGFjaw0KPiB5b3UgbWVudGlv
bmVkLiBDdXJyZW50bHkgTUtUTUUgb25seSBpbnZvbHZlcyBBRVMtWFRTLTEyOCBlbmNyeXB0aW9u
IGJ1dA0KPiBub3RoaW5nIGVsc2UuIEJ1dCBsaWtlIEkNCj4gc2FpZCBpZiBJIHVuZGVyc3RhbmQg
Y29ycmVjdGx5IGV2ZW4gU0VWIGRvZXNuJ3QgaGF2ZSBpbnRlZ3JpdHkgcHJvdGVjdGlvbiBzbw0K
PiBub3QgYWJsZSB0byBwcmV2ZW50DQo+IHJlcGx5IGF0dGFjayBhcyB3ZWxsLg0KDQpZb3UncmUg
YWJzb2x1dGVseSBjb3JyZWN0Lg0KDQpUaGVyZSdzIGEgYWxzbyBnb29kIHBhcGVyIG9uIFNFViBz
dWJ2ZXJ0aW9uOg0KDQpodHRwczovL2FyeGl2Lm9yZy9wZGYvMTgwNS4wOTYwNC5wZGYNCg0KSSBk
b24ndCB0aGluayB0aGlzIG1ha2VzIE1LVE1FIG9yIFNFViB1c2Vsc3MsIGJ1dCB5ZWFoLCBpdCBp
cyBhDQpjb25zdHJhaW50IHRoYXQgbmVlZHMgdG8gYmUgdGFrZW4gaW50byBjb25zaWRlcmF0aW9u
IHdoZW4gZmluZGluZyB0aGUNCmJlc3Qgd2F5IHRvIHVzZSB0aGVzZSB0ZWNobm9sb2dpZXMgaW4g
TGludXguDQoNCi9KYXJra28NCg==
