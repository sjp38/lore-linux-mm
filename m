Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D12DC6B7632
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:32:57 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m1-v6so15698232plb.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 12:32:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t184si22422270pfb.22.2018.12.05.12.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 12:32:56 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 5 Dec 2018 20:32:52 +0000
Message-ID: <063026c66b599ba4ff0b30a5ecc7d2c716e4da5b.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <20181204092550.GT11614@hirez.programming.kicks-ass.net>
	 <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
In-Reply-To: <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5B43E6359905644D87CDFB12A5AC1B5F@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>
Cc: "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gVHVlLCAyMDE4LTEyLTA0IGF0IDEyOjQ2ICswMzAwLCBLaXJpbGwgQS4gU2h1dGVtb3Ygd3Jv
dGU6DQo+IE9uIFR1ZSwgRGVjIDA0LCAyMDE4IGF0IDA5OjI1OjUwQU0gKzAwMDAsIFBldGVyIFpp
amxzdHJhIHdyb3RlOg0KPiA+IE9uIE1vbiwgRGVjIDAzLCAyMDE4IGF0IDExOjM5OjQ3UE0gLTA4
MDAsIEFsaXNvbiBTY2hvZmllbGQgd3JvdGU6DQo+ID4gPiAoTXVsdGktS2V5IFRvdGFsIE1lbW9y
eSBFbmNyeXB0aW9uKQ0KPiA+IA0KPiA+IEkgdGhpbmsgdGhhdCBNS1RNRSBpcyBhIGhvcnJpYmxl
IG5hbWUsIGFuZCBkb2Vzbid0IGFwcGVhciB0byBhY2N1cmF0ZWx5DQo+ID4gZGVzY3JpYmUgd2hh
dCBpdCBkb2VzIGVpdGhlci4gU3BlY2lmaWNhbGx5IHRoZSAndG90YWwnIHNlZW1zIG91dCBvZg0K
PiA+IHBsYWNlLCBpdCBkb2Vzbid0IHJlcXVpcmUgYWxsIG1lbW9yeSB0byBiZSBlbmNyeXB0ZWQu
DQo+IA0KPiBNS1RNRSBpbXBsaWVzIFRNRS4gVE1FIGlzIGVuYWJsZWQgYnkgQklPUyBhbmQgaXQg
ZW5jcnlwdHMgYWxsIG1lbW9yeSB3aXRoDQo+IENQVS1nZW5lcmF0ZWQga2V5LiBNS1RNRSBhbGxv
d3MgdG8gdXNlIG90aGVyIGtleXMgb3IgZGlzYWJsZSBlbmNyeXB0aW9uDQo+IGZvciBhIHBhZ2Uu
DQoNCldoZW4geW91IHNheSAiZGlzYWJsZSBlbmNyeXB0aW9uIHRvIGEgcGFnZSIgZG9lcyB0aGUg
ZW5jcnlwdGlvbiBnZXQNCmFjdHVhbGx5IGRpc2FibGVkIG9yIGRvZXMgdGhlIENQVSBqdXN0IGRl
Y3J5cHQgaXQgdHJhbnNwYXJlbnRseSBpLmUuDQp3aGF0IGhhcHBlbnMgcGh5c2ljYWxseT8NCg0K
PiBCdXQsIHllcywgbmFtZSBpcyBub3QgZ29vZC4NCg0KL0phcmtrbw0K
