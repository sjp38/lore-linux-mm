Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2686D6B0003
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 19:34:46 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id n11so8630513plp.13
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 16:34:46 -0800 (PST)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id c2-v6si8160814plb.439.2018.02.20.16.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 16:34:44 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [RFC patch] ioremap: don't set up huge I/O mappings when
 p4d/pud/pmd is zero
Date: Wed, 21 Feb 2018 00:34:40 +0000
Message-ID: <1519175992.16384.121.camel@hpe.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
	 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
In-Reply-To: <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <6A2CE272CB23C041A9BC657DD90D9DD9@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>
Cc: "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "Hocko, Michal" <mhocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

T24gVHVlLCAyMDE4LTAyLTIwIGF0IDE0OjU0ICswNTMwLCBDaGludGFuIFBhbmR5YSB3cm90ZToN
Cj4gDQo+IE9uIDEyLzI4LzIwMTcgNDo1NCBQTSwgSGFuanVuIEd1byB3cm90ZToNCj4gPiBGcm9t
OiBIYW5qdW4gR3VvIDxoYW5qdW4uZ3VvQGxpbmFyby5vcmc+DQo+ID4gDQo+ID4gV2hlbiB3ZSB1
c2luZyBpb3VubWFwKCkgdG8gZnJlZSB0aGUgNEsgbWFwcGluZywgaXQganVzdCBjbGVhciB0aGUg
UFRFcw0KPiA+IGJ1dCBsZWF2ZSBQNEQvUFVEL1BNRCB1bmNoYW5nZWQsIGFsc28gd2lsbCBub3Qg
ZnJlZSB0aGUgbWVtb3J5IG9mIHBhZ2UNCj4gPiB0YWJsZXMuDQo+ID4gDQo+ID4gVGhpcyB3aWxs
IGNhdXNlIGlzc3VlcyBvbiBBUk02NCBwbGF0Zm9ybSAobm90IHN1cmUgaWYgb3RoZXIgYXJjaHMg
aGF2ZQ0KPiA+IHRoZSBzYW1lIGlzc3VlKSBmb3IgdGhpcyBjYXNlOg0KPiA+IA0KPiA+IDEuIGlv
cmVtYXAgYSA0SyBzaXplLCB2YWxpZCBwYWdlIHRhYmxlIHdpbGwgYnVpbGQsDQo+ID4gMi4gaW91
bm1hcCBpdCwgcHRlMCB3aWxsIHNldCB0byAwOw0KPiA+IDMuIGlvcmVtYXAgdGhlIHNhbWUgYWRk
cmVzcyB3aXRoIDJNIHNpemUsIHBnZC9wbWQgaXMgdW5jaGFuZ2VkLA0KPiA+ICAgICB0aGVuIHNl
dCB0aGUgYSBuZXcgdmFsdWUgZm9yIHBtZDsNCj4gPiA0LiBwdGUwIGlzIGxlYWtlZDsNCj4gPiA1
LiBDUFUgbWF5IG1lZXQgZXhjZXB0aW9uIGJlY2F1c2UgdGhlIG9sZCBwbWQgaXMgc3RpbGwgaW4g
VExCLA0KPiA+ICAgICB3aGljaCB3aWxsIGxlYWQgdG8ga2VybmVsIHBhbmljLg0KPiA+IA0KPiA+
IEZpeCBpdCBieSBza2lwIHNldHRpbmcgdXAgdGhlIGh1Z2UgSS9PIG1hcHBpbmdzIHdoZW4gcDRk
L3B1ZC9wbWQgaXMNCj4gPiB6ZXJvLg0KPiA+IA0KPiANCj4gT25lIG9idmlvdXMgcHJvYmxlbSBJ
IHNlZSBoZXJlIGlzLCBvbmNlIGFueSAybmQgbGV2ZWwgZW50cnkgaGFzIDNyZCANCj4gbGV2ZWwg
bWFwcGluZywgdGhpcyBlbnRyeSBjYW4ndCBtYXAgMk0gc2VjdGlvbiBldmVyIGluIGZ1dHVyZS4g
VGhpcyB3YXksIA0KPiB3ZSB3aWxsIGZyYWdtZW50IGVudGlyZSB2aXJ0dWFsIHNwYWNlIG92ZXIg
dGltZS4NCj4gDQo+IFRoZSBjb2RlIHlvdSBhcmUgY2hhbmdpbmcgaXMgY29tbW9uIGJldHdlZW4g
MzItYml0IHN5c3RlbXMgYXMgd2VsbCAoSSANCj4gdGhpbmspLiBBbmQgcnVubmluZyBvdXQgb2Yg
c2VjdGlvbiBtYXBwaW5nIHdvdWxkIGJlIGEgcmVhbGl0eSBpbiANCj4gcHJhY3RpY2FsIHRlcm1z
Lg0KPiANCj4gU28sIGlmIHdlIGNhbiBkbyB0aGUgZm9sbG93aW5nIGFzIGEgZml4IHVwLCB3ZSB3
b3VsZCBiZSBzYXZlZC4NCj4gMSkgSW52YWxpZGF0ZSAybmQgbGV2ZWwgZW50cnkgZnJvbSBUTEIs
IGFuZA0KPiAyKSBGcmVlIHRoZSBwYWdlIHdoaWNoIGhvbGRzIGxhc3QgbGV2ZWwgcGFnZSB0YWJs
ZQ0KPiANCj4gQlRXLCBpcyB0aGVyZSBhbnkgZnVydGhlciBkaXNjdXNzaW9uIGdvaW5nIG9uIHRo
aXMgdG9waWMgd2hpY2ggSSBhbSANCj4gbWlzc2luZyA/DQoNClllcywgSSBzdWdnZXN0ZWQgdG8g
ZnJlZSB1cCBhIHB0ZSB0YWJsZSBpbiBteSBsYXN0IHJlcGx5Lg0KaHR0cHM6Ly9wYXRjaHdvcmsu
a2VybmVsLm9yZy9wYXRjaC8xMDEzNDU4MS8NCg0KVGhhbmtzLA0KLVRvc2hpDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
