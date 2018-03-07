Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8740F6B0009
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 18:02:18 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v5so2038979oib.17
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 15:02:18 -0800 (PST)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id 4si5237179otx.162.2018.03.07.15.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 15:02:17 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Date: Wed, 7 Mar 2018 23:02:12 +0000
Message-ID: <1520466429.2693.43.camel@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	 <20180307183227.17983-2-toshi.kani@hpe.com>
	 <20180307145454.d3df4bed6d6431c52bcf271e@linux-foundation.org>
In-Reply-To: <20180307145454.d3df4bed6d6431c52bcf271e@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <485C8B4D88DC1740BFEF56BD935DAF5C@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko,
 Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTAzLTA3IGF0IDE0OjU0IC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBXZWQsICA3IE1hciAyMDE4IDExOjMyOjI2IC0wNzAwIFRvc2hpIEthbmkgPHRvc2hpLmth
bmlAaHBlLmNvbT4gd3JvdGU6DQo+IA0KPiA+IE9uIGFyY2hpdGVjdHVyZXMgd2l0aCBDT05GSUdf
SEFWRV9BUkNIX0hVR0VfVk1BUCBzZXQsIGlvcmVtYXAoKQ0KPiA+IG1heSBjcmVhdGUgcHVkL3Bt
ZCBtYXBwaW5ncy4gIEtlcm5lbCBwYW5pYyB3YXMgb2JzZXJ2ZWQgb24gYXJtNjQNCj4gPiBzeXN0
ZW1zIHdpdGggQ29ydGV4LUE3NSBpbiB0aGUgZm9sbG93aW5nIHN0ZXBzIGFzIGRlc2NyaWJlZCBi
eQ0KPiA+IEhhbmp1biBHdW8uDQo+ID4gDQo+ID4gMS4gaW9yZW1hcCBhIDRLIHNpemUsIHZhbGlk
IHBhZ2UgdGFibGUgd2lsbCBidWlsZCwNCj4gPiAyLiBpb3VubWFwIGl0LCBwdGUwIHdpbGwgc2V0
IHRvIDA7DQo+ID4gMy4gaW9yZW1hcCB0aGUgc2FtZSBhZGRyZXNzIHdpdGggMk0gc2l6ZSwgcGdk
L3BtZCBpcyB1bmNoYW5nZWQsDQo+ID4gICAgdGhlbiBzZXQgdGhlIGEgbmV3IHZhbHVlIGZvciBw
bWQ7DQo+ID4gNC4gcHRlMCBpcyBsZWFrZWQ7DQo+ID4gNS4gQ1BVIG1heSBtZWV0IGV4Y2VwdGlv
biBiZWNhdXNlIHRoZSBvbGQgcG1kIGlzIHN0aWxsIGluIFRMQiwNCj4gPiAgICB3aGljaCB3aWxs
IGxlYWQgdG8ga2VybmVsIHBhbmljLg0KPiA+IA0KPiA+IFRoaXMgcGFuaWMgaXMgbm90IHJlcHJv
ZHVjaWJsZSBvbiB4ODYuICBJTlZMUEcsIGNhbGxlZCBmcm9tIGlvdW5tYXAsDQo+ID4gcHVyZ2Vz
IGFsbCBsZXZlbHMgb2YgZW50cmllcyBhc3NvY2lhdGVkIHdpdGggcHVyZ2VkIGFkZHJlc3Mgb24g
eDg2Lg0KPiA+IHg4NiBzdGlsbCBoYXMgbWVtb3J5IGxlYWsuDQo+ID4gDQo+ID4gQWRkIHR3byBp
bnRlcmZhY2VzLCBwdWRfZnJlZV9wbWRfcGFnZSgpIGFuZCBwbWRfZnJlZV9wdGVfcGFnZSgpLA0K
PiA+IHdoaWNoIGNsZWFyIGEgZ2l2ZW4gcHVkL3BtZCBlbnRyeSBhbmQgZnJlZSB1cCBhIHBhZ2Ug
Zm9yIHRoZSBsb3dlcg0KPiA+IGxldmVsIGVudHJpZXMuDQo+ID4gDQo+ID4gVGhpcyBwYXRjaCBp
bXBsZW1lbnRzIHRoZWlyIHN0dWIgZnVuY3Rpb25zIG9uIHg4NiBhbmQgYXJtNjQsIHdoaWNoDQo+
ID4gd29yayBhcyB3b3JrYXJvdW5kLg0KPiA+IA0KPiA+IGluZGV4IDAwNGFiZjllYmYxMi4uOTQy
ZjRmYTM0MWYxIDEwMDY0NA0KPiA+IC0tLSBhL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiA+ICsr
KyBiL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiA+IEBAIC03MDIsNCArNzAyLDI0IEBAIGludCBw
bWRfY2xlYXJfaHVnZShwbWRfdCAqcG1kKQ0KPiA+ICANCj4gPiAgCXJldHVybiAwOw0KPiA+ICB9
DQo+ID4gKw0KPiA+ICsvKioNCj4gPiArICogcHVkX2ZyZWVfcG1kX3BhZ2UgLSBjbGVhciBwdWQg
ZW50cnkgYW5kIGZyZWUgcG1kIHBhZ2UNCj4gPiArICoNCj4gPiArICogUmV0dXJucyAxIG9uIHN1
Y2Nlc3MgYW5kIDAgb24gZmFpbHVyZSAocHVkIG5vdCBjbGVhcmVkKS4NCj4gPiArICovDQo+ID4g
K2ludCBwdWRfZnJlZV9wbWRfcGFnZShwdWRfdCAqcHVkKQ0KPiA+ICt7DQo+ID4gKwlyZXR1cm4g
cHVkX25vbmUoKnB1ZCk7DQo+ID4gK30NCj4gPiArDQo+ID4gKy8qKg0KPiA+ICsgKiBwbWRfZnJl
ZV9wdGVfcGFnZSAtIGNsZWFyIHBtZCBlbnRyeSBhbmQgZnJlZSBwdGUgcGFnZQ0KPiA+ICsgKg0K
PiA+ICsgKiBSZXR1cm5zIDEgb24gc3VjY2VzcyBhbmQgMCBvbiBmYWlsdXJlIChwbWQgbm90IGNs
ZWFyZWQpLg0KPiA+ICsgKi8NCj4gPiAraW50IHBtZF9mcmVlX3B0ZV9wYWdlKHBtZF90ICpwbWQp
DQo+ID4gK3sNCj4gPiArCXJldHVybiBwbWRfbm9uZSgqcG1kKTsNCj4gPiArfQ0KPiANCj4gQXJl
IHRoZXNlIGZ1bmN0aW9ucyB3ZWxsIG5hbWVkPyAgSSBtZWFuLCB0aGUgY29tbWVudCBzYXlzICJj
bGVhciBwdWQNCj4gZW50cnkgYW5kIGZyZWUgcG1kIHBhZ2UiIGJ1dCB0aGUgaW1wbGVtZW50YXRp
biBkb2VzIG5laXRoZXIgb2YgdGhvc2UNCj4gdGhpbmdzLiAgVGhlIG5hbWUgaW1wbGllcyB0aGF0
IHRoZSBmdW5jdGlvbiBmcmVlcyBhIHBtZF9wYWdlIGJ1dCB0aGUNCj4gY2FsbHNpdGVzIHVzZSB0
aGUgZnVuY3Rpb24gYXMgYSB3YXkgb2YgcXVlcnlpbmcgc3RhdGUuDQoNClRoaXMgcGF0Y2ggMS8y
IG9ubHkgaW1wbGVtZW50cyBzdHVicy4gIFBhdGNoIDIvMiBpbXBsZW1lbnRzIHdoYXQgaXMNCmRl
c2NyaWJlZCBoZXJlLg0KDQo+IEFsc28sIGFzIHRoaXMgZml4ZXMgYW4gYXJtNjQga2VybmVsIHBh
bmljLCBzaG91bGQgd2UgYmUgdXNpbmcNCj4gY2M6c3RhYmxlPw0KDQpSaWdodC4NCg0KVGhhbmtz
LA0KLVRvc2hpDQo=
