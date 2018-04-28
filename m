Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 005E06B0007
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 16:54:50 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z6-v6so3952166pgu.20
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 13:54:49 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id u2-v6si1061220plm.379.2018.04.28.13.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Apr 2018 13:54:48 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Sat, 28 Apr 2018 20:54:42 +0000
Message-ID: <1524948829.2693.547.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <20180426141926.GN15462@8bytes.org> <1524759629.2693.465.camel@hpe.com>
	 <20180426172327.GQ15462@8bytes.org> <1524764948.2693.478.camel@hpe.com>
	 <20180426200737.GS15462@8bytes.org> <1524781764.2693.503.camel@hpe.com>
	 <20180427073719.GT15462@8bytes.org> <1524839460.2693.531.camel@hpe.com>
	 <20180428090217.n2l3w4vobmtkvz6k@8bytes.org>
In-Reply-To: <20180428090217.n2l3w4vobmtkvz6k@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <AE6C04653E607F4DA2883AEC95039EB8@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko,
 Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gU2F0LCAyMDE4LTA0LTI4IGF0IDExOjAyICswMjAwLCBqb3JvQDhieXRlcy5vcmcgd3JvdGU6
DQo+IE9uIEZyaSwgQXByIDI3LCAyMDE4IGF0IDAyOjMxOjUxUE0gKzAwMDAsIEthbmksIFRvc2hp
IHdyb3RlOg0KPiA+IFNvLCB3ZSBjYW4gYWRkIHRoZSBzdGVwIDIgb24gdG9wIG9mIHRoaXMgcGF0
Y2guDQo+ID4gIDEuIENsZWFyIHB1ZC9wbWQgZW50cnkuDQo+ID4gIDIuIFN5c3RlbSB3aWRlIFRM
QiBmbHVzaCA8LS0gVE8gQkUgQURERUQgQlkgTkVXIFBBVENIDQo+ID4gIDMuIEZyZWUgaXRzIHVu
ZGVybGluaW5nIHBtZC9wdGUgcGFnZS4NCj4gDQo+IFRoaXMgc3RpbGwgbGFja3MgdGhlIHBhZ2Ut
dGFibGUgc3luY2hyb25pemF0aW9uIGFuZCB3aWxsIHRodXMgbm90IGZpeA0KPiB0aGUgQlVHX09O
IGJlaW5nIHRyaWdnZXJlZC4NCg0KVGhlIEJVR19PTiBpc3N1ZSBpcyBzcGVjaWZpYyB0byBQQUUg
dGhhdCBpdCBzeW5jcyBhdCB0aGUgcG1kIGxldmVsLg0KeDg2LzY0IGRvZXMgbm90IGhhdmUgdGhp
cyBpc3N1ZSBzaW5jZSBpdCBzeW5jcyBhdCB0aGUgcGdkIG9yIHA0ZCBsZXZlbC4NCg0KPiA+IFdl
IGRvIG5vdCBuZWVkIHRvIHJldmVydCB0aGlzIHBhdGNoLiAgV2UgY2FuIG1ha2UgdGhlIGFib3Zl
IGNoYW5nZSBJDQo+ID4gbWVudGlvbmVkLg0KPiANCj4gUGxlYXNlIG5vdGUgdGhhdCB3ZSBhcmUg
bm90IGluIHRoZSBtZXJnZSB3aW5kb3cgYW55bW9yZSBhbmQgdGhhdCBhbnkgZml4DQo+IG5lZWRz
IHRvIGJlIHNpbXBsZSBhbmQgb2J2aW91c2x5IGNvcnJlY3QuDQoNClVuZGVyc3Rvb2QuICBDaGFu
Z2luZyB0aGUgeDg2LzMyIHN5bmMgcG9pbnQgaXMgcmlza3kuICBTbywgSSBhbSBnb2luZyB0bw0K
cmV2ZXJ0IHRoZSBmcmVlIHBhZ2UgaGFuZGxpbmcgZm9yIFBBRS4gICANCg0KVGhhbmtzLA0KLVRv
c2hpDQoNCg==
