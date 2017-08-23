Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDD9928038B
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:51:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r187so2344369pfr.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 07:51:17 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 9si1241913plc.674.2017.08.23.07.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 07:51:16 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Wed, 23 Aug 2017 14:51:13 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0775378A8BB@SHSMSX103.ccr.corp.intel.com>
References: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <20170822190828.GO32112@worktop.programming.kicks-ass.net>
 <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
 <20170822193714.GZ28715@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1708221605220.18344@nuc-kabylake>
 <20170822212408.GC28715@tassilo.jf.intel.com>
 <CA+55aFw_-RmdWF6mPHonnqoJcMEmjhvjzcwp5OU7Uwzk3KPNmw@mail.gmail.com>
In-Reply-To: <CA+55aFw_-RmdWF6mPHonnqoJcMEmjhvjzcwp5OU7Uwzk3KPNmw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8yXSBzY2hlZC93YWl0OiBCcmVhayB1cCBsb25nIHdh
a2UgbGlzdCB3YWxrDQo+IA0KPiBPbiBUdWUsIEF1ZyAyMiwgMjAxNyBhdCAyOjI0IFBNLCBBbmRp
IEtsZWVuIDxha0BsaW51eC5pbnRlbC5jb20+IHdyb3RlOg0KPiA+DQo+ID4gSSBiZWxpZXZlIGlu
IHRoaXMgY2FzZSBpdCdzIHVzZWQgYnkgdGhyZWFkcywgc28gYSByZWZlcmVuY2UgY291bnQNCj4g
PiBsaW1pdCB3b3VsZG4ndCBoZWxwLg0KPiANCj4gRm9yIHRoZSBmaXJzdCBtaWdyYXRpb24gdHJ5
LCB5ZXMuIEJ1dCBpZiBpdCdzIHNvbWUga2luZCBvZiAidHJ5IGFuZCB0cnkgYWdhaW4iDQo+IHBh
dHRlcm4sIHRoZSBzZWNvbmQgdGltZSB5b3UgdHJ5IGFuZCB0aGVyZSBhcmUgcGVvcGxlIHdhaXRp
bmcgZm9yIHRoZSBwYWdlLA0KPiB0aGUgcGFnZSBjb3VudCAobm90IHRoZSBtYXAgY291bnQpIHdv
dWxkIGJlIGVsZXZhbnRlZC4NCj4gDQo+IFNvIGl0J3MgcG9zc2libGUgdGhhdCBkZXBlbmRpbmcg
b24gZXhhY3RseSB3aGF0IHRoZSBkZWVwZXIgcHJvYmxlbSBpcywgdGhlDQo+ICJ0aGlzIHBhZ2Ug
aXMgdmVyeSBidXN5LCBkb24ndCBtaWdyYXRlIiBjYXNlIG1pZ2h0IGJlIGRpc2NvdmVyYWJsZSwg
YW5kIHRoZQ0KPiBwYWdlIGNvdW50IG1pZ2h0IGJlIHBhcnQgb2YgaXQuDQo+IA0KPiBIb3dldmVy
LCBhZnRlciBQZXRlclogbWFkZSB0aGF0IGNvbW1lbnQgdGhhdCBwYWdlIG1pZ3JhdGlvbiBzaG91
bGQgaGF2ZQ0KPiB0aGF0IHNob3VsZF9udW1hX21pZ3JhdGVfbWVtb3J5KCkgZmlsdGVyLCBJIGFt
IGxvb2tpbmcgYXQgdGhhdA0KPiBtcG9sX21pc3BsYWNlZCgpIGNvZGUuDQo+IA0KPiBBbmQgaG9u
ZXN0bHksIHRoYXQgTVBPTF9QUkVGRVJSRUQgLyBNUE9MX0ZfTE9DQUwgY2FzZSByZWFsbHkgbG9v
a3MgbGlrZQ0KPiBjb21wbGV0ZSBnYXJiYWdlIHRvIG1lLg0KPiANCj4gSXQgbG9va3MgbGlrZSBn
YXJiYWdlIGV4YWN0bHkgYmVjYXVzZSBpdCBzYXlzICJhbHdheXMgbWlncmF0ZSB0byB0aGUgY3Vy
cmVudA0KPiBub2RlIiwgYnV0IHRoYXQncyBjcmF6eSAtIGlmIGl0J3MgYSBncm91cCBvZiB0aHJl
YWRzIGFsbCBydW5uaW5nIHRvZ2V0aGVyIG9uIHRoZQ0KPiBzYW1lIFZNLCB0aGF0IG9idmlvdXNs
eSB3aWxsIGp1c3QgYm91bmNlIHRoZSBwYWdlIGFyb3VuZCBmb3IgYWJzb2x1dGUgemVybw0KPiBn
b29kIGV3YXNvbi4NCj4gDQo+IFRoZSAqb3RoZXIqIG1lbW9yeSBwb2xpY2llcyBsb29rIGZhaXJs
eSBzYW5lLiBUaGV5IGJhc2ljYWxseSBoYXZlIGEgZmFpcmx5DQo+IHdlbGwtZGVmaW5lZCBwcmVm
ZXJyZWQgbm9kZSBmb3IgdGhlIHBvbGljeSAoYWx0aG91Z2ggdGhlDQo+ICJNUE9MX0lOVEVSTEVB
VkUiIGxvb2tzIHdyb25nIGZvciBhIGh1Z2VwYWdlKS4gIEJ1dA0KPiBNUE9MX1BSRUZFUlJFRC9N
UE9MX0ZfTE9DQUwgcmVhbGx5IGxvb2tzIGNvbXBsZXRlbHkgYnJva2VuLg0KPiANCj4gTWF5YmUg
cGVvcGxlIGV4cGVjdGVkIHRoYXQgYW55Ym9keSB3aG8gdXNlcyBNUE9MX0ZfTE9DQUwgd2lsbCBh
bHNvDQo+IGJpbmQgYWxsIHRocmVhZHMgdG8gb25lIHNpbmdsZSBub2RlPw0KPiANCj4gQ291bGQg
d2UgcGVyaGFwcyBtYWtlIHRoYXQgIk1QT0xfUFJFRkVSUkVEIC8gTVBPTF9GX0xPQ0FMIiBjYXNl
IGp1c3QNCj4gZG8gdGhlIE1QT0xfRl9NT1JPTiBwb2xpY3ksIHdoaWNoICpkb2VzKiB1c2UgdGhh
dCAic2hvdWxkIEkgbWlncmF0ZSB0bw0KPiB0aGUgbG9jYWwgbm9kZSIgZmlsdGVyPw0KPiANCj4g
SU9XLCB3ZSd2ZSBiZWVuIGxvb2tpbmcgYXQgdGhlIHdhaXRlcnMgKGJlY2F1c2UgdGhlIHByb2Js
ZW0gc2hvd3MgdXAgZHVlDQo+IHRvIHRoZSBleGNlc3NpdmUgd2FpdCBxdWV1ZXMpLCBidXQgbWF5
YmUgdGhlIHNvdXJjZSBvZiB0aGUgcHJvYmxlbSBjb21lcw0KPiBmcm9tIHRoZSBudW1hIGJhbGFu
Y2luZyBjb2RlIGp1c3QgaW5zYW5lbHkgYm91bmNpbmcgcGFnZXMgYmFjay1hbmQtZm9ydGggaWYN
Cj4geW91IHVzZSB0aGF0ICJhbHdheXMgYmFsYW5jZSB0byBsb2NhbCBub2RlIiB0aGluZy4NCj4g
DQo+IFVudGVzdGVkIChhcyBhbHdheXMpIHBhdGNoIGF0dGFjaGVkLg0KDQpUaGUgcGF0Y2ggZG9l
c27igJl0IHdvcmsuDQoNClRoYW5rcywNCkthbg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
