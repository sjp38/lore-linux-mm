Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27E4F6B540B
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:49:30 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 68so2326367pfr.6
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:49:30 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id bi6si2848003plb.279.2018.11.29.10.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 10:49:28 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: =?utf-8?B?UmU6IFtQQVRDSCAwLzJdIERvbuKAmXQgbGVhdmUgZXhlY3V0YWJsZSBUTEIg?=
 =?utf-8?Q?entries_to_freed_pages?=
Date: Thu, 29 Nov 2018 18:49:26 +0000
Message-ID: <4cddc2ba36ba3b6d528556207b8d4592209797ea.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181129230616.f017059a093841dbaa4b82e6@kernel.org>
In-Reply-To: <20181129230616.f017059a093841dbaa4b82e6@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A76C5CD0E9CE5E488A3D2C4CFA24D87C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhiramat@kernel.org" <mhiramat@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

T24gVGh1LCAyMDE4LTExLTI5IGF0IDIzOjA2ICswOTAwLCBNYXNhbWkgSGlyYW1hdHN1IHdyb3Rl
Og0KPiBPbiBUdWUsIDI3IE5vdiAyMDE4IDE2OjA3OjUyIC0wODAwDQo+IFJpY2sgRWRnZWNvbWJl
IDxyaWNrLnAuZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+IA0KPiA+IFNvbWV0aW1lcyB3
aGVuIG1lbW9yeSBpcyBmcmVlZCB2aWEgdGhlIG1vZHVsZSBzdWJzeXN0ZW0sIGFuIGV4ZWN1dGFi
bGUNCj4gPiBwZXJtaXNzaW9uZWQgVExCIGVudHJ5IGNhbiByZW1haW4gdG8gYSBmcmVlZCBwYWdl
LiBJZiB0aGUgcGFnZSBpcyByZS11c2VkIHRvDQo+ID4gYmFjayBhbiBhZGRyZXNzIHRoYXQgd2ls
bCByZWNlaXZlIGRhdGEgZnJvbSB1c2Vyc3BhY2UsIGl0IGNhbiByZXN1bHQgaW4gdXNlcg0KPiA+
IGRhdGEgYmVpbmcgbWFwcGVkIGFzIGV4ZWN1dGFibGUgaW4gdGhlIGtlcm5lbC4gVGhlIHJvb3Qg
b2YgdGhpcyBiZWhhdmlvciBpcw0KPiA+IHZmcmVlIGxhemlseSBmbHVzaGluZyB0aGUgVExCLCBi
dXQgbm90IGxhemlseSBmcmVlaW5nIHRoZSB1bmRlcmx5aW5nIHBhZ2VzLiANCj4gDQo+IEdvb2Qg
Y2F0Y2ghDQo+IA0KPiA+IA0KPiA+IFRoZXJlIGFyZSBzb3J0IG9mIHRocmVlIGNhdGVnb3JpZXMg
b2YgdGhpcyB3aGljaCBzaG93IHVwIGFjcm9zcyBtb2R1bGVzLA0KPiA+IGJwZiwNCj4gPiBrcHJv
YmVzIGFuZCBmdHJhY2U6DQo+IA0KPiBGb3IgeDg2LTY0IGtwcm9iZSwgaXQgc2V0cyB0aGUgcGFn
ZSBOWCBhbmQgYWZ0ZXIgdGhhdCBSVywgYW5kIHRoZW4gcmVsZWFzZQ0KPiB2aWEgbW9kdWxlX21l
bWZyZWUuIFNvIEknbSBub3Qgc3VyZSBpdCByZWFsbHkgaGFwcGVucyBvbiBrcHJvYmVzLiAoT2Yg
Y291cnNlDQo+IHRoZSBkZWZhdWx0IG1lbW9yeSBhbGxvY2F0b3IgaXMgc2ltcGxlciBzbyBpdCBt
YXkgaGFwcGVuIG9uIG90aGVyIGFyY2hzKSBCdXQNCj4gaW50ZXJlc3RpbmcgZml4ZXMuDQpZZXMs
IEkgdGhpbmsgeW91IGFyZSByaWdodCwgaXQgc2hvdWxkIG5vdCBsZWF2ZSBhbiBleGVjdXRhYmxl
IFRMQiBlbnRyeSBpbiB0aGlzDQpjYXNlLiBGdHJhY2UgYWN0dWFsbHkgZG9lcyB0aGlzIG9uIHg4
NiBhcyB3ZWxsLg0KDQpJcyB0aGVyZSBzb21lIG90aGVyIHJlYXNvbiBmb3IgY2FsbGluZyBzZXRf
bWVtb3J5X254IHRoYXQgc2hvdWxkIGFwcGx5IGVsc2V3aGVyZQ0KZm9yIG1vZHVsZSB1c2Vycz8g
T3IgY291bGQgaXQgYmUgcmVtb3ZlZCBpbiB0aGUgY2FzZSBvZiB0aGlzIHBhdGNoIHRvIGNlbnRy
YWxpemUNCnRoZSBiZWhhdmlvcj8NCg0KVGhhbmtzLA0KDQpSaWNrDQoNCj4gVGhhbmsgeW91LA0K
PiANCj4gDQo+ID4gDQo+ID4gMS4gV2hlbiBleGVjdXRhYmxlIG1lbW9yeSBpcyB0b3VjaGVkIGFu
ZCB0aGVuIGltbWVkaWF0bHkgZnJlZWQNCj4gPiANCj4gPiAgICBUaGlzIHNob3dzIHVwIGluIGEg
Y291cGxlIGVycm9yIGNvbmRpdGlvbnMgaW4gdGhlIG1vZHVsZSBsb2FkZXIgYW5kIEJQRg0KPiA+
IEpJVA0KPiA+ICAgIGNvbXBpbGVyLg0KPiA+IA0KPiA+IDIuIFdoZW4gZXhlY3V0YWJsZSBtZW1v
cnkgaXMgc2V0IHRvIFJXIHJpZ2h0IGJlZm9yZSBiZWluZyBmcmVlZA0KPiA+IA0KPiA+ICAgIElu
IHRoaXMgY2FzZSAob24geDg2IGFuZCBwcm9iYWJseSBvdGhlcnMpIHRoZXJlIHdpbGwgYmUgYSBU
TEIgZmx1c2ggd2hlbg0KPiA+IGl0cw0KPiA+ICAgIHNldCB0byBSVyBhbmQgc28gc2luY2UgdGhl
IHBhZ2VzIGFyZSBub3QgdG91Y2hlZCBiZXR3ZWVuIHNldHRpbmcgdGhlDQo+ID4gICAgZmx1c2gg
YW5kIHRoZSBmcmVlLCBpdCBzaG91bGQgbm90IGJlIGluIHRoZSBUTEIgaW4gbW9zdCBjYXNlcy4g
U28gdGhpcw0KPiA+ICAgIGNhdGVnb3J5IGlzIG5vdCBhcyBiaWcgb2YgYSBjb25jZXJuLiBIb3dl
dmVyLCB0ZWNoaW5pY2FsbHkgdGhlcmUgaXMgc3RpbGwNCj4gPiBhDQo+ID4gICAgcmFjZSB3aGVy
ZSBhbiBhdHRhY2tlciBjb3VsZCB0cnkgdG8ga2VlcCBpdCBhbGl2ZSBmb3IgYSBzaG9ydCB3aW5k
b3cgd2l0aA0KPiA+IGENCj4gPiAgICB3ZWxsIHRpbWVkIG91dC1vZi1ib3VuZCByZWFkIG9yIHNw
ZWN1bGF0aXZlIHJlYWQsIHNvIGlkZWFsbHkgdGhpcyBjb3VsZA0KPiA+IGJlDQo+ID4gICAgYmxv
Y2tlZCBhcyB3ZWxsLg0KPiA+IA0KPiA+IDMuIFdoZW4gZXhlY3V0YWJsZSBtZW1vcnkgaXMgZnJl
ZWQgaW4gYW4gaW50ZXJydXB0DQo+ID4gDQo+ID4gICAgQXQgbGVhc3Qgb25lIGV4YW1wbGUgb2Yg
dGhpcyBpcyB0aGUgZnJlZWluZyBvZiBpbml0IHNlY3Rpb25zIGluIHRoZQ0KPiA+IG1vZHVsZQ0K
PiA+ICAgIGxvYWRlci4gU2luY2Ugdm1hbGxvYyByZXVzZXMgdGhlIGFsbG9jYXRpb24gZm9yIHRo
ZSB3b3JrIHF1ZXVlIGxpbmtlZA0KPiA+IGxpc3QNCj4gPiAgICBub2RlIGZvciB0aGUgZGVmZXJy
ZWQgZnJlZXMsIHRoZSBtZW1vcnkgYWN0dWFsbHkgZ2V0cyB0b3VjaGVkIGFzIHBhcnQgb2YNCj4g
PiB0aGUNCj4gPiAgICB2ZnJlZSBvcGVyYXRpb24gYW5kIHNvIHJldHVybnMgdG8gdGhlIFRMQiBl
dmVuIGFmdGVyIHRoZSBmbHVzaCBmcm9tDQo+ID4gcmVzZXR0aW5nDQo+ID4gICAgdGhlIHBlcm1p
c3Npb25zLg0KPiA+IA0KPiA+IEkgaGF2ZSBvbmx5IGFjdHVhbGx5IHRlc3RlZCBjYXRlZ29yeSAx
LCBhbmQgaWRlbnRpZmllZCAyIGFuZCAzIGp1c3QgZnJvbQ0KPiA+IHJlYWRpbmcNCj4gPiB0aGUg
Y29kZS4NCj4gPiANCj4gPiBUbyBjYXRjaCBhbGwgb2YgdGhlc2UsIG1vZHVsZV9hbGxvYyBmb3Ig
eDg2IGlzIGNoYW5nZWQgdG8gdXNlIGEgbmV3IGZsYWcNCj4gPiB0aGF0DQo+ID4gaW5zdHJ1Y3Rz
IHRoZSB1bm1hcCBvcGVyYXRpb24gdG8gZmx1c2ggdGhlIFRMQiBiZWZvcmUgZnJlZWluZyB0aGUg
cGFnZXMuDQo+ID4gDQo+ID4gSWYgdGhpcyBzb2x1dGlvbiBzZWVtcyBnb29kIEkgY2FuIHBsdWcg
dGhlIGZsYWcgaW4gZm9yIG90aGVyIGFyY2hpdGVjdHVyZXMNCj4gPiB0aGF0DQo+ID4gZGVmaW5l
IFBBR0VfS0VSTkVMX0VYRUMuDQo+ID4gDQo+ID4gDQo+ID4gUmljayBFZGdlY29tYmUgKDIpOg0K
PiA+ICAgdm1hbGxvYzogTmV3IGZsYWcgZm9yIGZsdXNoIGJlZm9yZSByZWxlYXNpbmcgcGFnZXMN
Cj4gPiAgIHg4Ni9tb2R1bGVzOiBNYWtlIHg4NiBhbGxvY3MgdG8gZmx1c2ggd2hlbiBmcmVlDQo+
ID4gDQo+ID4gIGFyY2gveDg2L2tlcm5lbC9tb2R1bGUuYyB8ICA0ICsrLS0NCj4gPiAgaW5jbHVk
ZS9saW51eC92bWFsbG9jLmggIHwgIDEgKw0KPiA+ICBtbS92bWFsbG9jLmMgICAgICAgICAgICAg
fCAxMyArKysrKysrKysrKy0tDQo+ID4gIDMgZmlsZXMgY2hhbmdlZCwgMTQgaW5zZXJ0aW9ucygr
KSwgNCBkZWxldGlvbnMoLSkNCj4gPiANCj4gPiAtLSANCj4gPiAyLjE3LjENCj4gPiANCj4gDQo+
IA0K
