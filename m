Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50CED6B032C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 00:48:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id s201-v6so8144627ita.1
        for <linux-mm@kvack.org>; Tue, 08 May 2018 21:48:14 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.7])
        by mx.google.com with ESMTPS id q4-v6si23369441ioe.237.2018.05.08.21.48.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 21:48:13 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem)
 zone
Date: Wed, 9 May 2018 04:47:54 +0000
Message-ID: <HK2PR03MB16841CBB549F40F86BB8D35C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
 <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
 <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com>
 <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180508030959.GB16338@bombadil.infradead.org>
In-Reply-To: <20180508030959.GB16338@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, NingTing Cheng <chengnt@lenovo.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, Linux MM <linux-mm@kvack.org>, "colyli@suse.de" <colyli@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@verizon.com>, Mel
 Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

DQo+IA0KPiBPbiBUdWUsIE1heSAwOCwgMjAxOCBhdCAwMjo1OTo0MEFNICswMDAwLCBIdWFpc2hl
bmcgSFMxIFllIHdyb3RlOg0KPiA+IEN1cnJlbnRseSBpbiBvdXIgbWluZCwgYW4gaWRlYWwgdXNl
IHNjZW5hcmlvIGlzIHRoYXQsIHdlIHB1dCBhbGwgcGFnZSBjYWNoZXMgdG8NCj4gPiB6b25lX252
bSwgd2l0aG91dCBhbnkgZG91YnQsIHBhZ2UgY2FjaGUgaXMgYW4gZWZmaWNpZW50IGFuZCBjb21t
b24gY2FjaGUNCj4gPiBpbXBsZW1lbnQsIGJ1dCBpdCBoYXMgYSBkaXNhZHZhbnRhZ2UgdGhhdCBh
bGwgZGlydHkgZGF0YSB3aXRoaW4gaXQgd291bGQgaGFzIHJpc2sNCj4gPiB0byBiZSBtaXNzZWQg
YnkgcG93ZXIgZmFpbHVyZSBvciBzeXN0ZW0gY3Jhc2guIElmIHdlIHB1dCBhbGwgcGFnZSBjYWNo
ZXMgdG8gTlZESU1NcywNCj4gPiBhbGwgZGlydHkgZGF0YSB3aWxsIGJlIHNhZmUuDQo+IA0KPiBU
aGF0J3MgYSBjb21tb24gbWlzY29uY2VwdGlvbi4gIFNvbWUgZGlydHkgZGF0YSB3aWxsIHN0aWxs
IGJlIGluIHRoZQ0KPiBDUFUgY2FjaGVzLiAgQXJlIHlvdSBwbGFubmluZyBvbiBidWlsZGluZyBz
ZXJ2ZXJzIHdoaWNoIGhhdmUgZW5vdWdoDQo+IGNhcGFjaXRhbmNlIHRvIGFsbG93IHRoZSBDUFUg
dG8gZmx1c2ggYWxsIGRpcnR5IGRhdGEgZnJvbSBMTEMgdG8gTlYtRElNTT8NCj4gDQpTb3JyeSBm
b3Igbm90IGJlaW5nIGNsZWFyLg0KRm9yIENQVSBjYWNoZXMgaWYgdGhlcmUgaXMgYSBwb3dlciBm
YWlsdXJlLCBOVkRJTU0gaGFzIEFEUiB0byBndWFyYW50ZWUgYW4gaW50ZXJydXB0IHdpbGwgYmUg
cmVwb3J0ZWQgdG8gQ1BVLCBhbiBpbnRlcnJ1cHQgcmVzcG9uc2UgZnVuY3Rpb24gc2hvdWxkIGJl
IHJlc3BvbnNpYmxlIHRvIGZsdXNoIGFsbCBkaXJ0eSBkYXRhIHRvIE5WRElNTS4NCklmIHRoZXJl
IGlzIGEgc3lzdGVtIGNydXNoLCBwZXJoYXBzIENQVSBjb3VsZG4ndCBoYXZlIGNoYW5jZSB0byBl
eGVjdXRlIHRoaXMgcmVzcG9uc2UuDQoNCkl0IGlzIGhhcmQgdG8gbWFrZSBzdXJlIGV2ZXJ5dGhp
bmcgaXMgc2FmZSwgd2hhdCB3ZSBjYW4gZG8gaXMganVzdCB0byBzYXZlIHRoZSBkaXJ0eSBkYXRh
IHdoaWNoIGlzIGFscmVhZHkgc3RvcmVkIHRvIFBhZ2VjYWNoZSwgYnV0IG5vdCBpbiBDUFUgY2Fj
aGUuDQpJcyB0aGlzIGFuIGltcHJvdmVtZW50IHRoYW4gY3VycmVudD8NCg0KPiBUaGVuIHRoZXJl
J3MgdGhlIHByb2JsZW0gb2YgcmVjb25uZWN0aW5nIHRoZSBwYWdlIGNhY2hlICh3aGljaCBpcw0K
PiBwb2ludGVkIHRvIGJ5IGVwaGVtZXJhbCBkYXRhIHN0cnVjdHVyZXMgbGlrZSBpbm9kZXMgYW5k
IGRlbnRyaWVzKSB0bw0KPiB0aGUgbmV3IGlub2Rlcy4NClllcywgaXQgaXMgbm90IGVhc3kuDQoN
Cj4gDQo+IEFuZCB0aGVuIHlvdSBoYXZlIHRvIGNvbnZpbmNlIGN1c3RvbWVycyB0aGF0IHdoYXQg
eW91J3JlIGRvaW5nIGlzIHNhZmUNCj4gZW5vdWdoIGZvciB0aGVtIHRvIHRydXN0IGl0IDstKQ0K
U3VyZS4g8J+Yig0KDQpTaW5jZXJlbHksDQpIdWFpc2hlbmcgWWUNCg==
