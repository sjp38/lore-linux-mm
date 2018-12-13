Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 074C68E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:02:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d71so2045137pgc.1
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:02:54 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e37si2140203plb.172.2018.12.13.11.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 11:02:53 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v2 2/4] modules: Add new special vfree flags
Date: Thu, 13 Dec 2018 19:02:51 +0000
Message-ID: <ae9292380803f891a2472ebec70361b7c1af48d8.camel@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
	 <20181212000354.31955-3-rick.p.edgecombe@intel.com>
	 <3AD9DBCA-C6EC-4FA6-84DC-09F3D4A9C47B@vmware.com>
In-Reply-To: <3AD9DBCA-C6EC-4FA6-84DC-09F3D4A9C47B@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A94C43946908D040A3E03262A753F155@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "namit@vmware.com" <namit@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gV2VkLCAyMDE4LTEyLTEyIGF0IDIzOjQwICswMDAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPiA+
IE9uIERlYyAxMSwgMjAxOCwgYXQgNDowMyBQTSwgUmljayBFZGdlY29tYmUgPHJpY2sucC5lZGdl
Y29tYmVAaW50ZWwuY29tPg0KPiA+IHdyb3RlOg0KPiA+IA0KPiA+IEFkZCBuZXcgZmxhZ3MgZm9y
IGhhbmRsaW5nIGZyZWVpbmcgb2Ygc3BlY2lhbCBwZXJtaXNzaW9uZWQgbWVtb3J5IGluDQo+ID4g
dm1hbGxvYywNCj4gPiBhbmQgcmVtb3ZlIHBsYWNlcyB3aGVyZSB0aGUgaGFuZGxpbmcgd2FzIGRv
bmUgaW4gbW9kdWxlLmMuDQo+ID4gDQo+ID4gVGhpcyB3aWxsIGVuYWJsZSB0aGlzIGZsYWcgZm9y
IGFsbCBhcmNoaXRlY3R1cmVzLg0KPiA+IA0KPiA+IFNpZ25lZC1vZmYtYnk6IFJpY2sgRWRnZWNv
bWJlIDxyaWNrLnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gPiAtLS0NCj4gPiBrZXJuZWwvbW9k
dWxlLmMgfCA0MyArKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+
ID4gMSBmaWxlIGNoYW5nZWQsIDEyIGluc2VydGlvbnMoKyksIDMxIGRlbGV0aW9ucygtKQ0KPiA+
IA0KPiANCj4gSSBjb3VudCBvbiB5b3UgZm9yIG1lcmdpbmcgeW91ciBwYXRjaC1zZXQgd2l0aCBt
aW5lLCBzaW5jZSBjbGVhcmx5IHRoZXkNCj4gY29uZmxpY3QuDQo+IA0KWWVzLCBJIGNhbiByZWJh
c2Ugb24gdG9wIG9mIHlvdXJzIGlmIHlvdSBvbWl0IHRoZSBjaGFuZ2VzIGFyb3VuZCBtb2R1bGVf
bWVtZnJlZSANCmZvciB5b3VyIG5leHQgdmVyc2lvbi4gSXQgc2hvdWxkIGZpdCB0b2dldGhlciBw
cmV0dHkgY2xlYW5seSBmb3IgQlBGIGFuZCBtb2R1bGVzDQpJIHRoaW5rLiBOb3Qgc3VyZSB3aGF0
IHlvdSBhcmUgcGxhbm5pbmcgZm9yIGtwcm9iZXMgYW5kIGZ0cmFjZS4NCg==
