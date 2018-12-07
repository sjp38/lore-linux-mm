Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6738E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 16:59:33 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so4468517pfj.15
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 13:59:33 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g6si3845778plp.132.2018.12.07.13.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 13:59:31 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Fri, 7 Dec 2018 21:59:27 +0000
Message-ID: <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
In-Reply-To: <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0AA883A02E9D764DA7910B6F5FEDB45C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTEyLTA3IGF0IDE0OjU3ICswMzAwLCBLaXJpbGwgQS4gU2h1dGVtb3Ygd3Jv
dGU6DQo+ID4gV2hhdCBpcyB0aGUgdGhyZWF0IG1vZGVsIGFueXdheSBmb3IgQU1EIGFuZCBJbnRl
bCB0ZWNobm9sb2dpZXM/DQo+ID4gDQo+ID4gRm9yIG1lIGl0IGxvb2tzIGxpa2UgdGhhdCB5b3Ug
Y2FuIHJlYWQsIHdyaXRlIGFuZCBldmVuIHJlcGxheSANCj4gPiBlbmNyeXB0ZWQgcGFnZXMgYm90
aCBpbiBTTUUgYW5kIFRNRS4gDQo+IA0KPiBXaGF0IHJlcGxheSBhdHRhY2sgYXJlIHlvdSB0YWxr
aW5nIGFib3V0PyBNS1RNRSB1c2VzIEFFUy1YVFMgd2l0aCBwaHlzaWNhbA0KPiBhZGRyZXNzIHR3
ZWFrLiBTbyB0aGUgZGF0YSBpcyB0aWVkIHRvIHRoZSBwbGFjZSBpbiBwaHlzaWNhbCBhZGRyZXNz
IHNwYWNlIGFuZA0KPiByZXBsYWNpbmcgb25lIGVuY3J5cHRlZCBwYWdlIHdpdGggYW5vdGhlciBl
bmNyeXB0ZWQgcGFnZSBmcm9tIGRpZmZlcmVudA0KPiBhZGRyZXNzIHdpbGwgcHJvZHVjZSBnYXJi
YWdlIG9uIGRlY3J5cHRpb24uDQoNCkp1c3QgdHJ5aW5nIHRvIHVuZGVyc3RhbmQgaG93IHRoaXMg
d29ya3MuDQoNClNvIHlvdSB1c2UgcGh5c2ljYWwgYWRkcmVzcyBsaWtlIGEgbm9uY2UvdmVyc2lv
biBmb3IgdGhlIHBhZ2UgYW5kDQp0aHVzIHByZXZlbnQgcmVwbGF5PyBXYXMgbm90IGF3YXJlIG9m
IHRoaXMuDQoNCi9KYXJra28NCg==
