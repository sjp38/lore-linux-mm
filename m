Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E53BC8E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:27:50 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id w4so1248271otj.2
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:27:50 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780082.outbound.protection.outlook.com. [40.107.78.82])
        by mx.google.com with ESMTPS id k11si1106217otl.288.2018.12.13.11.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Dec 2018 11:27:49 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 2/4] modules: Add new special vfree flags
Date: Thu, 13 Dec 2018 19:27:45 +0000
Message-ID: <60C7B565-9009-4070-A632-8C982B692806@vmware.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-3-rick.p.edgecombe@intel.com>
 <3AD9DBCA-C6EC-4FA6-84DC-09F3D4A9C47B@vmware.com>
 <ae9292380803f891a2472ebec70361b7c1af48d8.camel@intel.com>
In-Reply-To: <ae9292380803f891a2472ebec70361b7c1af48d8.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0142D38DFCE0BA4B8AA61D16F5CE4B99@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

PiBPbiBEZWMgMTMsIDIwMTgsIGF0IDExOjAyIEFNLCBFZGdlY29tYmUsIFJpY2sgUCA8cmljay5w
LmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiANCj4gT24gV2VkLCAyMDE4LTEyLTEyIGF0
IDIzOjQwICswMDAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPj4+IE9uIERlYyAxMSwgMjAxOCwgYXQg
NDowMyBQTSwgUmljayBFZGdlY29tYmUgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0KPj4+
IHdyb3RlOg0KPj4+IA0KPj4+IEFkZCBuZXcgZmxhZ3MgZm9yIGhhbmRsaW5nIGZyZWVpbmcgb2Yg
c3BlY2lhbCBwZXJtaXNzaW9uZWQgbWVtb3J5IGluDQo+Pj4gdm1hbGxvYywNCj4+PiBhbmQgcmVt
b3ZlIHBsYWNlcyB3aGVyZSB0aGUgaGFuZGxpbmcgd2FzIGRvbmUgaW4gbW9kdWxlLmMuDQo+Pj4g
DQo+Pj4gVGhpcyB3aWxsIGVuYWJsZSB0aGlzIGZsYWcgZm9yIGFsbCBhcmNoaXRlY3R1cmVzLg0K
Pj4+IA0KPj4+IFNpZ25lZC1vZmYtYnk6IFJpY2sgRWRnZWNvbWJlIDxyaWNrLnAuZWRnZWNvbWJl
QGludGVsLmNvbT4NCj4+PiAtLS0NCj4+PiBrZXJuZWwvbW9kdWxlLmMgfCA0MyArKysrKysrKysr
KystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+Pj4gMSBmaWxlIGNoYW5nZWQsIDEy
IGluc2VydGlvbnMoKyksIDMxIGRlbGV0aW9ucygtKQ0KPj4gDQo+PiBJIGNvdW50IG9uIHlvdSBm
b3IgbWVyZ2luZyB5b3VyIHBhdGNoLXNldCB3aXRoIG1pbmUsIHNpbmNlIGNsZWFybHkgdGhleQ0K
Pj4gY29uZmxpY3QuDQo+IFllcywgSSBjYW4gcmViYXNlIG9uIHRvcCBvZiB5b3VycyBpZiB5b3Ug
b21pdCB0aGUgY2hhbmdlcyBhcm91bmQgbW9kdWxlX21lbWZyZWUgDQo+IGZvciB5b3VyIG5leHQg
dmVyc2lvbi4gSXQgc2hvdWxkIGZpdCB0b2dldGhlciBwcmV0dHkgY2xlYW5seSBmb3IgQlBGIGFu
ZCBtb2R1bGVzDQo+IEkgdGhpbmsuIE5vdCBzdXJlIHdoYXQgeW91IGFyZSBwbGFubmluZyBmb3Ig
a3Byb2JlcyBhbmQgZnRyYWNlLg0KDQpBcmUgeW91IGFza2luZyBhZnRlciBsb29raW5nIGF0IHRo
ZSBsYXRlc3QgdmVyc2lvbiBvZiBteSBwYXRjaC1zZXQ/DQoNCktwcm9iZXMgaXMgZG9uZSBhbmQg
YWNrJ2QuIGZ0cmFjZSBuZWVkcyB0byBiZSBicm9rZW4gaW50byB0d28gc2VwYXJhdGUNCmNoYW5n
ZXMgKHNldHRpbmcgeCBhZnRlciB3cml0aW5nLCBhbmQgdXNpbmcgdGV4dF9wb2tlIGludGVyZmFj
ZXMpLCB1bmxlc3MNClN0ZXZlbiBhY2vigJlzIHRoZW0uIFRoZSBjaGFuZ2VzIGludHJvZHVjZSBz
b21lIG92ZXJoZWFkICgzeCksIGJ1dCBJIHRoaW5rIGl0DQppcyBhIHJlYXNvbmFibGUgc2xvd2Rv
d24gZm9yIGEgZGVidWcgZmVhdHVyZS4NCg0KQ2FuIHlvdSBoYXZlIGEgbG9vayBhdCB0aGUgc2Vy
aWVzIEnigJl2ZSBzZW50IGFuZCBsZXQgbWUga25vdyB3aGljaCBwYXRjaGVzDQp0byBkcm9wPyBJ
dCB3b3VsZCBiZSBiZXN0IChmb3IgbWUpIGlmIHRoZSB0d28gc2VyaWVzIGFyZSBmdWxseSBtZXJn
ZWQu
