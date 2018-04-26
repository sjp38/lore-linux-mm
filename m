Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC4D36B0024
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 18:30:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j18so14127642pgv.18
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 15:30:22 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id l3si5472657pfi.179.2018.04.26.15.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 15:30:21 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Thu, 26 Apr 2018 22:30:14 +0000
Message-ID: <1524781764.2693.503.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <20180426141926.GN15462@8bytes.org> <1524759629.2693.465.camel@hpe.com>
	 <20180426172327.GQ15462@8bytes.org> <1524764948.2693.478.camel@hpe.com>
	 <20180426200737.GS15462@8bytes.org>
In-Reply-To: <20180426200737.GS15462@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5EDE787B35BE6D488AF4ABE41F90DD56@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko,
 Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTA0LTI2IGF0IDIyOjA3ICswMjAwLCBqb3JvQDhieXRlcy5vcmcgd3JvdGU6
DQo+IE9uIFRodSwgQXByIDI2LCAyMDE4IGF0IDA1OjQ5OjU4UE0gKzAwMDAsIEthbmksIFRvc2hp
IHdyb3RlOg0KPiA+IE9uIFRodSwgMjAxOC0wNC0yNiBhdCAxOToyMyArMDIwMCwgam9yb0A4Ynl0
ZXMub3JnIHdyb3RlOg0KPiA+ID4gU28gdGhlIFBNRCBlbnRyeSB5b3UgY2xlYXIgY2FuIHN0aWxs
IGJlIGluIGEgcGFnZS13YWxrIGNhY2hlIGFuZCB0aGlzDQo+ID4gPiBuZWVkcyB0byBiZSBmbHVz
aGVkIHRvbyBiZWZvcmUgeW91IGNhbiBmcmVlIHRoZSBQVEUgcGFnZS4gT3RoZXJ3aXNlDQo+ID4g
PiBwYWdlLXdhbGtzIG1pZ2h0IHN0aWxsIGdvIHRvIHRoZSBwYWdlIHlvdSBqdXN0IGZyZWVkLiBU
aGF0IGlzIGVzcGVjaWFsbHkNCj4gPiA+IGJhZCB3aGVuIHRoZSBwYWdlIGlzIGFscmVhZHkgcmVh
bGxvY2F0ZWQgYW5kIGZpbGxlZCB3aXRoIG90aGVyIGRhdGEuDQo+ID4gDQo+ID4gSSBkbyBub3Qg
dW5kZXJzdGFuZCB3aHkgd2UgbmVlZCB0byBmbHVzaCBwcm9jZXNzb3IgY2FjaGVzIGhlcmUuIHg4
Ng0KPiA+IHByb2Nlc3NvciBjYWNoZXMgYXJlIGNvaGVyZW50IHdpdGggTUVTSS4gIFNvLCBjbGVh
cmluZyBhbiBQTUQgZW50cnkNCj4gPiBtb2RpZmllcyBhIGNhY2hlIGVudHJ5IG9uIHRoZSBwcm9j
ZXNzb3IgYXNzb2NpYXRlZCB3aXRoIHRoZSBhZGRyZXNzLA0KPiA+IHdoaWNoIGluIHR1cm4gaW52
YWxpZGF0ZXMgYWxsIHN0YWxlIGNhY2hlIGVudHJpZXMgb24gb3RoZXIgcHJvY2Vzc29ycy4NCj4g
DQo+IEEgcGFnZSB3YWxrIGNhY2hlIGlzIG5vdCBhYm91dCB0aGUgcHJvY2Vzc29ycyBkYXRhIGNh
Y2hlLCBpdHMgYSBjYWNoZQ0KPiBzaW1pbGFyIHRvIHRoZSBUTEIgdG8gc3BlZWQgdXAgcGFnZS13
YWxrcyBieSBjYWNoaW5nIGludGVybWVkaWF0ZQ0KPiByZXN1bHRzIG9mIHByZXZpb3VzIHBhZ2Ug
d2Fsa3MuDQoNClRoYW5rcyBmb3IgdGhlIGNsYXJpZmljYXRpb24uIEFmdGVyIHJlYWRpbmcgdGhy
b3VnaCBTRE0gb25lIG1vcmUgdGltZSwgSQ0KYWdyZWUgdGhhdCB3ZSBuZWVkIGEgVExCIHB1cmdl
IGhlcmUuIEhlcmUgaXMgbXkgY3VycmVudCB1bmRlcnN0YW5kaW5nLiANCg0KIC0gSU5WTFBHIHB1
cmdlcyBib3RoIFRMQiBhbmQgcGFnaW5nLXN0cnVjdHVyZSBjYWNoZXMuIFNvLCBQTUQgY2FjaGUg
d2FzDQpwdXJnZWQgb25jZS4NCiAtIEhvd2V2ZXIsIHByb2Nlc3NvciBtYXkgY2FjaGUgdGhpcyBQ
TUQgZW50cnkgbGF0ZXIgaW4gc3BlY3VsYXRpb24NCnNpbmNlIGl0IGhhcyBwLWJpdCBzZXQuIChU
aGlzIGlzIHdoZXJlIG15IG1pc3VuZGVyc3RhbmRpbmcgd2FzLg0KU3BlY3VsYXRpb24gaXMgbm90
IGFsbG93ZWQgdG8gYWNjZXNzIGEgdGFyZ2V0IGFkZHJlc3MsIGJ1dCBpdCBtYXkgc3RpbGwNCmNh
Y2hlIHRoaXMgUE1EIGVudHJ5LikNCiAtIEEgc2luZ2xlIElOVkxQRyBvbiBlYWNoIHByb2Nlc3Nv
ciBwdXJnZXMgdGhpcyBQTUQgY2FjaGUuIEl0IGRvZXMgbm90DQpuZWVkIGEgcmFuZ2UgcHVyZ2Ug
KHdoaWNoIHdhcyBhbHJlYWR5IGRvbmUpLg0KDQpEb2VzIGl0IHNvdW5kIHJpZ2h0IHRvIHlvdT8N
Cg0KQXMgZm9yIHRoZSBCVUdfT04gaXNzdWUsIGFyZSB5b3UgYWJsZSB0byByZXByb2R1Y2UgdGhp
cyBpc3N1ZT8gIElmIHNvLA0Kd291bGQgeW91IGJlIGFibGUgdG8gdGVzdCB0aGUgZml4Pw0KDQpS
ZWdhcmRzLA0KLVRvc2hpDQo=
