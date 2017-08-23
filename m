Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D457328038B
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:50:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f86so2388616pfj.5
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 07:50:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m2si1134307pge.838.2017.08.23.07.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 07:50:09 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Wed, 23 Aug 2017 14:49:31 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
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
In-Reply-To: <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo
 Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

PiBPbiBUdWUsIEF1ZyAyMiwgMjAxNyBhdCAxMjo1NSBQTSwgTGlhbmcsIEthbiA8a2FuLmxpYW5n
QGludGVsLmNvbT4gd3JvdGU6DQo+ID4NCj4gPj4gU28gSSBwcm9wb3NlIHRlc3RpbmcgdGhlIGF0
dGFjaGVkIHRyaXZpYWwgcGF0Y2guDQo+ID4NCj4gPiBJdCBkb2VzbuKAmXQgd29yay4NCj4gPiBU
aGUgY2FsbCBzdGFjayBpcyB0aGUgc2FtZS4NCj4gDQo+IFNvIEkgd291bGQgaGF2ZSBleHBlY3Rl
ZCB0aGUgc3RhY2sgdHJhY2UgdG8gYmUgdGhlIHNhbWUsIGFuZCBJIHdvdWxkIGV2ZW4NCj4gZXhw
ZWN0IHRoZSBDUFUgdXNhZ2UgdG8gYmUgZmFpcmx5IHNpbWlsYXIsIGJlY2F1c2UgeW91J2Qgc2Vl
IHJlcGVhdGluZyBmcm9tDQo+IHRoZSBjYWxsZXJzICh0YWtpbmcgdGhlIGZhdWx0IGFnYWluIGlm
IHRoZSBwYWdlIGlzIC0gb25jZSBhZ2FpbiAtIGJlaW5nIG1pZ3JhdGVkKS4NCj4gDQo+IEJ1dCBJ
IHdhcyBob3BpbmcgdGhhdCB0aGUgd2FpdCBxdWV1ZXMgd291bGQgYmUgc2hvcnRlciBiZWNhdXNl
IHRoZSBsb29wIGZvcg0KPiB0aGUgcmV0cnkgd291bGQgYmUgYmlnZ2VyLg0KPiANCj4gT2ggd2Vs
bC4NCj4gDQo+IEknbSBzbGlnaHRseSBvdXQgb2YgaWRlYXMuIEFwcGFyZW50bHkgdGhlIHlpZWxk
KCkgd29ya2VkIG9rIChhcGFydCBmcm9tIG5vdA0KPiBjYXRjaGluZyBhbGwgY2FzZXMpLCBhbmQg
bWF5YmUgd2UgY291bGQgZG8gYSB2ZXJzaW9uIHRoYXQgd2FpdHMgb24gdGhlIHBhZ2UNCj4gYml0
IGluIHRoZSBub24tY29udGVuZGVkIGNhc2UsIGJ1dCB5aWVsZHMgdW5kZXIgY29udGVudGlvbj8N
Cj4gDQo+IElPVywgbWF5YmUgdGhpcyBpcyB0aGUgYmVzdCB3ZSBjYW4gZG8gZm9yIG5vdz8gSW50
cm9kdWNpbmcgdGhhdA0KPiAid2FpdF9vbl9wYWdlX21pZ3JhdGlvbigpIiBoZWxwZXIgbWlnaHQg
YWxsb3cgdXMgdG8gdHdlYWsgdGhpcyBhIGJpdCBhcw0KPiBwZW9wbGUgY29tZSB1cCB3aXRoIGJl
dHRlciBpZGVhcy4uDQoNClRoZSAid2FpdF9vbl9wYWdlX21pZ3JhdGlvbigpIiBoZWxwZXIgd29y
a3Mgd2VsbCBpbiB0aGUgb3Zlcm5pZ2h0IHRlc3RpbmcuDQoNClRoYW5rcywNCkthbg0KDQo+IA0K
PiBBbmQgdGhlbiBhZGQgVGltJ3MgcGF0Y2ggZm9yIHRoZSBnZW5lcmFsIHdvcnN0LWNhc2UganVz
dCBpbiBjYXNlPw0KPiANCj4gICAgICAgICAgICAgIExpbnVzDQoNCg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
