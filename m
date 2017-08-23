Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC1B62803BE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:55:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a186so13670364pge.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 13:55:19 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i12si1594191pfi.42.2017.08.23.13.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 13:55:18 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Wed, 23 Aug 2017 20:55:15 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0775378EC56@shsmsx102.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
 <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
In-Reply-To: <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes
 Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

PiANCj4gT24gV2VkLCBBdWcgMjMsIDIwMTcgYXQgODo1OCBBTSwgVGltIENoZW4gPHRpbS5jLmNo
ZW5AbGludXguaW50ZWwuY29tPg0KPiB3cm90ZToNCj4gPg0KPiA+IFdpbGwgeW91IHN0aWxsIGNv
bnNpZGVyIHRoZSBvcmlnaW5hbCBwYXRjaCBhcyBhIGZhaWwgc2FmZSBtZWNoYW5pc20/DQo+IA0K
PiBJIGRvbid0IHRoaW5rIHdlIGhhdmUgbXVjaCBjaG9pY2UsIGFsdGhvdWdoIEkgd291bGQgKnJl
YWxseSogd2FudCB0byBnZXQgdGhpcw0KPiByb290LWNhdXNlZCByYXRoZXIgdGhhbiBqdXN0IHBh
cGVyaW5nIG92ZXIgdGhlIHN5bXB0b21zLg0KPiANCj4gTWF5YmUgc3RpbGwgd29ydGggdGVzdGlu
ZyB0aGF0ICJzY2hlZC9udW1hOiBTY2FsZSBzY2FuIHBlcmlvZCB3aXRoIHRhc2tzIGluDQo+IGdy
b3VwIGFuZCBzaGFyZWQvcHJpdmF0ZSIgcGF0Y2ggdGhhdCBNZWwgbWVudGlvbmVkLg0KDQpUaGUg
cGF0Y2ggZG9lc27igJl0IGhlbHAgb24gb3VyIGxvYWQuDQoNClRoYW5rcywNCkthbg0KPiANCj4g
SW4gZmFjdCwgbG9va2luZyBhdCB0aGF0IHBhdGNoIGRlc2NyaXB0aW9uLCBpdCBkb2VzIHNlZW0g
dG8gbWF0Y2ggdGhpcyBwYXJ0aWN1bGFyDQo+IGxvYWQgYSBsb3QuIFF1b3RpbmcgZnJvbSB0aGUg
Y29tbWl0IG1lc3NhZ2U6DQo+IA0KPiAgICJSdW5uaW5nIDgwIHRhc2tzIGluIHRoZSBzYW1lIGdy
b3VwLCBvciBhcyB0aHJlYWRzIG9mIHRoZSBzYW1lIHByb2Nlc3MsDQo+ICAgIHJlc3VsdHMgaW4g
dGhlIG1lbW9yeSBnZXR0aW5nIHNjYW5uZWQgODB4IGFzIGZhc3QgYXMgaXQgd291bGQgYmUgaWYg
YQ0KPiAgICBzaW5nbGUgdGFzayB3YXMgdXNpbmcgdGhlIG1lbW9yeS4NCj4gDQo+ICAgIFRoaXMg
cmVhbGx5IGh1cnRzIHNvbWUgd29ya2xvYWRzIg0KPiANCj4gU28gaWYgODAgdGhyZWFkcyBjYXVz
ZXMgODB4IGFzIG11Y2ggc2Nhbm5pbmcsIGEgZmV3IHRob3VzYW5kIHRocmVhZHMgbWlnaHQNCj4g
aW5kZWVkIGJlIHJlYWxseSByZWFsbHkgYmFkLg0KPiANCj4gU28gb25jZSBtb3JlIHVudG8gdGhl
IGJyZWFjaCwgZGVhciBmcmllbmRzLCBvbmNlIG1vcmUuDQo+IA0KPiBQbGVhc2UuDQo+IA0KPiBU
aGUgcGF0Y2ggZ290IGFwcGxpZWQgdG8gLXRpcCBhcyBjb21taXQgYjVkZDc3YzhiZGFkLCBhbmQg
Y2FuIGJlDQo+IGRvd25sb2FkZWQgaGVyZToNCj4gDQo+IA0KPiBodHRwczovL2dpdC5rZXJuZWwu
b3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90aXAvdGlwLmdpdC9jb21taXQvP2lkPWI1ZGQN
Cj4gNzdjOGJkYWRhN2I2MjYyZDBjYmEwMmE2ZWQ1MjViZjRlNmUxDQo+IA0KPiAoSG1tLiBJdCBz
YXlzIGl0J3MgY2MnZCB0byBtZSwgYnV0IEkgbmV2ZXIgbm90aWNlZCB0aGF0IHBhdGNoIHNpbXBs
eSBiZWNhdXNlIGl0DQo+IHdhcyBpbiBhIGJpZyBncm91cCBvZiBvdGhlciAtdGlwIGNvbW1pdHMu
LiBPaCB3ZWxsKS4NCj4gDQo+ICAgICAgICAgICBMaW51cw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
