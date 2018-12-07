Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 192BE8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:45:21 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so3620254pgt.11
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:45:21 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y20si3970410plp.415.2018.12.07.15.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 15:45:20 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Fri, 7 Dec 2018 23:45:14 +0000
Message-ID: <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
In-Reply-To: <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B14A143DE6497545AB154E1FB659B42E@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Alison  <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTEyLTA3IGF0IDEzOjU5IC0wODAwLCBKYXJra28gU2Fra2luZW4gd3JvdGU6
DQo+IE9uIEZyaSwgMjAxOC0xMi0wNyBhdCAxNDo1NyArMDMwMCwgS2lyaWxsIEEuIFNodXRlbW92
IHdyb3RlOg0KPiA+ID4gV2hhdCBpcyB0aGUgdGhyZWF0IG1vZGVsIGFueXdheSBmb3IgQU1EIGFu
ZCBJbnRlbCB0ZWNobm9sb2dpZXM/DQo+ID4gPiANCj4gPiA+IEZvciBtZSBpdCBsb29rcyBsaWtl
IHRoYXQgeW91IGNhbiByZWFkLCB3cml0ZSBhbmQgZXZlbiByZXBsYXkgDQo+ID4gPiBlbmNyeXB0
ZWQgcGFnZXMgYm90aCBpbiBTTUUgYW5kIFRNRS4gDQo+ID4gDQo+ID4gV2hhdCByZXBsYXkgYXR0
YWNrIGFyZSB5b3UgdGFsa2luZyBhYm91dD8gTUtUTUUgdXNlcyBBRVMtWFRTIHdpdGggcGh5c2lj
YWwNCj4gPiBhZGRyZXNzIHR3ZWFrLiBTbyB0aGUgZGF0YSBpcyB0aWVkIHRvIHRoZSBwbGFjZSBp
biBwaHlzaWNhbCBhZGRyZXNzIHNwYWNlDQo+ID4gYW5kDQo+ID4gcmVwbGFjaW5nIG9uZSBlbmNy
eXB0ZWQgcGFnZSB3aXRoIGFub3RoZXIgZW5jcnlwdGVkIHBhZ2UgZnJvbSBkaWZmZXJlbnQNCj4g
PiBhZGRyZXNzIHdpbGwgcHJvZHVjZSBnYXJiYWdlIG9uIGRlY3J5cHRpb24uDQo+IA0KPiBKdXN0
IHRyeWluZyB0byB1bmRlcnN0YW5kIGhvdyB0aGlzIHdvcmtzLg0KPiANCj4gU28geW91IHVzZSBw
aHlzaWNhbCBhZGRyZXNzIGxpa2UgYSBub25jZS92ZXJzaW9uIGZvciB0aGUgcGFnZSBhbmQNCj4g
dGh1cyBwcmV2ZW50IHJlcGxheT8gV2FzIG5vdCBhd2FyZSBvZiB0aGlzLg0KDQpUaGUgYnJ1dGFs
IGZhY3QgaXMgdGhhdCBhIHBoeXNpY2FsIGFkZHJlc3MgaXMgYW4gYXN0cm9ub21pY2FsIHN0cmV0
Y2gNCmZyb20gYSByYW5kb20gdmFsdWUgb3IgaW5jcmVhc2luZyBjb3VudGVyLiBUaHVzLCBpdCBp
cyBmYWlyIHRvIHNheSB0aGF0DQpNS1RNRSBwcm92aWRlcyBvbmx5IG5haXZlIG1lYXN1cmVzIGFn
YWluc3QgcmVwbGF5IGF0dGFja3MuLi4NCg0KL0phcmtrbw0K
