Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 783FF6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:51:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w9so3353109pfl.2
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:51:13 -0700 (PDT)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id l6-v6si4458652plk.489.2018.03.15.07.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 07:51:12 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Thu, 15 Mar 2018 14:51:06 +0000
Message-ID: <1521125462.2693.154.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <14cb9fdf-25de-6519-2200-43f585b64cdd@codeaurora.org>
In-Reply-To: <14cb9fdf-25de-6519-2200-43f585b64cdd@codeaurora.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4B31960CADFB9D478D453187E9F7B27F@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <mhocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTAzLTE1IGF0IDEzOjA5ICswNTMwLCBDaGludGFuIFBhbmR5YSB3cm90ZToN
Cj4gDQo+IE9uIDMvMTQvMjAxOCAxMTozMSBQTSwgVG9zaGkgS2FuaSB3cm90ZToNCj4gPiBJbXBs
ZW1lbnQgcHVkX2ZyZWVfcG1kX3BhZ2UoKSBhbmQgcG1kX2ZyZWVfcHRlX3BhZ2UoKSBvbiB4ODYs
IHdoaWNoDQo+ID4gY2xlYXIgYSBnaXZlbiBwdWQvcG1kIGVudHJ5IGFuZCBmcmVlIHVwIGxvd2Vy
IGxldmVsIHBhZ2UgdGFibGUocykuDQo+ID4gQWRkcmVzcyByYW5nZSBhc3NvY2lhdGVkIHdpdGgg
dGhlIHB1ZC9wbWQgZW50cnkgbXVzdCBoYXZlIGJlZW4gcHVyZ2VkDQo+ID4gYnkgSU5WTFBHLg0K
PiA+IA0KPiA+IGZpeGVzOiBlNjFjZTZhZGU0MDRlICgibW06IGNoYW5nZSBpb3JlbWFwIHRvIHNl
dCB1cCBodWdlIEkvTyBtYXBwaW5ncyIpDQo+ID4gU2lnbmVkLW9mZi1ieTogVG9zaGkgS2FuaSA8
dG9zaGkua2FuaUBocGUuY29tPg0KPiA+IENjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNv
bT4NCj4gPiBDYzogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4g
PiBDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0cm9uaXguZGU+DQo+ID4gQ2M6IEluZ28g
TW9sbmFyIDxtaW5nb0ByZWRoYXQuY29tPg0KPiA+IENjOiAiSC4gUGV0ZXIgQW52aW4iIDxocGFA
enl0b3IuY29tPg0KPiA+IENjOiBCb3Jpc2xhdiBQZXRrb3YgPGJwQHN1c2UuZGU+DQo+ID4gQ2M6
IE1hdHRoZXcgV2lsY294IDx3aWxseUBpbmZyYWRlYWQub3JnPg0KPiA+IENjOiA8c3RhYmxlQHZn
ZXIua2VybmVsLm9yZz4NCj4gPiAtLS0NCj4gPiAgIGFyY2gveDg2L21tL3BndGFibGUuYyB8ICAg
MjggKysrKysrKysrKysrKysrKysrKysrKysrKystLQ0KPiA+ICAgMSBmaWxlIGNoYW5nZWQsIDI2
IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL2Fy
Y2gveDg2L21tL3BndGFibGUuYyBiL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiA+IGluZGV4IDFl
ZWQ3ZWQ1MThlNi4uMzRjZGE3ZTA1NTFiIDEwMDY0NA0KPiA+IC0tLSBhL2FyY2gveDg2L21tL3Bn
dGFibGUuYw0KPiA+ICsrKyBiL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiA+IEBAIC03MTIsNyAr
NzEyLDIyIEBAIGludCBwbWRfY2xlYXJfaHVnZShwbWRfdCAqcG1kKQ0KPiA+ICAgICovDQo+ID4g
ICBpbnQgcHVkX2ZyZWVfcG1kX3BhZ2UocHVkX3QgKnB1ZCkNCj4gPiAgIHsNCj4gPiAtCXJldHVy
biBwdWRfbm9uZSgqcHVkKTsNCj4gPiArCXBtZF90ICpwbWQ7DQo+ID4gKwlpbnQgaTsNCj4gPiAr
DQo+ID4gKwlpZiAocHVkX25vbmUoKnB1ZCkpDQo+ID4gKwkJcmV0dXJuIDE7DQo+ID4gKw0KPiA+
ICsJcG1kID0gKHBtZF90ICopcHVkX3BhZ2VfdmFkZHIoKnB1ZCk7DQo+ID4gKw0KPiA+ICsJZm9y
IChpID0gMDsgaSA8IFBUUlNfUEVSX1BNRDsgaSsrKQ0KPiA+ICsJCWlmICghcG1kX2ZyZWVfcHRl
X3BhZ2UoJnBtZFtpXSkpDQo+IA0KPiBUaGlzIGlzIGZvcmNlZCBhY3Rpb24gYW5kIG5vIG9wdGlv
bmFsLiBBbHNvLCBwbWRfZnJlZV9wdGVfcGFnZSgpDQo+IGRvZXNuJ3QgcmV0dXJuIDAgaW4gYW55
IGNhc2UuIFNvLCB5b3UgbWF5IHJlbW92ZSBfaWZfID8NCg0KVGhlIGNvZGUgbmVlZHMgdG8gYmUg
d3JpdHRlbiBwZXIgdGhlIGludGVyZmFjZSBkZWZpbml0aW9uLCBub3QgcGVyIHRoZQ0KY3VycmVu
dCBpbXBsZW1lbnRhdGlvbi4NCg0KPiA+ICsJCQlyZXR1cm4gMDsNCj4gPiArDQo+ID4gKwlwdWRf
Y2xlYXIocHVkKTsNCj4gPiArCWZyZWVfcGFnZSgodW5zaWduZWQgbG9uZylwbWQpOw0KPiA+ICsN
Cj4gPiArCXJldHVybiAxOw0KPiA+ICAgfQ0KPiA+ICAgDQo+ID4gICAvKioNCj4gPiBAQCAtNzI0
LDYgKzczOSwxNSBAQCBpbnQgcHVkX2ZyZWVfcG1kX3BhZ2UocHVkX3QgKnB1ZCkNCj4gPiAgICAq
Lw0KPiA+ICAgaW50IHBtZF9mcmVlX3B0ZV9wYWdlKHBtZF90ICpwbWQpDQo+ID4gICB7DQo+ID4g
LQlyZXR1cm4gcG1kX25vbmUoKnBtZCk7DQo+ID4gKwlwdGVfdCAqcHRlOw0KPiA+ICsNCj4gPiAr
CWlmIChwbWRfbm9uZSgqcG1kKSkNCj4gDQo+IFRoaXMgc2hvdWxkIGFsc28gY2hlY2sgaWYgcG1k
IGlzIGFscmVhZHkgaHVnZS4gU2FtZSBmb3IgcHVkID8NCg0KTm90IG5lY2Vzc2FyeS4gQXMgZGVz
Y3JpYmVkIGluIHRoZSBmdW5jdGlvbiBoZWFkZXIsIG9uZSBvZiB0aGUgZW50cnkNCmNvbmRpdGlv
bnMgaXMgdGhhdCBhIGdpdmVuIHBtZCByYW5nZSBpcyB1bm1hcHBlZC4gIFNlZQ0KdnVubWFwX3Bt
ZF9yYW5nZSgpLg0KDQpUaGFua3MsDQotVG9zaGkNCg==
