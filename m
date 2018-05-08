Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1C36B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 20:55:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h9-v6so23045898qti.19
        for <linux-mm@kvack.org>; Mon, 07 May 2018 17:55:26 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.209])
        by mx.google.com with ESMTPS id a22-v6si3348008qte.202.2018.05.07.17.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 17:55:25 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem)
 zone
Date: Tue, 8 May 2018 00:54:59 +0000
Message-ID: <HK2PR03MB1684FC2E2FB3C59C913D0C97929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
In-Reply-To: <20180507184622.GB12361@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

DQo+IA0KPiBPbiBNb24sIE1heSAwNywgMjAxOCBhdCAxMDo1MDoyMVBNICswODAwLCBIdWFpc2hl
bmcgWWUgd3JvdGU6DQo+ID4gVHJhZGl0aW9uYWxseSwgTlZESU1NcyBhcmUgdHJlYXRlZCBieSBt
bShtZW1vcnkgbWFuYWdlbWVudCkNCj4gc3Vic3lzdGVtIGFzDQo+ID4gREVWSUNFIHpvbmUsIHdo
aWNoIGlzIGEgdmlydHVhbCB6b25lIGFuZCBib3RoIGl0cyBzdGFydCBhbmQgZW5kIG9mIHBmbg0K
PiA+IGFyZSBlcXVhbCB0byAwLCBtbSB3b3VsZG7igJl0IG1hbmFnZSBOVkRJTU0gZGlyZWN0bHkg
YXMgRFJBTSwga2VybmVsDQo+IHVzZXMNCj4gPiBjb3JyZXNwb25kaW5nIGRyaXZlcnMsIHdoaWNo
IGxvY2F0ZSBhdCBcZHJpdmVyc1xudmRpbW1cIGFuZA0KPiA+IFxkcml2ZXJzXGFjcGlcbmZpdCBh
bmQgZnMsIHRvIHJlYWxpemUgTlZESU1NIG1lbW9yeSBhbGxvYyBhbmQgZnJlZSB3aXRoDQo+ID4g
bWVtb3J5IGhvdCBwbHVnIGltcGxlbWVudGF0aW9uLg0KPiANCj4gWW91IHByb2JhYmx5IHdhbnQg
dG8gbGV0IGxpbnV4LW52ZGltbSBrbm93IGFib3V0IHRoaXMgcGF0Y2ggc2V0Lg0KPiBBZGRpbmcg
dG8gdGhlIGNjLiAgQWxzbywgSSBvbmx5IHJlY2VpdmVkIHBhdGNoIDAgYW5kIDQuICBXaGF0IGhh
cHBlbmVkDQo+IHRvIDEtMyw1IGFuZCA2Pw0KDQpTb3JyeSwgSXQgY291bGQgYmUgc29tZXRoaW5n
IHdyb25nIHdpdGggbXkgZ2l0LXNlbmRlbWFpbCwgYnV0IG15IG1haWxib3ggaGFzIHJlY2VpdmVk
IGFsbCBvZiB0aGVtLg0KQW55d2F5LCBJIHdpbGwgc2VuZCB0aGVtIGFnYWluIGFuZCBDQyBsaW51
eC1udmRpbW0uDQoNClRoYW5rcw0KSHVhaXNoZW5nDQo=
