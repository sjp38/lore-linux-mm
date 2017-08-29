Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5C2F6B0292
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:57:10 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t193so6148829pgc.4
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 05:57:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b11si2499788pll.648.2017.08.29.05.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 05:57:09 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
Date: Tue, 29 Aug 2017 12:57:06 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077537A1C19@SHSMSX103.ccr.corp.intel.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com>
 <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A07E9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
In-Reply-To: <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo
 Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

PiBPbiBNb24sIEF1ZyAyOCwgMjAxNyBhdCA3OjUxIEFNLCBMaWFuZywgS2FuIDxrYW4ubGlhbmdA
aW50ZWwuY29tPiB3cm90ZToNCj4gPg0KPiA+IEkgdHJpZWQgdGhpcyBwYXRjaCBhbmQgaHR0cHM6
Ly9sa21sLm9yZy9sa21sLzIwMTcvOC8yNy8yMjIgdG9nZXRoZXIuDQo+ID4gQnV0IHRoZXkgZG9u
J3QgZml4IHRoZSBpc3N1ZS4gSSBjYW4gc3RpbGwgZ2V0IHRoZSBzaW1pbGFyIGNhbGwgc3RhY2su
DQo+IA0KPiBTbyB0aGUgbWFpbiBpc3N1ZSB3YXMgdGhhdCBJICpyZWFsbHkqIGhhdGVkIFRpbSdz
IHBhdGNoICMyLCBhbmQgdGhlIHBhdGNoIHRvDQo+IGNsZWFuIHVwIHRoZSBwYWdlIHdhaXQgcXVl
dWUgc2hvdWxkIG5vdyBtYWtlIGhpcyBwYXRjaCBzZXJpZXMgbXVjaCBtb3JlDQo+IHBhbGF0YWJs
ZS4NCj4gDQo+IEF0dGFjaGVkIGlzIGFuIEFMTU9TVCBDT01QTEVURUxZIFVOVEVTVEVEIGZvcndh
cmQtcG9ydCBvZiB0aG9zZSB0d28NCj4gcGF0Y2hlcywgbm93IHdpdGhvdXQgdGhhdCBuYXN0eSBX
UV9GTEFHX0FSUklWQUxTIGxvZ2ljLCBiZWNhdXNlIHdlIG5vdw0KPiBhbHdheXMgcHV0IHRoZSBu
ZXcgZW50cmllcyBhdCB0aGUgZW5kIG9mIHRoZSB3YWl0cXVldWUuDQo+IA0KDQpUaGUgcGF0Y2hl
cyBmaXggdGhlIGxvbmcgd2FpdCBpc3N1ZS4NCg0KVGVzdGVkLWJ5OiBLYW4gTGlhbmcgPGthbi5s
aWFuZ0BpbnRlbC5jb20+DQoNCj4gVGhlIGF0dGFjaGVkIHBhdGNoZXMganVzdCBhcHBseSBkaXJl
Y3RseSBvbiB0b3Agb2YgcGxhaW4gNC4xMy1yYzcuDQo+IA0KPiBUaGF0IG1ha2VzIHBhdGNoICMy
IG11Y2ggbW9yZSBwYWxhdGFibGUsIHNpbmNlIGl0IG5vdyBkb2Vzbid0IG5lZWQgdG8gcGxheQ0K
PiBnYW1lcyBhbmQgd29ycnkgYWJvdXQgbmV3IGFycml2YWxzLg0KPiANCj4gQnV0IG5vdGUgdGhl
IGxhY2sgb2YgdGVzdGluZy4gSSd2ZSBhY3R1YWxseSBib290ZWQgdGhpcyBhbmQgYW0gcnVubmlu
ZyB0aGVzZQ0KPiB0d28gcGF0Y2hlcyByaWdodCBub3csIGJ1dCBob25lc3RseSwgeW91IHNob3Vs
ZCBjb25zaWRlciB0aGVtICJ1bnRlc3RlZCINCj4gc2ltcGx5IGJlY2F1c2UgSSBjYW4ndCB0cmln
Z2VyIHRoZSBwYWdlIHdhaXRlcnMgY29udGVudGlvbiBjYXNlIHRvIGJlZ2luIHdpdGguDQo+IA0K
PiBCdXQgaXQncyByZWFsbHkganVzdCBUaW0ncyBwYXRjaGVzLCBtb2RpZmllZCBmb3IgdGhlIHBh
Z2Ugd2FpdHF1ZXVlIGNsZWFudXANCj4gd2hpY2ggbWFrZXMgcGF0Y2ggIzIgYmVjb21lIG11Y2gg
c2ltcGxlciwgYW5kIG5vdyBpdCdzDQo+IHBhbGF0YWJsZTogaXQncyBqdXN0IHVzaW5nIHRoZSBz
YW1lIGJvb2ttYXJrIHRoaW5nIHRoYXQgdGhlIG5vcm1hbCB3YWtldXANCj4gdXNlcywgbm8gZXh0
cmEgaGFja3MuDQo+IA0KPiBTbyBUaW0gc2hvdWxkIGxvb2sgdGhlc2Ugb3ZlciwgYW5kIHRoZXkg
c2hvdWxkIGRlZmluaXRlbHkgYmUgdGVzdGVkIG9uIHRoYXQNCj4gbG9hZC1mcm9tLWhlbGwgdGhh
dCB5b3UgZ3V5cyBoYXZlLCBidXQgaWYgdGhpcyBzZXQgd29ya3MsIGF0IGxlYXN0IEknbSBvayB3
aXRoIGl0DQo+IG5vdy4NCj4gDQo+IFRpbSAtIGRpZCBJIG1pc3MgYW55dGhpbmc/IEkgYWRkZWQg
YSAiY3B1X3JlbGF4KCkiIGluIHRoZXJlIGJldHdlZW4gdGhlDQo+IHJlbGVhc2UgbG9jayBhbmQg
aXJxIGFuZCByZS10YWtlIGl0LCBJJ20gbm90IGNvbnZpbmNlZCBpdCBtYWtlcyBhbnkgZGlmZmVy
ZW5jZSwNCj4gYnV0IEkgd2FudGVkIHRvIG1hcmsgdGhhdCAidGFrZSBhIGJyZWF0aGVyIiB0aGlu
Zy4NCj4gDQo+IE9oLCB0aGVyZSdzIG9uZSBtb3JlIGNhc2UgSSBvbmx5IHJlYWxpemVkIGFmdGVy
IHRoZSBwYXRjaGVzOiB0aGUgc3R1cGlkDQo+IGFkZF9wYWdlX3dhaXRfcXVldWUoKSBjb2RlIHN0
aWxsIGFkZHMgdG8gdGhlIGhlYWQgb2YgdGhlIGxpc3QuDQo+IFNvIHRlY2huaWNhbGx5IHlvdSBu
ZWVkIHRoaXMgdG9vOg0KPiANCj4gICAgIGRpZmYgLS1naXQgYS9tbS9maWxlbWFwLmMgYi9tbS9m
aWxlbWFwLmMNCj4gICAgIGluZGV4IDc0MTIzYTI5OGY1My4uNTk4YzNiZTU3NTA5IDEwMDY0NA0K
PiAgICAgLS0tIGEvbW0vZmlsZW1hcC5jDQo+ICAgICArKysgYi9tbS9maWxlbWFwLmMNCj4gICAg
IEBAIC0xMDYxLDcgKzEwNjEsNyBAQCB2b2lkIGFkZF9wYWdlX3dhaXRfcXVldWUoc3RydWN0IHBh
Z2UgKnBhZ2UsDQo+IHdhaXRfcXVldWVfZW50cnlfdCAqd2FpdGVyKQ0KPiAgICAgICAgIHVuc2ln
bmVkIGxvbmcgZmxhZ3M7DQo+IA0KPiAgICAgICAgIHNwaW5fbG9ja19pcnFzYXZlKCZxLT5sb2Nr
LCBmbGFncyk7DQo+ICAgICAtICAgX19hZGRfd2FpdF9xdWV1ZShxLCB3YWl0ZXIpOw0KPiAgICAg
KyAgIF9fYWRkX3dhaXRfcXVldWVfZW50cnlfdGFpbChxLCB3YWl0ZXIpOw0KPiAgICAgICAgIFNl
dFBhZ2VXYWl0ZXJzKHBhZ2UpOw0KPiAgICAgICAgIHNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJnEt
PmxvY2ssIGZsYWdzKTsNCj4gICAgICB9DQo+IA0KPiBidXQgdGhhdCBvbmx5IG1hdHRlcnMgaWYg
eW91IGFjdHVhbGx5IHVzZSB0aGUgY2FjaGVmaWxlcyB0aGluZywgd2hpY2ggSQ0KPiBob3BlL2Fz
c3VtZSB5b3UgZG9uJ3QuDQo+IA0KPiAgICAgICAgTGludXMNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
