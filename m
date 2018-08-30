Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 466D26B52B8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:25:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so5445466pgp.6
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:25:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e189-v6si7685078pfe.206.2018.08.30.11.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 11:25:09 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v4 0/3] KASLR feature to randomize each loadable module
Date: Thu, 30 Aug 2018 18:24:28 +0000
Message-ID: <1535653498.1689.175.camel@intel.com>
References: <1535583579-6138-1-git-send-email-rick.p.edgecombe@intel.com>
	 <20180830022703.xxl5eolthinicgwp@ast-mbp>
In-Reply-To: <20180830022703.xxl5eolthinicgwp@ast-mbp>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <428C3DEADE9E50409548C98A6FE035EE@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jannh@google.com" <jannh@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

T24gV2VkLCAyMDE4LTA4LTI5IGF0IDE5OjI3IC0wNzAwLCBBbGV4ZWkgU3Rhcm92b2l0b3Ygd3Jv
dGU6DQo+IE9uIFdlZCwgQXVnIDI5LCAyMDE4IGF0IDAzOjU5OjM2UE0gLTA3MDAsIFJpY2sgRWRn
ZWNvbWJlIHdyb3RlOg0KPiA+IENoYW5nZXMgZm9yIFYzOg0KPiA+IMKgLSBDb2RlIGNsZWFudXAg
YmFzZWQgb24gaW50ZXJuYWwgZmVlZGJhY2suICh0aGFua3MgdG8gRGF2ZSBIYW5zZW4gYW5kDQo+
ID4gQW5kcml5DQo+ID4gwqDCoMKgU2hldmNoZW5rbykNCj4gPiDCoC0gU2xpZ2h0IHJlZmFjdG9y
IG9mIGV4aXN0aW5nIGFsZ29yaXRobSB0byBtb3JlIGNsZWFubHkgbGl2ZSBhbG9uZyBzaWRlIG5l
dw0KPiA+IMKgwqDCoG9uZS4NCj4gPiDCoC0gQlBGIHN5bnRoZXRpYyBiZW5jaG1hcmsNCj4gSSBk
b24ndCBzZWUgdGhpcyBiZW5jaG1hcmsgaW4gdGhpcyBwYXRjaCBzZXQuDQo+IENvdWxkIHlvdSBw
cmVwYXJlIGl0IGFzIGEgdGVzdCBpbiB0b29scy90ZXN0aW5nL3NlbGZ0ZXN0cy9icGYvID8NCj4g
c28gd2UgY2FuIGRvdWJsZSBjaGVjayB3aGF0IGlzIGJlaW5nIHRlc3RlZCBhbmQgcnVuIGl0IHJl
Z3VsYXJseQ0KPiBsaWtlIHdlIGRvIGZvciBhbGwgb3RoZXIgdGVzdHMgaW4gdGhlcmUuDQpTdXJl
Lg0KDQpUaGVyZSB3ZXJlIHR3byBiZW5jaG1hcmtzIEkgaGFkIHJ1biB3aXRoIEJQRiBpbiBtaW5k
LCBvbmUgd2FzIHRoZSB0aW1pbmcgdGhlDQptb2R1bGVfYWxsb2MgZnVuY3Rpb24gaW4gZGlmZmVy
ZW50IHNjZW5hcmlvcywgbG9va2luZyB0byBtYWtlIHN1cmUgdGhlcmUgd2VyZSBubw0Kc2xvd2Rv
d25zIGZvciBpbnNlcnRpb25zLg0KDQpUaGUgb3RoZXIgd2FzIHRvIGNoZWNrIGlmIHRoZSBmcmFn
bWVudGF0aW9uIGNhdXNlZCBhbnkgbWVhc3VyYWJsZSBydW50aW1lDQpwZXJmb3JtYW5jZToNCiJG
b3IgcnVudGltZSBwZXJmb3JtYW5jZSwgYSBzeW50aGV0aWMgYmVuY2htYXJrIHdhcyBydW4gdGhh
dCBkb2VzIDUwMDAwMDAgQlBGDQpKSVQgaW52b2NhdGlvbnMgZWFjaCwgZnJvbSB2YXJ5aW5nIG51
bWJlcnMgb2YgcGFyYWxsZWwgcHJvY2Vzc2VzLCB3aGlsZSB0aGUNCmtlcm5lbCBjb21waWxlcyBz
aGFyaW5nIHRoZSBzYW1lIENQVSB0byBzdGFuZCBpbiBmb3IgdGhlIGNhY2hlIGltcGFjdCBvZiBh
IHJlYWwNCndvcmtsb2FkLiBUaGUgc2VjY29tcCBmaWx0ZXIgaW52b2NhdGlvbnMgd2VyZSBqdXN0
IEphbm4gSG9ybidzIHNlY2NvbXAgZmlsdGVyaW5nDQp0ZXN0IGZyb20gdGhpcyB0aHJlYWQgaHR0
cDovL29wZW53YWxsLmNvbS9saXN0cy9rZXJuZWwtaGFyZGVuaW5nLzIwMTgvMDcvMTgvMiwNCmV4
Y2VwdCBub24tcmVhbCB0aW1lIHByaW9yaXR5LiBUaGUga2VybmVsIHdhcyBjb25maWd1cmVkIHdp
dGggS1BUSSBhbmQNCnJldHBvbGluZSwgYW5kIHBjaWQgd2FzIGRpc2FibGVkLiBUaGVyZSB3YXNu
J3QgYW55IHNpZ25pZmljYW50IGRpZmZlcmVuY2UNCmJldHdlZW4gdGhlIG5ldyBhbmQgdGhlIG9s
ZC4iDQoNCkZyb20gd2hhdCBJIGtub3cgYWJvdXQgdGhlIGJwZiBrc2VsZnRlc3QsIHRoZSBmaXJz
dCBvbmUgd291bGQgcHJvYmFibHkgYmUgYQ0KYmV0dGVyIGZpdC4gTm90IHN1cmUgaWYgdGhlIHNl
Y29uZCBvbmUgd291bGQgZml0LCB3aXRoIHRoZSBrZXJuZWwgY29tcGlsaW5nDQpzaGFyaW5nIHRo
ZSBzYW1lIENQVSwgYSBzcGVjaWFsIGNvbmZpZywgYW5kIGEgaHVnZSBhbW91bnQgb2YgcHJvY2Vz
c2VzIGJlaW5nDQpzcGF3bmVkLi4uIEkgY2FuIHRyeSB0byBhZGQgYSBtaWNyby1iZW5jaG1hcmsg
aW5zdGVhZCBpZiB0aGF0IHNvdW5kcyBnb29kLg0KDQpSaWNr
