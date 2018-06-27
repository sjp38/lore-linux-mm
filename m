Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C49356B026B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:13:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y123-v6so1816951oie.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:13:44 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id t17-v6si1519594oij.441.2018.06.27.09.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 09:13:43 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 2/3] ioremap: Update pgtable free interfaces with addr
Date: Wed, 27 Jun 2018 16:13:22 +0000
Message-ID: <1530115885.14039.295.camel@hpe.com>
References: <20180627141348.21777-1-toshi.kani@hpe.com>
	 <20180627141348.21777-3-toshi.kani@hpe.com>
	 <20180627155632.GH30631@arm.com>
In-Reply-To: <20180627155632.GH30631@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <397C5A88CFE1164E80BA21374D6CCD34@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTA2LTI3IGF0IDE2OjU2ICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
SGkgVG9zaGksDQo+IA0KPiBPbiBXZWQsIEp1biAyNywgMjAxOCBhdCAwODoxMzo0N0FNIC0wNjAw
LCBUb3NoaSBLYW5pIHdyb3RlOg0KPiA+IEZyb206IENoaW50YW4gUGFuZHlhIDxjcGFuZHlhQGNv
ZGVhdXJvcmEub3JnPg0KPiA+IA0KPiA+IFRoZSBmb2xsb3dpbmcga2VybmVsIHBhbmljIHdhcyBv
YnNlcnZlZCBvbiBBUk02NCBwbGF0Zm9ybSBkdWUgdG8gYSBzdGFsZQ0KPiA+IFRMQiBlbnRyeS4N
Cj4gPiANCj4gPiAgMS4gaW9yZW1hcCB3aXRoIDRLIHNpemUsIGEgdmFsaWQgcHRlIHBhZ2UgdGFi
bGUgaXMgc2V0Lg0KPiA+ICAyLiBpb3VubWFwIGl0LCBpdHMgcHRlIGVudHJ5IGlzIHNldCB0byAw
Lg0KPiA+ICAzLiBpb3JlbWFwIHRoZSBzYW1lIGFkZHJlc3Mgd2l0aCAyTSBzaXplLCB1cGRhdGUg
aXRzIHBtZCBlbnRyeSB3aXRoDQo+ID4gICAgIGEgbmV3IHZhbHVlLg0KPiA+ICA0LiBDUFUgbWF5
IGhpdCBhbiBleGNlcHRpb24gYmVjYXVzZSB0aGUgb2xkIHBtZCBlbnRyeSBpcyBzdGlsbCBpbiBU
TEIsDQo+ID4gICAgIHdoaWNoIGxlYWRzIHRvIGEga2VybmVsIHBhbmljLg0KPiA+IA0KPiA+IENv
bW1pdCBiNmJkYjc1MTdjM2QgKCJtbS92bWFsbG9jOiBhZGQgaW50ZXJmYWNlcyB0byBmcmVlIHVu
bWFwcGVkIHBhZ2UNCj4gPiB0YWJsZSIpIGhhcyBhZGRyZXNzZWQgdGhpcyBwYW5pYyBieSBmYWxs
aW5nIHRvIHB0ZSBtYXBwaW5ncyBpbiB0aGUgYWJvdmUNCj4gPiBjYXNlIG9uIEFSTTY0Lg0KPiA+
IA0KPiA+IFRvIHN1cHBvcnQgcG1kIG1hcHBpbmdzIGluIGFsbCBjYXNlcywgVExCIHB1cmdlIG5l
ZWRzIHRvIGJlIHBlcmZvcm1lZA0KPiA+IGluIHRoaXMgY2FzZSBvbiBBUk02NC4NCj4gPiANCj4g
PiBBZGQgYSBuZXcgYXJnLCAnYWRkcicsIHRvIHB1ZF9mcmVlX3BtZF9wYWdlKCkgYW5kIHBtZF9m
cmVlX3B0ZV9wYWdlKCkNCj4gPiBzbyB0aGF0IFRMQiBwdXJnZSBjYW4gYmUgYWRkZWQgbGF0ZXIg
aW4gc2VwcmF0ZSBwYXRjaGVzLg0KPiANCj4gU28gSSBhY2tlZCB2MTMgb2YgQ2hpbnRhbidzIHNl
cmllcyBwb3N0ZWQgaGVyZToNCj4gDQo+IGh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL3BpcGVy
bWFpbC9saW51eC1hcm0ta2VybmVsLzIwMTgtSnVuZS81ODI5NTMuaHRtbA0KPiANCj4gYW55IGNo
YW5jZSB0aGlzIGxvdCBjb3VsZCBhbGwgYmUgbWVyZ2VkIHRvZ2V0aGVyLCBwbGVhc2U/DQoNCkhp
IFdpbGwsDQoNCkNoaW50YW4ncyBwYXRjaCAyLzMgYW5kIDMvMyBhcHBseSBjbGVhbmx5IG9uIHRv
cCBvZiBteSBzZXJpZXMuIENhbiB5b3UNCnBsZWFzZSBjb29yZGluYXRlIHdpdGggVGhvbWFzIG9u
IHRoZSBsb2dpc3RpY3M/DQoNClRoYW5rcywNCi1Ub3NoaQ0K
