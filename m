Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D71A66B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:50:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u68so4476813pgc.13
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:50:46 -0700 (PDT)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id v4-v6si4727262ply.351.2018.04.26.10.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 10:50:45 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Date: Thu, 26 Apr 2018 17:49:58 +0000
Message-ID: <1524764948.2693.478.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-3-toshi.kani@hpe.com>
	 <20180426141926.GN15462@8bytes.org> <1524759629.2693.465.camel@hpe.com>
	 <20180426172327.GQ15462@8bytes.org>
In-Reply-To: <20180426172327.GQ15462@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <BD7B01EDF5027C46BE3A540B0138870D@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko,
 Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gVGh1LCAyMDE4LTA0LTI2IGF0IDE5OjIzICswMjAwLCBqb3JvQDhieXRlcy5vcmcgd3JvdGU6
DQo+IE9uIFRodSwgQXByIDI2LCAyMDE4IGF0IDA0OjIxOjE5UE0gKzAwMDAsIEthbmksIFRvc2hp
IHdyb3RlOg0KPiA+IEFsbCBwYWdlcyB1bmRlciB0aGUgcG1kIGhhZCBiZWVuIHVubWFwcGVkIGFu
ZCB0aGVuIGxhenkgVExCIHB1cmdlZCB3aXRoDQo+ID4gSU5WTFBHIGJlZm9yZSBjb21pbmcgdG8g
dGhpcyBjb2RlIHBhdGguICBTcGVjdWxhdGlvbiBpcyBub3QgYWxsb3dlZCB0bw0KPiA+IHBhZ2Vz
IHdpdGhvdXQgbWFwcGluZy4NCj4gDQo+IENQVXMgaGF2ZSBub3Qgb25seSBUTEJzLCBidXQgYWxz
byBwYWdlLXdhbGsgY2FjaGVzIHdoaWNoIGNhY2hlDQo+IGludGVybWVkaWFyeSByZXN1bHRzIG9m
IHBhZ2UtdGFibGUgd2Fsa3MgYW5kIHdoaWNoIGlzIGZsdXNoZWQgdG9nZXRoZXINCj4gd2l0aCB0
aGUgVExCLg0KPiANCj4gU28gdGhlIFBNRCBlbnRyeSB5b3UgY2xlYXIgY2FuIHN0aWxsIGJlIGlu
IGEgcGFnZS13YWxrIGNhY2hlIGFuZCB0aGlzDQo+IG5lZWRzIHRvIGJlIGZsdXNoZWQgdG9vIGJl
Zm9yZSB5b3UgY2FuIGZyZWUgdGhlIFBURSBwYWdlLiBPdGhlcndpc2UNCj4gcGFnZS13YWxrcyBt
aWdodCBzdGlsbCBnbyB0byB0aGUgcGFnZSB5b3UganVzdCBmcmVlZC4gVGhhdCBpcyBlc3BlY2lh
bGx5DQo+IGJhZCB3aGVuIHRoZSBwYWdlIGlzIGFscmVhZHkgcmVhbGxvY2F0ZWQgYW5kIGZpbGxl
ZCB3aXRoIG90aGVyIGRhdGEuDQoNCkkgZG8gbm90IHVuZGVyc3RhbmQgd2h5IHdlIG5lZWQgdG8g
Zmx1c2ggcHJvY2Vzc29yIGNhY2hlcyBoZXJlLiB4ODYNCnByb2Nlc3NvciBjYWNoZXMgYXJlIGNv
aGVyZW50IHdpdGggTUVTSS4gIFNvLCBjbGVhcmluZyBhbiBQTUQgZW50cnkNCm1vZGlmaWVzIGEg
Y2FjaGUgZW50cnkgb24gdGhlIHByb2Nlc3NvciBhc3NvY2lhdGVkIHdpdGggdGhlIGFkZHJlc3Ms
DQp3aGljaCBpbiB0dXJuIGludmFsaWRhdGVzIGFsbCBzdGFsZSBjYWNoZSBlbnRyaWVzIG9uIG90
aGVyIHByb2Nlc3NvcnMuDQoNCj4gPiA+IEZ1cnRoZXIgdGhpcyBuZWVkcyBzeW5jaHJvbml6YXRp
b24gd2l0aCBvdGhlciBwYWdlLXRhYmxlcyBpbiB0aGUgc3lzdGVtDQo+ID4gPiB3aGVuIHRoZSBr
ZXJuZWwgUE1EcyBhcmUgbm90IHNoYXJlZCBiZXR3ZWVuIHByb2Nlc3Nlcy4gSW4geDg2LTMyIHdp
dGgNCj4gPiA+IFBBRSB0aGlzIGNhdXNlcyBhIEJVR19PTigpIGJlaW5nIHRyaWdnZXJlZCBhdCBh
cmNoL3g4Ni9tbS9mYXVsdC5jOjI2OA0KPiA+ID4gYmVjYXVzZSB0aGUgcGFnZS10YWJsZXMgYXJl
IG5vdCBjb3JyZWN0bHkgc3luY2hyb25pemVkLg0KPiA+IA0KPiA+IEkgdGhpbmsgdGhpcyBpcyBh
biBpc3N1ZSB3aXRoIHBtZCBtYXBwaW5nIHN1cHBvcnQgb24geDg2LTMyLVBBRSwgbm90DQo+ID4g
d2l0aCB0aGlzIHBhdGNoLiAgSSB0aGluayB0aGUgY29kZSBuZWVkZWQgdG8gYmUgdXBkYXRlZCB0
byBzeW5jIGF0IHRoZQ0KPiA+IHB1ZCBsZXZlbC4NCj4gDQo+IEl0IGlzIGFuIGlzc3VlIHdpdGgg
dGhpcyBwYXRjaCwgYmVjYXVzZSB0aGlzIHBhdGNoIGlzIGZvciB4ODYgYW5kIG9uIHg4Ng0KPiBl
dmVyeSBjaGFuZ2UgdG8gdGhlIGtlcm5lbCBwYWdlLXRhYmxlcyBwb3RlbnRpYWxseSBuZWVkcyB0
byBieQ0KPiBzeW5jaHJvbml6ZWQgdG8gdGhlIG90aGVyIHBhZ2UtdGFibGVzLiBBbmQgdGhpcyBw
YXRjaCBkb2Vzbid0IGltcGxlbWVudA0KPiBpdCwgd2hpY2ggdHJpZ2dlcnMgYSBCVUdfT04oKSB1
bmRlciBjZXJ0YWluIGNvbmRpdGlvbnMuDQoNClRoZSBpc3N1ZSB3YXMgaW50cm9kdWNlZCB3aGVu
IHBtZCBtYXBwaW5nIHN1cHBvcnQgd2FzIGFkZGVkIG9uIHg4Ni8zMiwNCndoaWNoIHdhcyBtYWRl
IHByaW9yIHRvIHRoaXMgcGF0Y2guDQoNClRoYW5rcywNCi1Ub3NoaQ0K
