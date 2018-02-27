Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3878D6B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 14:49:48 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v71so3044oia.13
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 11:49:48 -0800 (PST)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id u18si3321574oie.482.2018.02.27.11.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 11:49:46 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: =?utf-8?B?UmU6IOetlOWkjTogW1JGQyBwYXRjaF0gaW9yZW1hcDogZG9uJ3Qgc2V0IHVw?=
 =?utf-8?Q?_huge_I/O_mappings_when_p4d/pud/pmd_is_zero?=
Date: Tue, 27 Feb 2018 19:49:42 +0000
Message-ID: <1519763686.2693.2.camel@hpe.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
	 <861128ce-966f-7006-45ba-6a7298918686@codeaurora.org>
	 <1519175992.16384.121.camel@hpe.com>
	 <etPan.5a8d2180.1dbfd272.49b8@localhost> <20180221115758.GA7614@arm.com>
	 <32c9b1c3-086b-ba54-f9e9-aefa50066730@huawei.com>
	 <20180226110422.GD8736@arm.com>
	 <a80e540f-f3bd-53da-185d-7fffe801f10c@huawei.com>
In-Reply-To: <a80e540f-f3bd-53da-185d-7fffe801f10c@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <29A967BA55147B45AC689AF729FCB186@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <mhocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

