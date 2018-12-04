Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 835966B7072
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:02:07 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so14777202pfb.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:02:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x23si16817893pln.100.2018.12.04.12.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:02:06 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Date: Tue, 4 Dec 2018 20:02:03 +0000
Message-ID: <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
	 <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
	 <20181204160304.GB7195@arm.com>
In-Reply-To: <20181204160304.GB7195@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A505089424EB70449A3E55198D49D917@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "Keshavamurthy, Anil S  <anil.s.keshavamurthy@intel.com>, kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVHVlLCAyMDE4LTEyLTA0IGF0IDE2OjAzICswMDAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
T24gTW9uLCBEZWMgMDMsIDIwMTggYXQgMDU6NDM6MTFQTSAtMDgwMCwgTmFkYXYgQW1pdCB3cm90
ZToNCj4gPiA+IE9uIE5vdiAyNywgMjAxOCwgYXQgNDowNyBQTSwgUmljayBFZGdlY29tYmUgPHJp
Y2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0KPiA+ID4gd3JvdGU6DQo+ID4gPiANCj4gPiA+IFNp
bmNlIHZmcmVlIHdpbGwgbGF6aWx5IGZsdXNoIHRoZSBUTEIsIGJ1dCBub3QgbGF6aWx5IGZyZWUg
dGhlIHVuZGVybHlpbmcNCj4gPiA+IHBhZ2VzLA0KPiA+ID4gaXQgb2Z0ZW4gbGVhdmVzIHN0YWxl
IFRMQiBlbnRyaWVzIHRvIGZyZWVkIHBhZ2VzIHRoYXQgY291bGQgZ2V0IHJlLXVzZWQuDQo+ID4g
PiBUaGlzIGlzDQo+ID4gPiB1bmRlc2lyYWJsZSBmb3IgY2FzZXMgd2hlcmUgdGhlIG1lbW9yeSBi
ZWluZyBmcmVlZCBoYXMgc3BlY2lhbCBwZXJtaXNzaW9ucw0KPiA+ID4gc3VjaA0KPiA+ID4gYXMg
ZXhlY3V0YWJsZS4NCj4gPiANCj4gPiBTbyBJIGFtIHRyeWluZyB0byBmaW5pc2ggbXkgcGF0Y2gt
c2V0IGZvciBwcmV2ZW50aW5nIHRyYW5zaWVudCBXK1ggbWFwcGluZ3MNCj4gPiBmcm9tIHRha2lu
ZyBzcGFjZSwgYnkgaGFuZGxpbmcga3Byb2JlcyAmIGZ0cmFjZSB0aGF0IEkgbWlzc2VkICh0aGFu
a3MgYWdhaW4NCj4gPiBmb3INCj4gPiBwb2ludGluZyBpdCBvdXQpLg0KPiA+IA0KPiA+IEJ1dCBh
bGwgb2YgdGhlIHN1ZGRlbiwgSSBkb27igJl0IHVuZGVyc3RhbmQgd2h5IHdlIGhhdmUgdGhlIHBy
b2JsZW0gdGhhdCB0aGlzDQo+ID4gKHlvdXIpIHBhdGNoLXNldCBkZWFscyB3aXRoIGF0IGFsbC4g
V2UgYWxyZWFkeSBjaGFuZ2UgdGhlIG1hcHBpbmdzIHRvIG1ha2UNCj4gPiB0aGUgbWVtb3J5IHdy
aXRhYmxlIGJlZm9yZSBmcmVlaW5nIHRoZSBtZW1vcnksIHNvIHdoeSBjYW7igJl0IHdlIG1ha2Ug
aXQNCj4gPiBub24tZXhlY3V0YWJsZSBhdCB0aGUgc2FtZSB0aW1lPyBBY3R1YWxseSwgd2h5IGRv
IHdlIG1ha2UgdGhlIG1vZHVsZSBtZW1vcnksDQo+ID4gaW5jbHVkaW5nIGl0cyBkYXRhIGV4ZWN1
dGFibGUgYmVmb3JlIGZyZWVpbmcgaXQ/Pz8NCj4gDQo+IFllYWgsIHRoaXMgaXMgcmVhbGx5IGNv
bmZ1c2luZywgYnV0IEkgaGF2ZSBhIHN1c3BpY2lvbiBpdCdzIGEgY29tYmluYXRpb24NCj4gb2Yg
dGhlIHZhcmlvdXMgZGlmZmVyZW50IGNvbmZpZ3VyYXRpb25zIGFuZCBoeXN0ZXJpY2FsIHJhaXNp
bnMuIFdlIGNhbid0DQo+IHJlbHkgb24gbW9kdWxlX2FsbG9jKCkgYWxsb2NhdGluZyBmcm9tIHRo
ZSB2bWFsbG9jIGFyZWEgKHNlZSBuaW9zMikgbm9yDQo+IGNhbiB3ZSByZWx5IG9uIGRpc2FibGVf
cm9fbngoKSBiZWluZyBhdmFpbGFibGUgYXQgYnVpbGQgdGltZS4NCj4gDQo+IElmIHdlICpjb3Vs
ZCogcmVseSBvbiBtb2R1bGUgYWxsb2NhdGlvbnMgYWx3YXlzIHVzaW5nIHZtYWxsb2MoKSwgdGhl
bg0KPiB3ZSBjb3VsZCBwYXNzIGluIFJpY2sncyBuZXcgZmxhZyBhbmQgZHJvcCBkaXNhYmxlX3Jv
X254KCkgYWx0b2dldGhlcg0KPiBhZmFpY3QgLS0gd2hvIGNhcmVzIGFib3V0IHRoZSBtZW1vcnkg
YXR0cmlidXRlcyBvZiBhIG1hcHBpbmcgdGhhdCdzIGFib3V0DQo+IHRvIGRpc2FwcGVhciBhbnl3
YXk/DQo+IA0KPiBJcyBpdCBqdXN0IG5pb3MyIHRoYXQgZG9lcyBzb21ldGhpbmcgZGlmZmVyZW50
Pw0KPiANCj4gV2lsbA0KDQpZZWEgaXQgaXMgcmVhbGx5IGludGVydHdpbmVkLiBJIHRoaW5rIGZv
ciB4ODYsIHNldF9tZW1vcnlfbnggZXZlcnl3aGVyZSB3b3VsZA0Kc29sdmUgaXQgYXMgd2VsbCwg
aW4gZmFjdCB0aGF0IHdhcyB3aGF0IEkgZmlyc3QgdGhvdWdodCB0aGUgc29sdXRpb24gc2hvdWxk
IGJlDQp1bnRpbCB0aGlzIHdhcyBzdWdnZXN0ZWQuIEl0J3MgaW50ZXJlc3RpbmcgdGhhdCBmcm9t
IHRoZSBvdGhlciB0aHJlYWQgTWFzYW1pDQpIaXJhbWF0c3UgcmVmZXJlbmNlZCwgc2V0X21lbW9y
eV9ueCB3YXMgc3VnZ2VzdGVkIGxhc3QgeWVhciBhbmQgd291bGQgaGF2ZQ0KaW5hZHZlcnRlbnRs
eSBibG9ja2VkIHRoaXMgb24geDg2LiBCdXQsIG9uIHRoZSBvdGhlciBhcmNoaXRlY3R1cmVzIEkg
aGF2ZSBzaW5jZQ0KbGVhcm5lZCBpdCBpcyBhIGJpdCBkaWZmZXJlbnQuDQoNCkl0IGxvb2tzIGxp
a2UgYWN0dWFsbHkgbW9zdCBhcmNoJ3MgZG9uJ3QgcmUtZGVmaW5lIHNldF9tZW1vcnlfKiwgYW5k
IHNvIGFsbCBvZg0KdGhlIGZyb2JfKiBmdW5jdGlvbnMgYXJlIGFjdHVhbGx5IGp1c3Qgbm9vcHMu
IEluIHdoaWNoIGNhc2UgYWxsb2NhdGluZyBSV1ggaXMNCm5lZWRlZCB0byBtYWtlIGl0IHdvcmsg
YXQgYWxsLCBiZWNhdXNlIHRoYXQgaXMgd2hhdCB0aGUgYWxsb2NhdGlvbiBpcyBnb2luZyB0bw0K
c3RheSBhdC4gU28gaW4gdGhlc2UgYXJjaHMsIHNldF9tZW1vcnlfbnggd29uJ3Qgc29sdmUgaXQg
YmVjYXVzZSBpdCB3aWxsIGRvDQpub3RoaW5nLg0KDQpPbiB4ODYgSSB0aGluayB5b3UgY2Fubm90
IGdldCByaWQgb2YgZGlzYWJsZV9yb19ueCBmdWxseSBiZWNhdXNlIHRoZXJlIGlzIHRoZQ0KY2hh
bmdpbmcgb2YgdGhlIHBlcm1pc3Npb25zIG9uIHRoZSBkaXJlY3RtYXAgYXMgd2VsbC4gWW91IGRv
bid0IHdhbnQgc29tZSBvdGhlcg0KY2FsbGVyIGdldHRpbmcgYSBwYWdlIHRoYXQgd2FzIGxlZnQg
Uk8gd2hlbiBmcmVlZCBhbmQgdGhlbiB0cnlpbmcgdG8gd3JpdGUgdG8NCml0LCBpZiBJIHVuZGVy
c3RhbmQgdGhpcy4NCg0KVGhlIG90aGVyIHJlYXNvbmluZyB3YXMgdGhhdCBjYWxsaW5nIHNldF9t
ZW1vcnlfbnggaXNuJ3QgZG9pbmcgd2hhdCB3ZSBhcmUNCmFjdHVhbGx5IHRyeWluZyB0byBkbyB3
aGljaCBpcyBwcmV2ZW50IHRoZSBwYWdlcyBmcm9tIGdldHRpbmcgcmVsZWFzZWQgdG9vDQplYXJs
eS4NCg0KQSBtb3JlIGNsZWFyIHNvbHV0aW9uIGZvciBhbGwgb2YgdGhpcyBtaWdodCBpbnZvbHZl
IHJlZmFjdG9yaW5nIHNvbWUgb2YgdGhlDQpzZXRfbWVtb3J5XyBkZS1hbGxvY2F0aW9uIGxvZ2lj
IG91dCBpbnRvIF9fd2VhayBmdW5jdGlvbnMgaW4gZWl0aGVyIG1vZHVsZXMgb3INCnZtYWxsb2Mu
IEFzIEplc3NpY2EgcG9pbnRzIG91dCBpbiB0aGUgb3RoZXIgdGhyZWFkIHRob3VnaCwgbW9kdWxl
cyBkb2VzIGEgbG90DQptb3JlIHN0dWZmIHRoZXJlIHRoYW4gdGhlIG90aGVyIG1vZHVsZV9hbGxv
YyBjYWxsZXJzLiBJIHRoaW5rIGl0IG1heSB0YWtlIHNvbWUNCnRob3VnaHQgdG8gY2VudHJhbGl6
ZSBBTkQgbWFrZSBpdCBvcHRpbWFsIGZvciBldmVyeSBtb2R1bGVfYWxsb2Mvdm1hbGxvY19leGVj
DQp1c2VyIGFuZCBhcmNoLg0KDQpCdXQgZm9yIG5vdyB3aXRoIHRoZSBjaGFuZ2UgaW4gdm1hbGxv
Yywgd2UgY2FuIGJsb2NrIHRoZSBleGVjdXRhYmxlIG1hcHBpbmcNCmZyZWVkIHBhZ2UgcmUtdXNl
IGlzc3VlIGluIGEgY3Jvc3MgcGxhdGZvcm0gd2F5Lg0KDQpUaGFua3MsDQoNClJpY2sNCg0K
