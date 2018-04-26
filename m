Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C48486B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:21:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c85so19108663pfb.12
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:21:27 -0700 (PDT)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id n28si8066278pfh.210.2018.04.26.09.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 09:21:26 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Thu, 26 Apr 2018 16:21:19 +0000
Message-ID: <1524759629.2693.465.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <20180426141926.GN15462@8bytes.org>
In-Reply-To: <20180426141926.GN15462@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A8BF7B687565FC47954EFC81C3D22EE6@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "willy@infradead.org" <willy@infradead.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTA0LTI2IGF0IDE2OjE5ICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IEhpIFRvc2hpLCBBbmRyZXcsDQo+IA0KPiB0aGlzIHBhdGNoKC1zZXQpIGlzIGJyb2tlbiBpbiBz
ZXZlcmFsIHdheXMsIHBsZWFzZSBzZWUgYmVsb3cuDQo+IA0KPiBPbiBXZWQsIE1hciAxNCwgMjAx
OCBhdCAxMjowMTo1NVBNIC0wNjAwLCBUb3NoaSBLYW5pIHdyb3RlOg0KPiA+IEltcGxlbWVudCBw
dWRfZnJlZV9wbWRfcGFnZSgpIGFuZCBwbWRfZnJlZV9wdGVfcGFnZSgpIG9uIHg4Niwgd2hpY2gN
Cj4gPiBjbGVhciBhIGdpdmVuIHB1ZC9wbWQgZW50cnkgYW5kIGZyZWUgdXAgbG93ZXIgbGV2ZWwg
cGFnZSB0YWJsZShzKS4NCj4gPiBBZGRyZXNzIHJhbmdlIGFzc29jaWF0ZWQgd2l0aCB0aGUgcHVk
L3BtZCBlbnRyeSBtdXN0IGhhdmUgYmVlbiBwdXJnZWQNCj4gPiBieSBJTlZMUEcuDQo+IA0KPiBB
biBJTlZMUEcgYmVmb3JlIGFjdHVhbGx5IHVubWFwcGluZyB0aGUgcGFnZSBpcyB1c2VsZXNzLCBh
cyBvdGhlciBjb3Jlcw0KPiBvciBldmVuIHNwZWN1bGF0aXZlIGluc3RydWN0aW9uIGV4ZWN1dGlv
biBjYW4gYnJpbmcgdGhlIFRMQiBlbnRyeSBiYWNrDQo+IGJlZm9yZSB0aGUgY29kZSBhY3R1YWxs
eSB1bm1hcHMgdGhlIHBhZ2UuDQoNCkhpIEpvZXJnLA0KDQpBbGwgcGFnZXMgdW5kZXIgdGhlIHBt
ZCBoYWQgYmVlbiB1bm1hcHBlZCBhbmQgdGhlbiBsYXp5IFRMQiBwdXJnZWQgd2l0aA0KSU5WTFBH
IGJlZm9yZSBjb21pbmcgdG8gdGhpcyBjb2RlIHBhdGguICBTcGVjdWxhdGlvbiBpcyBub3QgYWxs
b3dlZCB0bw0KcGFnZXMgd2l0aG91dCBtYXBwaW5nLiAgDQoNCj4gPiAgaW50IHB1ZF9mcmVlX3Bt
ZF9wYWdlKHB1ZF90ICpwdWQpDQo+ID4gIHsNCj4gPiAtCXJldHVybiBwdWRfbm9uZSgqcHVkKTsN
Cj4gPiArCXBtZF90ICpwbWQ7DQo+ID4gKwlpbnQgaTsNCj4gPiArDQo+ID4gKwlpZiAocHVkX25v
bmUoKnB1ZCkpDQo+ID4gKwkJcmV0dXJuIDE7DQo+ID4gKw0KPiA+ICsJcG1kID0gKHBtZF90ICop
cHVkX3BhZ2VfdmFkZHIoKnB1ZCk7DQo+ID4gKw0KPiA+ICsJZm9yIChpID0gMDsgaSA8IFBUUlNf
UEVSX1BNRDsgaSsrKQ0KPiA+ICsJCWlmICghcG1kX2ZyZWVfcHRlX3BhZ2UoJnBtZFtpXSkpDQo+
ID4gKwkJCXJldHVybiAwOw0KPiA+ICsNCj4gPiArCXB1ZF9jbGVhcihwdWQpOw0KPiANCj4gVExC
IGZsdXNoIG5lZWRlZCBoZXJlLCBiZWZvcmUgdGhlIHBhZ2UgaXMgZnJlZWQuDQo+IA0KPiA+ICsJ
ZnJlZV9wYWdlKCh1bnNpZ25lZCBsb25nKXBtZCk7DQo+ID4gKw0KPiA+ICsJcmV0dXJuIDE7DQo+
ID4gIH0NCj4gPiAgDQo+ID4gIC8qKg0KPiA+IEBAIC03MjQsNiArNzM5LDE1IEBAIGludCBwdWRf
ZnJlZV9wbWRfcGFnZShwdWRfdCAqcHVkKQ0KPiA+ICAgKi8NCj4gPiAgaW50IHBtZF9mcmVlX3B0
ZV9wYWdlKHBtZF90ICpwbWQpDQo+ID4gIHsNCj4gPiAtCXJldHVybiBwbWRfbm9uZSgqcG1kKTsN
Cj4gPiArCXB0ZV90ICpwdGU7DQo+ID4gKw0KPiA+ICsJaWYgKHBtZF9ub25lKCpwbWQpKQ0KPiA+
ICsJCXJldHVybiAxOw0KPiA+ICsNCj4gPiArCXB0ZSA9IChwdGVfdCAqKXBtZF9wYWdlX3ZhZGRy
KCpwbWQpOw0KPiA+ICsJcG1kX2NsZWFyKHBtZCk7DQo+IA0KPiBTYW1lIGhlcmUsIFRMQiBmbHVz
aCBuZWVkZWQuDQo+IA0KPiBGdXJ0aGVyIHRoaXMgbmVlZHMgc3luY2hyb25pemF0aW9uIHdpdGgg
b3RoZXIgcGFnZS10YWJsZXMgaW4gdGhlIHN5c3RlbQ0KPiB3aGVuIHRoZSBrZXJuZWwgUE1EcyBh
cmUgbm90IHNoYXJlZCBiZXR3ZWVuIHByb2Nlc3Nlcy4gSW4geDg2LTMyIHdpdGgNCj4gUEFFIHRo
aXMgY2F1c2VzIGEgQlVHX09OKCkgYmVpbmcgdHJpZ2dlcmVkIGF0IGFyY2gveDg2L21tL2ZhdWx0
LmM6MjY4DQo+IGJlY2F1c2UgdGhlIHBhZ2UtdGFibGVzIGFyZSBub3QgY29ycmVjdGx5IHN5bmNo
cm9uaXplZC4NCg0KSSB0aGluayB0aGlzIGlzIGFuIGlzc3VlIHdpdGggcG1kIG1hcHBpbmcgc3Vw
cG9ydCBvbiB4ODYtMzItUEFFLCBub3QNCndpdGggdGhpcyBwYXRjaC4gIEkgdGhpbmsgdGhlIGNv
ZGUgbmVlZGVkIHRvIGJlIHVwZGF0ZWQgdG8gc3luYyBhdCB0aGUNCnB1ZCBsZXZlbC4NCg0KVGhh
bmtzLA0KLVRvc2hpDQo=
