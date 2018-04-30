Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 760216B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 09:43:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z24so992647pfn.5
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:43:51 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id t71-v6si6063099pgc.444.2018.04.30.06.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 06:43:50 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Mon, 30 Apr 2018 13:43:37 +0000
Message-ID: <1525095763.2693.550.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <20180426141926.GN15462@8bytes.org> <1524759629.2693.465.camel@hpe.com>
	 <20180426172327.GQ15462@8bytes.org> <1524764948.2693.478.camel@hpe.com>
	 <20180426200737.GS15462@8bytes.org> <1524781764.2693.503.camel@hpe.com>
	 <20180427073719.GT15462@8bytes.org> <1524839460.2693.531.camel@hpe.com>
	 <20180428090217.n2l3w4vobmtkvz6k@8bytes.org>
	 <1524948829.2693.547.camel@hpe.com>
	 <c8c5e78a-2cb2-ca46-6521-928b6c0114c6@codeaurora.org>
In-Reply-To: <c8c5e78a-2cb2-ca46-6521-928b6c0114c6@codeaurora.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <2A59DFC846261343BB407C0FE1A574EB@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "bp@suse.de" <bp@suse.de>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gTW9uLCAyMDE4LTA0LTMwIGF0IDEzOjAwICswNTMwLCBDaGludGFuIFBhbmR5YSB3cm90ZToN
Cj4gDQo+IE9uIDQvMjkvMjAxOCAyOjI0IEFNLCBLYW5pLCBUb3NoaSB3cm90ZToNCj4gPiBPbiBT
YXQsIDIwMTgtMDQtMjggYXQgMTE6MDIgKzAyMDAsIGpvcm9AOGJ5dGVzLm9yZyB3cm90ZToNCj4g
PiA+IE9uIEZyaSwgQXByIDI3LCAyMDE4IGF0IDAyOjMxOjUxUE0gKzAwMDAsIEthbmksIFRvc2hp
IHdyb3RlOg0KPiA+ID4gPiBTbywgd2UgY2FuIGFkZCB0aGUgc3RlcCAyIG9uIHRvcCBvZiB0aGlz
IHBhdGNoLg0KPiA+ID4gPiAgIDEuIENsZWFyIHB1ZC9wbWQgZW50cnkuDQo+ID4gPiA+ICAgMi4g
U3lzdGVtIHdpZGUgVExCIGZsdXNoIDwtLSBUTyBCRSBBRERFRCBCWSBORVcgUEFUQ0gNCj4gPiA+
ID4gICAzLiBGcmVlIGl0cyB1bmRlcmxpbmluZyBwbWQvcHRlIHBhZ2UuDQo+ID4gPiANCj4gPiA+
IFRoaXMgc3RpbGwgbGFja3MgdGhlIHBhZ2UtdGFibGUgc3luY2hyb25pemF0aW9uIGFuZCB3aWxs
IHRodXMgbm90IGZpeA0KPiA+ID4gdGhlIEJVR19PTiBiZWluZyB0cmlnZ2VyZWQuDQo+ID4gDQo+
ID4gVGhlIEJVR19PTiBpc3N1ZSBpcyBzcGVjaWZpYyB0byBQQUUgdGhhdCBpdCBzeW5jcyBhdCB0
aGUgcG1kIGxldmVsLg0KPiA+IHg4Ni82NCBkb2VzIG5vdCBoYXZlIHRoaXMgaXNzdWUgc2luY2Ug
aXQgc3luY3MgYXQgdGhlIHBnZCBvciBwNGQgbGV2ZWwuDQo+ID4gDQo+ID4gPiA+IFdlIGRvIG5v
dCBuZWVkIHRvIHJldmVydCB0aGlzIHBhdGNoLiAgV2UgY2FuIG1ha2UgdGhlIGFib3ZlIGNoYW5n
ZSBJDQo+ID4gPiA+IG1lbnRpb25lZC4NCj4gPiA+IA0KPiA+ID4gUGxlYXNlIG5vdGUgdGhhdCB3
ZSBhcmUgbm90IGluIHRoZSBtZXJnZSB3aW5kb3cgYW55bW9yZSBhbmQgdGhhdCBhbnkgZml4DQo+
ID4gPiBuZWVkcyB0byBiZSBzaW1wbGUgYW5kIG9idmlvdXNseSBjb3JyZWN0Lg0KPiA+IA0KPiA+
IFVuZGVyc3Rvb2QuICBDaGFuZ2luZyB0aGUgeDg2LzMyIHN5bmMgcG9pbnQgaXMgcmlza3kuICBT
bywgSSBhbSBnb2luZyB0bw0KPiA+IHJldmVydCB0aGUgZnJlZSBwYWdlIGhhbmRsaW5nIGZvciBQ
QUUuDQo+IA0KPiBXaWxsIHRoaXMgYWZmZWN0IHBtZF9mcmVlX3B0ZV9wYWdlKCkgJiBwdWRfZnJl
ZV9wbWRfcGFnZSgpICdzIGV4aXN0ZW5jZQ0KPiBvciBpdHMgcGFyYW1ldGVycyA/IEknbSBhc2tp
bmcgYmVjYXVzZSwgSSd2ZSBzaW1pbGFyIGNoYW5nZSBmb3IgYXJtNjQNCj4gYW5kIHJlYWR5IHRv
IHNlbmQgdjkgcGF0Y2hlcy4NCg0KTm8sIGl0IHdvbid0LiAgVGhlIGNoYW5nZSBpcyBvbmx5IHRv
IHRoZSB4ODYgc2lkZS4NCg0KPiBJJ20gdGhpbmtpbmcgdG8gc2hhcmUgbXkgdjkgcGF0Y2hlcyBp
biBhbnkgY2FzZS4gSWYgeW91IGFyZSBnb2luZyB0byBkbw0KPiBUTEIgaW52YWxpZGF0aW9uIHdp
dGhpbiB0aGVzZSBBUElzLCBteSBmaXJzdCBwYXRjaCB3aWxsIGhlbHAuDQoNCkkgd2lsbCBtYWtl
IG15IGNoYW5nZSBvbiB0b3Agb2YgeW91ciB2OSAxLzQgcGF0Y2ggc28gdGhhdCB3ZSBjYW4gYXZv
aWQNCm1lcmdlIGNvbmZsaWN0Lg0KDQpUaGFua3MsDQotVG9zaGkNCg==
