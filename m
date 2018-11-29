Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7F16B5116
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:14:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so764097pfj.3
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 22:14:23 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 88si1164237plb.288.2018.11.28.22.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 22:14:22 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 2/2] x86/modules: Make x86 allocs to flush when free
Date: Thu, 29 Nov 2018 06:14:20 +0000
Message-ID: <c600ff319e37c74cf2c55b06a68e5ab041e12095.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181128000754.18056-3-rick.p.edgecombe@intel.com>
	 <CALCETrU+skBS0r6WtkwwMZJvb3s2vWB-JmDeZtVWV8pOkxKojQ@mail.gmail.com>
In-Reply-To: <CALCETrU+skBS0r6WtkwwMZJvb3s2vWB-JmDeZtVWV8pOkxKojQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B63C153BF433EA41A45FE67461271450@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gV2VkLCAyMDE4LTExLTI4IGF0IDE3OjQwIC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+ID4gT24gTm92IDI3LCAyMDE4LCBhdCA0OjA3IFBNLCBSaWNrIEVkZ2Vjb21iZSA8DQo+ID4g
cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IENoYW5nZSB0aGUg
bW9kdWxlIGFsbG9jYXRpb25zIHRvIGZsdXNoIGJlZm9yZSBmcmVlaW5nIHRoZSBwYWdlcy4NCj4g
PiANCj4gPiBTaWduZWQtb2ZmLWJ5OiBSaWNrIEVkZ2Vjb21iZSA8cmljay5wLmVkZ2Vjb21iZUBp
bnRlbC5jb20+DQo+ID4gLS0tDQo+ID4gYXJjaC94ODYva2VybmVsL21vZHVsZS5jIHwgNCArKy0t
DQo+ID4gMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4g
PiANCj4gPiBkaWZmIC0tZ2l0IGEvYXJjaC94ODYva2VybmVsL21vZHVsZS5jIGIvYXJjaC94ODYv
a2VybmVsL21vZHVsZS5jDQo+ID4gaW5kZXggYjA1MmU4ODNkZDhjLi4xNjk0ZGFmMjU2YjMgMTAw
NjQ0DQo+ID4gLS0tIGEvYXJjaC94ODYva2VybmVsL21vZHVsZS5jDQo+ID4gKysrIGIvYXJjaC94
ODYva2VybmVsL21vZHVsZS5jDQo+ID4gQEAgLTg3LDggKzg3LDggQEAgdm9pZCAqbW9kdWxlX2Fs
bG9jKHVuc2lnbmVkIGxvbmcgc2l6ZSkNCj4gPiAgICBwID0gX192bWFsbG9jX25vZGVfcmFuZ2Uo
c2l6ZSwgTU9EVUxFX0FMSUdOLA0KPiA+ICAgICAgICAgICAgICAgICAgICBNT0RVTEVTX1ZBRERS
ICsgZ2V0X21vZHVsZV9sb2FkX29mZnNldCgpLA0KPiA+ICAgICAgICAgICAgICAgICAgICBNT0RV
TEVTX0VORCwgR0ZQX0tFUk5FTCwNCj4gPiAtICAgICAgICAgICAgICAgICAgICBQQUdFX0tFUk5F
TF9FWEVDLCAwLCBOVU1BX05PX05PREUsDQo+ID4gLSAgICAgICAgICAgICAgICAgICAgX19idWls
dGluX3JldHVybl9hZGRyZXNzKDApKTsNCj4gPiArICAgICAgICAgICAgICAgICAgICBQQUdFX0tF
Uk5FTF9FWEVDLCBWTV9JTU1FRElBVEVfVU5NQVAsDQo+ID4gKyAgICAgICAgICAgICAgICAgICAg
TlVNQV9OT19OT0RFLCBfX2J1aWx0aW5fcmV0dXJuX2FkZHJlc3MoMCkpOw0KPiANCj4gSG1tLiBI
b3cgYXdmdWwgaXMgdGhlIHJlc3VsdGluZyBwZXJmb3JtYW5jZSBmb3IgaGVhdnkgZUJQRg0KPiB1
c2Vycz8gIEnigJltDQo+IHdvbmRlcmluZyBpZiB0aGUgSklUIHdpbGwgbmVlZCBzb21lIGtpbmQg
b2YgY2FjaGUgdG8gcmV1c2UNCj4gYWxsb2NhdGlvbnMuDQpJIHRoaW5rIGl0IHNob3VsZCBoYXZl
IG5vIGVmZmVjdCBmb3IgeDg2IGF0IGxlYXN0LiBPbiBhbGxvY2F0aW9uIHRoZXJlDQppcyBvbmx5
IHRoZSBzZXR0aW5nIG9mIHRoZSBmbGFnLiBGb3IgZnJlZS1pbmcgdGhlcmUgaXMgb2YgY291cnNl
IGEgbmV3DQpUTEIgZmx1c2gsIGJ1dCBpdCBoYXBwZW5zIGluIHdheSB0aGF0IHNob3VsZCByZW1v
dmUgb25lIGVsc2V3aGVyZSBmb3INCkJQRi4NCg0KT24geDg2IHRvZGF5IHRoZXJlIGFyZSBhY3R1
YWxseSBhbHJlYWR5IDMgZmx1c2hlcyBmb3IgdGhlIG9wZXJhdGlvbg0KYXJvdW5kIGEgbW9kdWxl
X2FsbG9jIEpJVCBmcmVlLiBXaGF0J3MgaGFwcGVuaW5nIGlzIHRoZXJlIGFyZSB0d28NCmFsbG9j
YXRpb25zIHRoYXQgYXJlIFJPOiB0aGUgSklUIGFuZCBzb21lIGRhdGEuIFdoZW4gZnJlZWluZywg
Zmlyc3QgdGhlDQpKSVQgaXMgc2V0IFJXLCB0aGVuIHZmcmVlZC4gU28gdGhpcyBjYXVzZXMgMSBU
TEIgZmx1c2ggZnJvbSB0aGUNCnNldF9tZW1vcnlfcncsIGFuZCB0aGVyZSBpcyBub3cgYSBsYXp5
IHZtYXAgYXJlYSBmcm9tIHRoZSB2ZnJlZS4gV2hlbg0KdGhlIGRhdGEgYWxsb2NhdGlvbiBpcyBz
ZXQgdG8gUlcsIHZtX3VubWFwX2FsaWFzZXMoKSBpcyBjYWxsZWQgaW4NCnBhZ2VhdHRyLmM6Y2hh
bmdlX3BhZ2VfYXR0cl9zZXRfY2xyLCBzbyBpdCB3aWxsIGNhdXNlIGEgZmx1c2ggZnJvbQ0KY2xl
YXJpbmcgdGhlIGxhenkgYXJlYSwgdGhlbiB0aGVyZSBpcyB0aGUgdGhpcmQgZmx1c2ggYXMgcGFy
dCBvZiB0aGUNCnBlcm1pc3Npb25zIGNoYW5nZSBsaWtlIHVzdWFsLg0KDQpTaW5jZSBub3cgdGhl
IEpJVCB2ZnJlZSB3aWxsIGNhbGwgdm1fdW5tYXBfYWxpYXNlcygpLCBpdCBzaG91bGQgbm90DQp0
cmlnZ2VyIGEgVExCIGZsdXNoIGluIHRoZSBzZWNvbmQgcGVybWlzc2lvbiBjaGFuZ2UsIHNvIHJl
bWFpbiBhdCAzLg0KPiA+ICAgIGlmIChwICYmIChrYXNhbl9tb2R1bGVfYWxsb2MocCwgc2l6ZSkg
PCAwKSkgew0KPiA+ICAgICAgICB2ZnJlZShwKTsNCj4gPiAgICAgICAgcmV0dXJuIE5VTEw7DQo+
ID4gLS0NCj4gPiAyLjE3LjENCj4gPiANCg==
