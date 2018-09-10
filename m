Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27CF88E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:32:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x85-v6so11526033pfe.13
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:32:28 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f35-v6si15044557plh.33.2018.09.10.10.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 10:32:27 -0700 (PDT)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
Date: Mon, 10 Sep 2018 17:32:20 +0000
Message-ID: <437f79cf2512f3aef200f7d0bfba4c99a1834eff.camel@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
	 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5D15F5D9C149224FBCDC3F1CB66F788A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang,
 Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTA5LTA3IGF0IDE1OjM0IC0wNzAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBEb2N1bWVudCB0aGUgQVBJJ3MgdXNlZCBmb3IgTUtUTUUgb24gSW50ZWwgcGxhdGZvcm1z
Lg0KPiBNS1RNRTogTXVsdGktS0VZIFRvdGFsIE1lbW9yeSBFbmNyeXB0aW9uDQo+IA0KPiBTaWdu
ZWQtb2ZmLWJ5OiBBbGlzb24gU2Nob2ZpZWxkIDxhbGlzb24uc2Nob2ZpZWxkQGludGVsLmNvbT4N
Cj4gLS0tDQo+ICBEb2N1bWVudGF0aW9uL3g4Ni9ta3RtZS1rZXlzLnR4dCB8IDE1Mw0KPiArKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysNCj4gIDEgZmlsZSBjaGFuZ2VkLCAx
NTMgaW5zZXJ0aW9ucygrKQ0KPiAgY3JlYXRlIG1vZGUgMTAwNjQ0IERvY3VtZW50YXRpb24veDg2
L21rdG1lLWtleXMudHh0DQo+IA0KPiBkaWZmIC0tZ2l0IGEvRG9jdW1lbnRhdGlvbi94ODYvbWt0
bWUta2V5cy50eHQgYi9Eb2N1bWVudGF0aW9uL3g4Ni9ta3RtZS0NCj4ga2V5cy50eHQNCj4gbmV3
IGZpbGUgbW9kZSAxMDA2NDQNCj4gaW5kZXggMDAwMDAwMDAwMDAwLi4yZGVhN2FjZDJhMTcNCj4g
LS0tIC9kZXYvbnVsbA0KPiArKysgYi9Eb2N1bWVudGF0aW9uL3g4Ni9ta3RtZS1rZXlzLnR4dA0K
PiBAQCAtMCwwICsxLDE1MyBAQA0KPiArTUtUTUUgKE11bHRpLUtleSBUb3RhbCBNZW1vcnkgRW5j
cnlwdGlvbikgaXMgYSB0ZWNobm9sb2d5IHRoYXQgYWxsb3dzDQo+ICttZW1vcnkgZW5jcnlwdGlv
biBvbiBJbnRlbCBwbGF0Zm9ybXMuIFdoZXJlYXMgVE1FIChUb3RhbCBNZW1vcnkgRW5jcnlwdGlv
bikNCj4gK2FsbG93cyBlbmNyeXB0aW9uIG9mIHRoZSBlbnRpcmUgc3lzdGVtIG1lbW9yeSB1c2lu
ZyBhIHNpbmdsZSBrZXksIE1LVE1FDQo+ICthbGxvd3MgbXVsdGlwbGUgZW5jcnlwdGlvbiBkb21h
aW5zLCBlYWNoIGhhdmluZyB0aGVpciBvd24ga2V5LiBUaGUgbWFpbiB1c2UNCj4gK2Nhc2UgZm9y
IHRoZSBmZWF0dXJlIGlzIHZpcnR1YWwgbWFjaGluZSBpc29sYXRpb24uIFRoZSBBUEkncyBpbnRy
b2R1Y2VkIGhlcmUNCj4gK2FyZSBpbnRlbmRlZCB0byBvZmZlciBmbGV4aWJpbGl0eSB0byB3b3Jr
IGluIGEgd2lkZSByYW5nZSBvZiB1c2VzLg0KPiArDQo+ICtUaGUgZXh0ZXJuYWxseSBhdmFpbGFi
bGUgSW50ZWwgQXJjaGl0ZWN0dXJlIFNwZWM6DQo+ICtodHRwczovL3NvZnR3YXJlLmludGVsLmNv
bS9zaXRlcy9kZWZhdWx0L2ZpbGVzL21hbmFnZWQvYTUvMTYvTXVsdGktS2V5LVRvdGFsLQ0KPiBN
ZW1vcnktRW5jcnlwdGlvbi1TcGVjLnBkZg0KPiArDQo+ICs9PT09PT09PT09PT09PT09PT09PT09
PT09PT09ICBBUEkgT3ZlcnZpZXcgID09PT09PT09PT09PT09PT09PT09PT09PT09PT0NCj4gKw0K
PiArVGhlcmUgYXJlIDIgTUtUTUUgc3BlY2lmaWMgQVBJJ3MgdGhhdCBlbmFibGUgdXNlcnNwYWNl
IHRvIGNyZWF0ZSBhbmQgdXNlDQo+ICt0aGUgbWVtb3J5IGVuY3J5cHRpb24ga2V5czoNCg0KVGhp
cyBpcyBsaWtlIHNheWluZyB0aGF0IHRoZXkgYXJlIGRpZmZlcmVudCBBUElzIHRvIGRvIHNlbWFu
dGljYWxseSB0aGUNCnNhbWUgZXhhY3QgdGhpbmcuIElzIHRoYXQgc28/DQoNCi9KYXJra28=
