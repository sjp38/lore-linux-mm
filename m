Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D61508E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 16:48:18 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so2167666pls.21
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 13:48:18 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g10si2267693plq.371.2018.12.13.13.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 13:48:17 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v2 2/4] modules: Add new special vfree flags
Date: Thu, 13 Dec 2018 21:48:15 +0000
Message-ID: <427fee623f38d08cf66d070c37ce5a69a8fc2811.camel@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
	 <20181212000354.31955-3-rick.p.edgecombe@intel.com>
	 <3AD9DBCA-C6EC-4FA6-84DC-09F3D4A9C47B@vmware.com>
	 <ae9292380803f891a2472ebec70361b7c1af48d8.camel@intel.com>
	 <60C7B565-9009-4070-A632-8C982B692806@vmware.com>
In-Reply-To: <60C7B565-9009-4070-A632-8C982B692806@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <EDE0299C348546439A160617DA4E66F1@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "namit@vmware.com" <namit@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVGh1LCAyMDE4LTEyLTEzIGF0IDE5OjI3ICswMDAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPiA+
IE9uIERlYyAxMywgMjAxOCwgYXQgMTE6MDIgQU0sIEVkZ2Vjb21iZSwgUmljayBQIDxyaWNrLnAu
ZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBPbiBXZWQsIDIwMTgt
MTItMTIgYXQgMjM6NDAgKzAwMDAsIE5hZGF2IEFtaXQgd3JvdGU6DQo+ID4gPiA+IE9uIERlYyAx
MSwgMjAxOCwgYXQgNDowMyBQTSwgUmljayBFZGdlY29tYmUgPHJpY2sucC5lZGdlY29tYmVAaW50
ZWwuY29tPg0KPiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IEFkZCBuZXcgZmxhZ3Mg
Zm9yIGhhbmRsaW5nIGZyZWVpbmcgb2Ygc3BlY2lhbCBwZXJtaXNzaW9uZWQgbWVtb3J5IGluDQo+
ID4gPiA+IHZtYWxsb2MsDQo+ID4gPiA+IGFuZCByZW1vdmUgcGxhY2VzIHdoZXJlIHRoZSBoYW5k
bGluZyB3YXMgZG9uZSBpbiBtb2R1bGUuYy4NCj4gPiA+ID4gDQo+ID4gPiA+IFRoaXMgd2lsbCBl
bmFibGUgdGhpcyBmbGFnIGZvciBhbGwgYXJjaGl0ZWN0dXJlcy4NCj4gPiA+ID4gDQo+ID4gPiA+
IFNpZ25lZC1vZmYtYnk6IFJpY2sgRWRnZWNvbWJlIDxyaWNrLnAuZWRnZWNvbWJlQGludGVsLmNv
bT4NCj4gPiA+ID4gLS0tDQo+ID4gPiA+IGtlcm5lbC9tb2R1bGUuYyB8IDQzICsrKysrKysrKysr
Ky0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gPiA+ID4gMSBmaWxlIGNoYW5nZWQs
IDEyIGluc2VydGlvbnMoKyksIDMxIGRlbGV0aW9ucygtKQ0KPiA+ID4gDQo+ID4gPiBJIGNvdW50
IG9uIHlvdSBmb3IgbWVyZ2luZyB5b3VyIHBhdGNoLXNldCB3aXRoIG1pbmUsIHNpbmNlIGNsZWFy
bHkgdGhleQ0KPiA+ID4gY29uZmxpY3QuDQo+ID4gDQo+ID4gWWVzLCBJIGNhbiByZWJhc2Ugb24g
dG9wIG9mIHlvdXJzIGlmIHlvdSBvbWl0IHRoZSBjaGFuZ2VzIGFyb3VuZA0KPiA+IG1vZHVsZV9t
ZW1mcmVlIA0KPiA+IGZvciB5b3VyIG5leHQgdmVyc2lvbi4gSXQgc2hvdWxkIGZpdCB0b2dldGhl
ciBwcmV0dHkgY2xlYW5seSBmb3IgQlBGIGFuZA0KPiA+IG1vZHVsZXMNCj4gPiBJIHRoaW5rLiBO
b3Qgc3VyZSB3aGF0IHlvdSBhcmUgcGxhbm5pbmcgZm9yIGtwcm9iZXMgYW5kIGZ0cmFjZS4NCj4g
DQo+IEFyZSB5b3UgYXNraW5nIGFmdGVyIGxvb2tpbmcgYXQgdGhlIGxhdGVzdCB2ZXJzaW9uIG9m
IG15IHBhdGNoLXNldD8NCj4gDQo+IEtwcm9iZXMgaXMgZG9uZSBhbmQgYWNrJ2QuIGZ0cmFjZSBu
ZWVkcyB0byBiZSBicm9rZW4gaW50byB0d28gc2VwYXJhdGUNCj4gY2hhbmdlcyAoc2V0dGluZyB4
IGFmdGVyIHdyaXRpbmcsIGFuZCB1c2luZyB0ZXh0X3Bva2UgaW50ZXJmYWNlcyksIHVubGVzcw0K
PiBTdGV2ZW4gYWNr4oCZcyB0aGVtLiBUaGUgY2hhbmdlcyBpbnRyb2R1Y2Ugc29tZSBvdmVyaGVh
ZCAoM3gpLCBidXQgSSB0aGluayBpdA0KPiBpcyBhIHJlYXNvbmFibGUgc2xvd2Rvd24gZm9yIGEg
ZGVidWcgZmVhdHVyZS4NCj4gDQo+IENhbiB5b3UgaGF2ZSBhIGxvb2sgYXQgdGhlIHNlcmllcyBJ
4oCZdmUgc2VudCBhbmQgbGV0IG1lIGtub3cgd2hpY2ggcGF0Y2hlcw0KPiB0byBkcm9wPyBJdCB3
b3VsZCBiZSBiZXN0IChmb3IgbWUpIGlmIHRoZSB0d28gc2VyaWVzIGFyZSBmdWxseSBtZXJnZWQu
DQoNCkxvb2tpbmcgYXQgdjcsIHRoZSBvbmx5IGV4dHJhIHRoaW5nIGNvdWxkIGJlIHRoZSB0d2Vh
a3MgdG8gdGhlIGV4aXN0aW5nIGxpbmVzIGluDQprcHJvYmVzIGZyZWVfaW5zbl9wYWdlIGJlIG9t
aXR0ZWQsIHNpbmNlIHRob3NlIGxpbmVzIHdvdWxkIGp1c3QgYmUgcmVtb3ZlZCBpbiBteQ0KbGF0
ZXIgY2hhbmdlcy4NCg==
