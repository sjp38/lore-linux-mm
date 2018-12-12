Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D88D48E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 10:31:49 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id ay11so13102681plb.20
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 07:31:49 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id q128si16868801pfc.179.2018.12.12.07.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 07:31:48 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 12 Dec 2018 15:31:41 +0000
Message-ID: <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
In-Reply-To: <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <6454B892ACB3F249A8B4ED5C50148AB2@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTEyLTA3IGF0IDE1OjQ1IC0wODAwLCBKYXJra28gU2Fra2luZW4gd3JvdGU6
DQo+IFRoZSBicnV0YWwgZmFjdCBpcyB0aGF0IGEgcGh5c2ljYWwgYWRkcmVzcyBpcyBhbiBhc3Ry
b25vbWljYWwgc3RyZXRjaA0KPiBmcm9tIGEgcmFuZG9tIHZhbHVlIG9yIGluY3JlYXNpbmcgY291
bnRlci4gVGh1cywgaXQgaXMgZmFpciB0byBzYXkgdGhhdA0KPiBNS1RNRSBwcm92aWRlcyBvbmx5
IG5haXZlIG1lYXN1cmVzIGFnYWluc3QgcmVwbGF5IGF0dGFja3MuLi4NCg0KSSdsbCB0cnkgdG8g
c3VtbWFyaXplIGhvdyBJIHVuZGVyc3RhbmQgdGhlIGhpZ2ggbGV2ZWwgc2VjdXJpdHkNCm1vZGVs
IG9mIE1LVE1FIGJlY2F1c2UgKHdvdWxkIGJlIGdvb2QgaWRlYSB0byBkb2N1bWVudCBpdCkuDQoN
CkFzc3VtcHRpb25zOg0KDQoxLiBUaGUgaHlwZXJ2aXNvciBoYXMgbm90IGJlZW4gaW5maWx0cmF0
ZWQuDQoyLiBUaGUgaHlwZXJ2aXNvciBkb2VzIG5vdCBsZWFrIHNlY3JldHMuDQoNCldoZW4gKDEp
IGFuZCAoMikgaG9sZCBbMV0sIHdlIGhhcmRlbiBWTXMgaW4gdHdvIGRpZmZlcmVudCB3YXlzOg0K
DQpBLiBWTXMgY2Fubm90IGxlYWsgZGF0YSB0byBlYWNoIG90aGVyIG9yIGNhbiB0aGV5IHdpdGgg
TDFURiB3aGVuIEhUDQogICBpcyBlbmFibGVkPw0KQi4gUHJvdGVjdHMgYWdhaW5zdCBjb2xkIGJv
b3QgYXR0YWNrcy4NCg0KSXNuJ3QgdGhpcyB3aGF0IHRoaXMgYWJvdXQgaW4gdGhlIG51dHNoZWxs
IHJvdWdobHk/DQoNClsxXSBYUEZPIGNvdWxkIHBvdGVudGlhbGx5IGJlIGFuIG9wdC1pbiBmZWF0
dXJlIHRoYXQgcmVkdWNlcyB0aGUNCiAgICBkYW1hZ2Ugd2hlbiBlaXRoZXIgb2YgdGhlc2UgYXNz
dW1wdGlvbnMgaGFzIGJlZW4gYnJva2VuLg0KDQovSmFya2tvDQo=
