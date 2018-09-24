Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A956D8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:58:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id o27-v6so10620384pfj.6
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:58:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b4-v6si121913pla.46.2018.09.24.11.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 11:58:45 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v6 3/4] vmalloc: Add debugfs modfraginfo
Date: Mon, 24 Sep 2018 18:58:44 +0000
Message-ID: <1537815554.19013.49.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
	 <1536874298-23492-4-git-send-email-rick.p.edgecombe@intel.com>
	 <CAGXu5jJj+08J9UeyQs5ku8CziYWA72iJ+hxMR2Z2tLiVwvU8MA@mail.gmail.com>
In-Reply-To: <CAGXu5jJj+08J9UeyQs5ku8CziYWA72iJ+hxMR2Z2tLiVwvU8MA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C183D5357C751A439DE80245741D78EA@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keescook@chromium.org" <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jannh@google.com" <jannh@google.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gRnJpLCAyMDE4LTA5LTIxIGF0IDExOjU2IC0wNzAwLCBLZWVzIENvb2sgd3JvdGU6DQo+IE9u
IFRodSwgU2VwIDEzLCAyMDE4IGF0IDI6MzEgUE0sIFJpY2sgRWRnZWNvbWJlDQo+IDxyaWNrLnAu
ZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gK2RvbmU6DQo+ID4gK8KgwqDCoMKgwqDC
oMKgZ2FwID0gKE1PRFVMRVNfRU5EIC0gbGFzdF9lbmQpOw0KPiA+ICvCoMKgwqDCoMKgwqDCoGlm
IChnYXAgPiBsYXJnZXN0X2ZyZWUpDQo+ID4gK8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oGxhcmdlc3RfZnJlZSA9IGdhcDsNCj4gPiArwqDCoMKgwqDCoMKgwqB0b3RhbF9mcmVlICs9IGdh
cDsNCj4gPiArDQo+ID4gK8KgwqDCoMKgwqDCoMKgc3Bpbl91bmxvY2soJnZtYXBfYXJlYV9sb2Nr
KTsNCj4gPiArDQo+ID4gK8KgwqDCoMKgwqDCoMKgc2VxX3ByaW50ZihtLCAiXHRMYXJnZXN0IGZy
ZWUgc3BhY2U6XHQlbHUga0JcbiIsIGxhcmdlc3RfZnJlZSAvDQo+ID4gMTAyNCk7DQo+ID4gK8Kg
wqDCoMKgwqDCoMKgc2VxX3ByaW50ZihtLCAiXHTCoMKgVG90YWwgZnJlZSBzcGFjZTpcdCVsdSBr
QlxuIiwgdG90YWxfZnJlZSAvIDEwMjQpOw0KPiA+ICsNCj4gPiArwqDCoMKgwqDCoMKgwqBpZiAo
SVNfRU5BQkxFRChDT05GSUdfUkFORE9NSVpFX0JBU0UpICYmIGthc2xyX2VuYWJsZWQoKSkNCj4g
PiArwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgc2VxX3ByaW50ZihtLCAiQWxsb2NhdGlv
bnMgaW4gYmFja3VwIGFyZWE6XHQlbHVcbiIsDQo+ID4gYmFja3VwX2NudCk7DQo+IEkgZG9uJ3Qg
dGhpbmsgdGhlIElTX0VOQUJMRUQgaXMgbmVlZGVkIGhlcmU/DQpUaGUgcmVhc29uIGZvcsKgdGhp
cyBpcyB0aGF0IGZvciBBUkNIPXVtLCBDT05GSUdfWDg2XzY0IGlzIGRlZmluZWQgYnV0DQprYXNs
cl9lbmFibGVkIGlzIG5vdC4ga2FzbHJfZW5hYmxlZCBpcyBkZWNsYXJlZCBhYm92ZSB0byBwcm90
ZWN0IGFnYWluc3QgYQ0KY29tcGlsZXIgZXJyb3IuDQoNClNvIElTX0VOQUJMRUQoQ09ORklHX1JB
TkRPTUlaRV9CQVNFKSBpcyBwcm90ZWN0aW5nIGthc2xyX2VuYWJsZWQgZnJvbSBjYXVzaW5nIGEN
CmxpbmtlciBlcnJvci4gSXQgZ2V0cyBjb25zdGFudCBldmFsdWF0ZWQgdG8gMCBhbmQgdGhlIGNv
bXBpbGVyIG9wdGltaXplcyBvdXQgdGhlDQprYXNscl9lbmFibGVkIGNhbGwuIFRob3VnaHQgaXQg
d2FzIGJldHRlciB0byBndWFyZCB3aXRoIENPTkZJR19SQU5ET01JWkVfQkFTRQ0KdGhhbiB3aXRo
IENPTkZJR19VTSwgdG8gdHJ5IHRvIGNhdGNoIHRoZSBicm9hZGVyIHNpdHVhdGlvbi4gSSBndWVz
cyBJIGNvdWxkIG1vdmUNCml0IHRvIGEgaGVscGVyIGluc2lkZSBpZmRlZnMgaW5zdGVhZC4gV2Fz
IHRyeWluZyB0byBrZWVwIHRoZSBpZmRlZi1lZCBjb2RlIGRvd24uDQoNCj4gSSB3b25kZXIgaWYg
dGhlcmUgaXMgYSBiZXR0ZXIgd2F5IHRvIGFycmFuZ2UgdGhpcyBjb2RlIHRoYXQgdXNlcyBmZXdl
cg0KPiBpZmRlZnMsIGV0Yy4gTWF5YmUgYSBzaW5nbGUgQ09ORklHIHRoYXQgY2FwdHVyZSB3aGV0
aGVyIG9yIG5vdA0KPiBmaW5lLWdyYWluZWQgbW9kdWxlIHJhbmRvbWl6YXRpb24gaXMgYnVpbHQg
aW4sIGxpa2U6DQo+IA0KPiBjb25maWcgUkFORE9NSVpFX0ZJTkVfTU9EVUxFDQo+IMKgwqDCoMKg
ZGVmX2Jvb2wgeSBpZiBSQU5ET01JWkVfQkFTRSAmJiBYODZfNjQNCj4gDQo+ICNpZmRlZiBDT05G
SUdfUkFORE9NSVpFX0ZJTkVfTU9EVUxFDQo+IC4uLg0KPiAjZW5kaWYNCj4gDQo+IEJ1dCB0aGF0
IGRvZXNuJ3QgY2FwdHVyZSB0aGUgREVCVUdfRlMgYW5kIFBST0NfRlMgYml0cyAuLi4gc28gLi4u
DQo+IG1heWJlIG5vdCB3b3J0aCBpdC4gSSBndWVzcywgZWl0aGVyIHdheToNCkhtbW0sIGRpZG4n
dCBrbm93IGFib3V0IHRoYXQuIFdvdWxkIGNsZWFuIGl0IHVwIHNvbWUgYXQgbGVhc3QuDQoNCkkg
d2lzaCB0aGUgZGVidWdmcyBpbmZvIGNvdWxkIGJlIGluIG1vZHVsZS5jIHRvIGhlbHAgd2l0aCB0
aGlzIElGREVGcywgYnV0IGl0DQpuZWVkcyB2bWFsbG9jIGludGVybmFscy4gTU9EVUxFU19WQURE
UiBpcyBub3Qgc3RhbmRhcmRpemVkIGFjcm9zcyB0aGUgQVJDSCdzIGFzDQp3ZWxsLCBzbyB0aGlz
IHdhcyBteSBiZXN0IGF0dGVtcHQgdG8gaW1wbGVtZW50IHRoaXMgd2l0aG91dCBoYXZpbmcgdG8g
bWFrZQ0KY2hhbmdlcyBpbiBvdGhlciBhcmNoaXRlY3R1cmVzLg0KPiBSZXZpZXdlZC1ieTogS2Vl
cyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+DQo+IA0KPiAtS2Vlcw0KPiA=
