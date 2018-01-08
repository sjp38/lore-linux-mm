Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 537626B0033
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 18:37:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 3so8808316pfo.1
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 15:37:04 -0800 (PST)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id w9si9226246plp.93.2018.01.08.15.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 15:37:02 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [RFC patch] ioremap: don't set up huge I/O mappings when
 p4d/pud/pmd is zero
Date: Mon, 8 Jan 2018 23:36:57 +0000
Message-ID: <1515457376.2108.34.camel@hpe.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
	 <1515193319.2108.24.camel@hpe.com>
	 <e0fa1b52-86f5-687e-46b3-78ddd03565d8@huawei.com>
In-Reply-To: <e0fa1b52-86f5-687e-46b3-78ddd03565d8@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5045DAF5E92F124BAE65985B33006A58@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>
Cc: "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

T24gU2F0LCAyMDE4LTAxLTA2IGF0IDE3OjQ2ICswODAwLCBIYW5qdW4gR3VvIHdyb3RlOg0KPiBP
biAyMDE4LzEvNiA2OjE1LCBLYW5pLCBUb3NoaSB3cm90ZToNCj4gPiBPbiBUaHUsIDIwMTctMTIt
MjggYXQgMTk6MjQgKzA4MDAsIEhhbmp1biBHdW8gd3JvdGU6DQo+ID4gPiBGcm9tOiBIYW5qdW4g
R3VvIDxoYW5qdW4uZ3VvQGxpbmFyby5vcmc+DQo+ID4gPiANCj4gPiA+IFdoZW4gd2UgdXNpbmcg
aW91bm1hcCgpIHRvIGZyZWUgdGhlIDRLIG1hcHBpbmcsIGl0IGp1c3QgY2xlYXIgdGhlIFBURXMN
Cj4gPiA+IGJ1dCBsZWF2ZSBQNEQvUFVEL1BNRCB1bmNoYW5nZWQsIGFsc28gd2lsbCBub3QgZnJl
ZSB0aGUgbWVtb3J5IG9mIHBhZ2UNCj4gPiA+IHRhYmxlcy4NCj4gPiA+IA0KPiA+ID4gVGhpcyB3
aWxsIGNhdXNlIGlzc3VlcyBvbiBBUk02NCBwbGF0Zm9ybSAobm90IHN1cmUgaWYgb3RoZXIgYXJj
aHMgaGF2ZQ0KPiA+ID4gdGhlIHNhbWUgaXNzdWUpIGZvciB0aGlzIGNhc2U6DQo+ID4gPiANCj4g
PiA+IDEuIGlvcmVtYXAgYSA0SyBzaXplLCB2YWxpZCBwYWdlIHRhYmxlIHdpbGwgYnVpbGQsDQo+
ID4gPiAyLiBpb3VubWFwIGl0LCBwdGUwIHdpbGwgc2V0IHRvIDA7DQo+ID4gPiAzLiBpb3JlbWFw
IHRoZSBzYW1lIGFkZHJlc3Mgd2l0aCAyTSBzaXplLCBwZ2QvcG1kIGlzIHVuY2hhbmdlZCwNCj4g
PiA+ICAgIHRoZW4gc2V0IHRoZSBhIG5ldyB2YWx1ZSBmb3IgcG1kOw0KPiA+ID4gNC4gcHRlMCBp
cyBsZWFrZWQ7DQo+ID4gPiA1LiBDUFUgbWF5IG1lZXQgZXhjZXB0aW9uIGJlY2F1c2UgdGhlIG9s
ZCBwbWQgaXMgc3RpbGwgaW4gVExCLA0KPiA+ID4gICAgd2hpY2ggd2lsbCBsZWFkIHRvIGtlcm5l
bCBwYW5pYy4NCj4gPiA+IA0KPiA+ID4gRml4IGl0IGJ5IHNraXAgc2V0dGluZyB1cCB0aGUgaHVn
ZSBJL08gbWFwcGluZ3Mgd2hlbiBwNGQvcHVkL3BtZCBpcw0KPiA+ID4gemVyby4NCj4gPiANCj4g
PiBIaSBIYW5qdW4sDQo+ID4gDQo+ID4gSSB0ZXN0ZWQgdGhlIGFib3ZlIHN0ZXBzIG9uIG15IHg4
NiBib3gsIGJ1dCB3YXMgbm90IGFibGUgdG8gcmVwcm9kdWNlDQo+ID4geW91ciBrZXJuZWwgcGFu
aWMuICBPbiB4ODYsIGEgNEsgdmFkZHIgZ2V0cyBhbGxvY2F0ZWQgZnJvbSBhIHNtYWxsDQo+ID4g
ZnJhZ21lbnRlZCBmcmVlIHJhbmdlLCB3aGVyZWFzIGEgMk1CIHZhZGRyIGlzIGZyb20gYSBsYXJn
ZXIgZnJlZSByYW5nZS4gDQo+ID4gVGhlaXIgYWRkcnMgaGF2ZSBkaWZmZXJlbnQgYWxpZ25tZW50
cyAoNEtCICYgMk1CKSBhcyB3ZWxsLiAgU28sIHRoZQ0KPiA+IHN0ZXBzIGRpZCBub3QgbGVhZCB0
byB1c2UgYSBzYW1lIHBtZCBlbnRyeS4NCj4gDQo+IFRoYW5rcyBmb3IgdGhlIHRlc3RpbmcsIEkg
Y2FuIG9ubHkgcmVwcm9kdWNlIHRoaXMgb24gbXkgQVJNNjQgcGxhdGZvcm0NCj4gd2hpY2ggdGhl
IENQVSB3aWxsIGNhY2hlIHRoZSBQTUQgaW4gVExCLCBmcm9tIG15IGtub3dsZWRnZSwgb25seSBD
b3J0ZXgtQTc1DQo+IHdpbGwgZG8gdGhpcywgc28gQVJNNjQgcGxhdGZvcm1zIHdoaWNoIGFyZSBu
b3QgQTc1IGJhc2VkIGNhbid0IGJlIHJlcHJvZHVjZWQNCj4gZWl0aGVyLg0KPiANCj4gQ2F0YWxp
biwgV2lsbCwgSSBjYW4gcmVwcm9kdWNlIHRoaXMgaXNzdWUgaW4gYWJvdXQgMyBtaW51dGVzIHdp
dGggZm9sbG93aW5nDQo+IHNpbXBsaWZpZWQgdGVzdCBjYXNlIFsxXSwgYW5kIGNhbiB0cmlnZ2Vy
IHBhbmljIGFzIFsyXSwgY291bGQgeW91IHRha2UgYSBsb29rDQo+IGFzIHdlbGw/DQoNClllcywg
dGhlIHRlc3QgY2FzZSBsb29rcyBnb29kIHRvIG1lLiAobml0IC0gaXQgc2hvdWxkIGNoZWNrIGlm
IHZpcl9hZGRyDQppcyBub3QgTlVMTC4pDQoNCj4gPiBIb3dldmVyLCBJIGFncmVlIHRoYXQgemVy
bydkIHB0ZSBlbnRyaWVzIHdpbGwgYmUgbGVha2VkIHdoZW4gYSBwbWQgbWFwDQo+ID4gaXMgc2V0
IGlmIHRoZXkgYXJlIHByZXNlbnQgdW5kZXIgdGhlIHBtZC4NCj4gDQo+IFRoYW5rcyBmb3IgdGhl
IGNvbmZpcm0uDQo+IA0KPiA+IA0KPiA+IEkgYWxzbyB0ZXN0ZWQgeW91ciBwYXRjaCBvbiBteSB4
ODYgYm94LiAgVW5mb3J0dW5hdGVseSwgaXQgZWZmZWN0aXZlbHkNCj4gPiBkaXNhYmxlZCAyTUIg
bWFwcGluZ3MuICBXaGlsZSBhIDJNQiB2YWRkciBnZXRzIGFsbG9jYXRlZCBmcm9tIGEgbGFyZ2Vy
DQo+ID4gZnJlZSByYW5nZSwgaXQgc2lsbCBjb21lcyBmcm9tIGEgZnJlZSByYW5nZSBjb3ZlcmVk
IGJ5IHplcm8nZCBwdGUNCj4gPiBlbnRyaWVzLiAgU28sIGl0IGVuZHMgdXAgd2l0aCA0S0IgbWFw
cGluZ3Mgd2l0aCB5b3VyIGNoYW5nZXMuDQo+ID4gDQo+ID4gSSB0aGluayB3ZSBuZWVkIHRvIGNv
bWUgdXAgd2l0aCBvdGhlciBhcHByb2FjaC4NCj4gDQo+IFllcywgQXMgSSBzYWlkIGluIG15IHBh
dGNoLCB0aGlzIGlzIGp1c3QgUkZDLCBjb21tZW50cyBhcmUgd2VsY29tZWQgOikNCg0KSSBhbSB3
b25kZXJpbmcgaWYgd2UgY2FuIGZvbGxvdyB0aGUgc2FtZSBhcHByb2FjaCBpbg0KYXJjaC94ODYv
bW0vcGFnZWF0dHIuYy4gIExpa2UgdGhlIGlvcmVtYXAgY2FzZSwgcG9wdWxhdGVfcG1kKCkgZG9l
cyBub3QNCmNoZWNrIGlmIHRoZXJlIGlzIGEgcHRlIHRhYmxlIHVuZGVyIHRoZSBwbWQuICBCdXQg
aXRzIGZyZWUgZnVuY3Rpb24sDQp1bm1hcF9wdGVfcmFuZ2UoKSBjYWxscyB0cnlfdG9fZnJlZV9w
dGVfcGFnZSgpIHNvIHRoYXQgYSBwdGUgdGFibGUgaXMNCmZyZWVkIHdoZW4gYWxsIHB0ZSBlbnRy
aWVzIGFyZSB6ZXJvJ2QuICBJdCB0aGVuIGNhbGxzIHBtZF9jbGVhcigpLg0KaW91bm1hcCgpJ3Mg
ZnJlZSBmdW5jdGlvbiwgdnVubWFwX3B0ZV9yYW5nZSgpIGRvZXMgbm90IGZyZWUgdXAgYSBwdGUN
CnRhYmxlIGV2ZW4gaWYgYWxsIHB0ZSBlbnRyaWVzIGFyZSB6ZXJvJ2QuDQoNClRoYW5rcywNCi1U
b3NoaQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