T24gTW9uLCAyMDE4LTAyLTI2IGF0IDIwOjUzICswODAwLCBIYW5qdW4gR3VvIHdyb3RlOg0KPiBP
biAyMDE4LzIvMjYgMTk6MDQsIFdpbGwgRGVhY29uIHdyb3RlOg0KPiA+IE9uIE1vbiwgRmViIDI2
LCAyMDE4IGF0IDA2OjU3OjIwUE0gKzA4MDAsIEhhbmp1biBHdW8gd3JvdGU6DQo+ID4gPiBPbiAy
MDE4LzIvMjEgMTk6NTcsIFdpbGwgRGVhY29uIHdyb3RlOg0KPiA+ID4gPiBbc29ycnksIHRyeWlu
ZyB0byBkZWFsIHdpdGggdG9wLXBvc3RpbmcgaGVyZV0NCj4gPiA+ID4gDQo+ID4gPiA+IE9uIFdl
ZCwgRmViIDIxLCAyMDE4IGF0IDA3OjM2OjM0QU0gKzAwMDAsIFdhbmd4dWVmZW5nIChFKSB3cm90
ZToNCj4gPiA+ID4gPiAgICAgIFRoZSBvbGQgZmxvdyBvZiByZXVzZSB0aGUgNGsgcGFnZSBhcyAy
TSBwYWdlIGRvZXMgbm90IGZvbGxvdyB0aGUgQkJNIGZsb3cNCj4gPiA+ID4gPiBmb3IgcGFnZSB0
YWJsZSByZWNvbnN0cnVjdGlvbu+8jG5vdCBvbmx5IHRoZSBtZW1vcnkgbGVhayBwcm9ibGVtcy4g
IElmIEJCTSBmbG93DQo+ID4gPiA+ID4gaXMgbm90IGZvbGxvd2Vk77yMdGhlIHNwZWN1bGF0aXZl
IHByZWZldGNoIG9mIHRsYiB3aWxsIG1hZGUgZmFsc2UgdGxiIGVudHJpZXMNCj4gPiA+ID4gPiBj
YWNoZWQgaW4gTU1VLCB0aGUgZmFsc2UgYWRkcmVzcyB3aWxsIGJlIGdvdO+8jCBwYW5pYyB3aWxs
IGhhcHBlbi4NCj4gPiA+ID4gDQo+ID4gPiA+IElmIEkgdW5kZXJzdGFuZCBUb3NoaSdzIHN1Z2dl
c3Rpb24gY29ycmVjdGx5LCBoZSdzIHNheWluZyB0aGF0IHRoZSBQTUQgY2FuDQo+ID4gPiA+IGJl
IGNsZWFyZWQgd2hlbiB1bm1hcHBpbmcgdGhlIGxhc3QgUFRFIChsaWtlIHRyeV90b19mcmVlX3B0
ZV9wYWdlKS4gSW4gdGhpcw0KPiA+ID4gPiBjYXNlLCB0aGVyZSdzIG5vIGlzc3VlIHdpdGggdGhl
IFRMQiBiZWNhdXNlIHRoaXMgaXMgZXhhY3RseSBCQk0gLS0gdGhlIFBNRA0KPiA+ID4gPiBpcyBj
bGVhcmVkIGFuZCBUTEIgaW52YWxpZGF0aW9uIGlzIGlzc3VlZCBiZWZvcmUgdGhlIFBURSB0YWJs
ZSBpcyBmcmVlZC4gQQ0KPiA+ID4gPiBzdWJzZXF1ZW50IDJNIG1hcCByZXF1ZXN0IHdpbGwgc2Vl
IGFuIGVtcHR5IFBNRCBhbmQgcHV0IGRvd24gYSBibG9jaw0KPiA+ID4gPiBtYXBwaW5nLg0KPiA+
ID4gPiANCj4gPiA+ID4gVGhlIGRvd25zaWRlIGlzIHRoYXQgZnJlZWluZyBiZWNvbWVzIG1vcmUg
ZXhwZW5zaXZlIGFzIHRoZSBsYXN0IGxldmVsIHRhYmxlDQo+ID4gPiA+IGJlY29tZXMgbW9yZSBz
cGFyc2VseSBwb3B1bGF0ZWQgYW5kIHlvdSBuZWVkIHRvIGVuc3VyZSB5b3UgZG9uJ3QgaGF2ZSBh
bnkNCj4gPiA+ID4gY29uY3VycmVudCBtYXBzIGdvaW5nIG9uIGZvciB0aGUgc2FtZSB0YWJsZSB3
aGVuIHlvdSdyZSB1bm1hcHBpbmcuIEkgYWxzbw0KPiA+ID4gPiBjYW4ndCBzZWUgYSBuZWF0IHdh
eSB0byBmaXQgdGhpcyBpbnRvIHRoZSBjdXJyZW50IHZ1bm1hcCBjb2RlLiBQZXJoYXBzIHdlDQo+
ID4gPiA+IG5lZWQgYW4gaW91bm1hcF9wYWdlX3JhbmdlLg0KPiA+ID4gPiANCj4gPiA+ID4gSW4g
dGhlIG1lYW50aW1lLCB0aGUgY29kZSBpbiBsaWIvaW9yZW1hcC5jIGxvb2tzIHRvdGFsbHkgYnJv
a2VuIHNvIEkgdGhpbmsNCj4gPiA+ID4gd2Ugc2hvdWxkIGRlc2VsZWN0IENPTkZJR19IQVZFX0FS
Q0hfSFVHRV9WTUFQIG9uIGFybTY0IHVudGlsIGl0J3MgZml4ZWQuDQo+ID4gPiANCj4gPiA+IFNp
bXBseSBkbyBzb21ldGhpbmcgYmVsb3cgYXQgbm93IChiZWZvcmUgdGhlIGJyb2tlbiBjb2RlIGlz
IGZpeGVkKT8NCj4gPiA+IA0KPiA+ID4gZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvS2NvbmZpZyBi
L2FyY2gvYXJtNjQvS2NvbmZpZw0KPiA+ID4gaW5kZXggYjJiOTVmNy4uYTg2MTQ4YyAxMDA2NDQN
Cj4gPiA+IC0tLSBhL2FyY2gvYXJtNjQvS2NvbmZpZw0KPiA+ID4gKysrIGIvYXJjaC9hcm02NC9L
Y29uZmlnDQo+ID4gPiBAQCAtODQsNyArODQsNiBAQCBjb25maWcgQVJNNjQNCj4gPiA+ICAgICAg
ICAgc2VsZWN0IEhBVkVfQUxJR05FRF9TVFJVQ1RfUEFHRSBpZiBTTFVCDQo+ID4gPiAgICAgICAg
IHNlbGVjdCBIQVZFX0FSQ0hfQVVESVRTWVNDQUxMDQo+ID4gPiAgICAgICAgIHNlbGVjdCBIQVZF
X0FSQ0hfQklUUkVWRVJTRQ0KPiA+ID4gLSAgIHNlbGVjdCBIQVZFX0FSQ0hfSFVHRV9WTUFQDQo+
ID4gPiAgICAgICAgIHNlbGVjdCBIQVZFX0FSQ0hfSlVNUF9MQUJFTA0KPiA+ID4gICAgICAgICBz
ZWxlY3QgSEFWRV9BUkNIX0tBU0FOIGlmICEoQVJNNjRfMTZLX1BBR0VTICYmIEFSTTY0X1ZBX0JJ
VFNfNDgpDQo+ID4gPiAgICAgICAgIHNlbGVjdCBIQVZFX0FSQ0hfS0dEQg0KPiA+IA0KPiA+IE5v
LCB0aGF0IGFjdHVhbGx5IGJyZWFrcyB3aXRoIHRoZSB1c2Ugb2YgYmxvY2sgbWFwcGluZ3MgZm9y
IHRoZSBrZXJuZWwNCj4gPiB0ZXh0LiBBbnl3YXksIHNlZToNCj4gPiANCj4gPiBodHRwczovL2dp
dC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90b3J2YWxkcy9saW51eC5naXQv
Y29tbWl0Lz9pZD0xNTEyMmVlMmM1MTVhMjUzYjBjNjZhM2U2MThiYzdlYmUzNTEwNWViDQo+IA0K
PiBTb3JyeSwganVzdCBiYWNrIGZyb20gaG9saWRheXMgYW5kIGRpZG4ndCBjYXRjaCB1cCB3aXRo
IGFsbCB0aGUgZW1haWxzLA0KPiB0aGFua3MgZm9yIHRha2luZyBjYXJlIG9mIHRoaXMuDQoNCkkg
d2lsbCB3b3JrIG9uIGEgZml4IGZvciB0aGUgY29tbW9uL3g4NiBjb2RlLg0KDQpUaGFua3MsDQot
VG9zaGkNCg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
