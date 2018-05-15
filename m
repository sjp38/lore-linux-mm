Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6256C6B02BB
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:34:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f10-v6so399606pln.21
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:34:30 -0700 (PDT)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id v16-v6si394492pfn.77.2018.05.15.09.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 09:34:28 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/3] x86/mm: add TLB purge to free pmd/pte page interfaces
Date: Tue, 15 May 2018 16:34:24 +0000
Message-ID: <1526401993.2693.605.camel@hpe.com>
References: <20180430175925.2657-1-toshi.kani@hpe.com>
	 <20180430175925.2657-3-toshi.kani@hpe.com>
	 <20180515140549.GE18595@8bytes.org>
In-Reply-To: <20180515140549.GE18595@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <680043A3F4C61F41930C5FFC82921F1F@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVHVlLCAyMDE4LTA1LTE1IGF0IDE2OjA1ICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IE9uIE1vbiwgQXByIDMwLCAyMDE4IGF0IDExOjU5OjI0QU0gLTA2MDAsIFRvc2hpIEthbmkgd3Jv
dGU6DQo+ID4gIGludCBwdWRfZnJlZV9wbWRfcGFnZShwdWRfdCAqcHVkLCB1bnNpZ25lZCBsb25n
IGFkZHIpDQo+ID4gIHsNCj4gPiAtCXBtZF90ICpwbWQ7DQo+ID4gKwlwbWRfdCAqcG1kLCAqcG1k
X3N2Ow0KPiA+ICsJcHRlX3QgKnB0ZTsNCj4gPiAgCWludCBpOw0KPiA+ICANCj4gPiAgCWlmIChw
dWRfbm9uZSgqcHVkKSkNCj4gPiAgCQlyZXR1cm4gMTsNCj4gPiAgDQo+ID4gIAlwbWQgPSAocG1k
X3QgKilwdWRfcGFnZV92YWRkcigqcHVkKTsNCj4gPiArCXBtZF9zdiA9IChwbWRfdCAqKV9fZ2V0
X2ZyZWVfcGFnZShHRlBfS0VSTkVMKTsNCj4gDQo+IFNvIHlvdSBuZWVkIHRvIGFsbG9jYXRlIGEg
cGFnZSB0byBmcmVlIGEgcGFnZT8gSXQgaXMgYmV0dGVyIHRvIHB1dCB0aGUNCj4gcGFnZXMgaW50
byBhIGxpc3Qgd2l0aCBhIGxpc3RfaGVhZCBvbiB0aGUgc3RhY2suDQoNClRoZSBjb2RlIHNob3Vs
ZCBoYXZlIGNoZWNrZWQgaWYgcG1kX3N2IGlzIE5VTEwuLi4gIEkgd2lsbCB1cGRhdGUgdGhlDQpw
YXRjaC4NCg0KRm9yIHBlcmZvcm1hbmNlLCBJIGRvIG5vdCB0aGluayB0aGlzIHBhZ2UgYWxsb2Mg
aXMgYSBwcm9ibGVtLiAgVW5saWtlDQpwbWRfZnJlZV9wdGVfcGFnZSgpLCBwdWRfZnJlZV9wbWRf
cGFnZSgpIGNvdmVycyBhbiBleHRyZW1lbHkgcmFyZSBjYXNlLiANCiAgU2luY2UgcHVkIHJlcXVp
cmVzIDFHQi1hbGlnbm1lbnQsIHB1ZCBhbmQgcG1kL3B0ZSBtYXBwaW5ncyBkbyBub3QNCnNoYXJl
IHRoZSBzYW1lIHJhbmdlcyB3aXRoaW4gdGhlIHZtYWxsb2Mgc3BhY2UuICBJIGhhZCB0byBpbnN0
cnVtZW50IHRoZQ0Ka2VybmVsIHRvIGZvcmNlIHRoZW0gc2hhcmUgdGhlIHNhbWUgcmFuZ2VzIGlu
IG9yZGVyIHRvIHRlc3QgdGhpcyBwYXRjaC4NCg0KPiBJIGFtIHN0aWxsIG9uIGZhdm91ciBvZiBq
dXN0IHJldmVydGluZyB0aGUgYnJva2VuIGNvbW1pdCBhbmQgZG8gYQ0KPiBjb3JyZWN0IGFuZCB3
b3JraW5nIGZpeCBmb3IgdGhlL2EgbWVyZ2Ugd2luZG93Lg0KDQpJIHdpbGwgcmVvcmRlciB0aGUg
cGF0Y2ggc2VyaWVzLCBhbmQgY2hhbmdlIHBhdGNoIDMvMyB0byAxLzMgc28gdGhhdCB3ZQ0KY2Fu
IHRha2UgaXQgZmlyc3QgdG8gZml4IHRoZSBCVUdfT04gb24gUEFFLiAgVGhpcyByZXZlcnQgd2ls
bCBkaXNhYmxlDQoyTUIgaW9yZW1hcCBvbiBQQUUgaW4gc29tZSBjYXNlcywgYnV0IEkgZG8gbm90
IHRoaW5rIGl0J3MgaW1wb3J0YW50IG9uDQpQQUUgYW55d2F5Lg0KDQpJIGRvIG5vdCB0aGluayBy
ZXZlcnQgb24geDg2LzY0IGlzIG5lY2Vzc2FyeSBhbmQgSSBhbSBtb3JlIHdvcnJpZWQgYWJvdXQN
CmRpc2FibGluZyAyTUIgaW9yZW1hcCBpbiBzb21lIGNhc2VzLCB3aGljaCBjYW4gYmUgc2VlbiBh
cyBkZWdyYWRhdGlvbi4gDQpQYXRjaCAyLzMgZml4ZXMgYSBwb3NzaWJsZSBwYWdlLWRpcmVjdG9y
eSBjYWNoZSBpc3N1ZSB0aGF0IEkgY2Fubm90IGhpdA0KZXZlbiB0aG91Z2ggSSBwdXQgaW9yZW1h
cC9pb3VubWFwIHdpdGggdmFyaW91cyBzaXplcyBpbnRvIGEgdGlnaHQgbG9vcA0KZm9yIGEgZGF5
Lg0KDQpUaGFua3MsDQotVG9zaGkNCg==
