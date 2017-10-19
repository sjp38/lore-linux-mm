Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A71F6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:02:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b6so4303673pff.18
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:02:26 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j6si4329840pfg.379.2017.10.19.02.02.24
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 02:02:25 -0700 (PDT)
From: 
	=?ks_c_5601-1987?B?udq6tMO2L7yxwNO/rLG4v/gvU1cgUGxhdGZvcm0ov6wpQU9UxsAo?=
 =?ks_c_5601-1987?B?Ynl1bmdjaHVsLnBhcmtAbGdlLmNvbSk=?=
	<byungchul.park@lge.com>
Date: Thu, 19 Oct 2017 18:02:21 +0900
Subject: RE: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and
 make it not unwind as default
Message-ID: <F6531D8286A0B34FBC858F176F707962027B9228C9@LGEVEXMBHQSVC1.LGE.NET>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
 <20171019055730.mlpoz333ekflacs2@gmail.com>
 <20171019061112.GB3310@X58A-UD3R> <20171019062255.GC3310@X58A-UD3R>
 <20171019081053.2mmzzjgfwgtv5lz3@gmail.com>
In-Reply-To: <20171019081053.2mmzzjgfwgtv5lz3@gmail.com>
Content-Language: ko-KR
Content-Type: text/plain; charset="ks_c_5601-1987"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Byungchul Park <byungchul.park@lge.com>
Cc: "peterz@infradead.org" <peterz@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJbmdvIE1vbG5hciBbbWFpbHRv
Om1pbmdvLmtlcm5lbC5vcmdAZ21haWwuY29tXSBPbiBCZWhhbGYgT2YgSW5nbw0KPiANCj4gPiBB
dCB0aGUgdGltZSwgY3Jvc3MtcmVsZWFzZSB3YXMgZmFsc2VseSBhY2N1c2VkLiBBRkFJSywgY3Jv
c3MtcmVsZWFzZSBoYXMNCj4gPiBub3QgY3Jhc2hlZCBzeXN0ZW0geWV0Lg0KPiANCj4gSSdtIHRh
bGtpbmcgYWJvdXQgdGhlIGNyYXNoIGZpeGVkIGhlcmU6DQo+IA0KPiAgIDhiNDA1ZDVjNWQwOTog
bG9ja2luZy9sb2NrZGVwOiBGaXggc3RhY2t0cmFjZSBtZXNzDQo+IA0KPiBXaGljaCB3YXMgaW50
cm9kdWNlZCBieSB5b3VyIHBhdGNoOg0KPiANCj4gICBjZTA3YTk0MTVmMjY6IGxvY2tpbmcvbG9j
a2RlcDogTWFrZSBjaGVja19wcmV2X2FkZCgpIGFibGUgdG8gaGFuZGxlDQo+IGV4dGVybmFsIHN0
YWNrX3RyYWNlDQo+IA0KPiAuLi4gd2hpY2ggd2FzIGEgcHJlcGFyYXRvcnkgcGF0Y2ggZm9yIGNy
b3NzLXJlbGVhc2UuIFNvICd0ZWNobmljYWxseScgaXQncyBub3QgYQ0KPiBjcm9zcy1yZWxlYXNl
IGNyYXNoLCBidXQgd2FzIHZlcnkgbXVjaCByZWxhdGVkLiBJdCBldmVuIHNheXMgc28gaW4gdGhl
IGNoYW5nZWxvZzoNCj4gDQo+ICAgQWN0dWFsbHkgY3Jvc3NyZWxlYXNlIG5lZWRzIHRvIGRvIG90
aGVyIHRoYW4gc2F2aW5nIGEgc3RhY2tfdHJhY2UuDQo+ICAgU28gcGFzcyBhIHN0YWNrX3RyYWNl
IGFuZCBjYWxsYmFjayB0byBoYW5kbGUgaXQsIHRvIGNoZWNrX3ByZXZfYWRkKCkuDQo+IA0KPiAu
Li4gc28gbGV0J3Mgbm90IHByZXRlbmQgaXQgd2Fzbid0IHJlbGF0ZWQsIG9rPw0KDQpJIGRvbid0
IHdhbnQgdG8gcHJldGVuZCBJJ20gcGVyZmVjdC4gT2YgY291cnNlLCBJIGNhbiBtYWtlIG1pc3Rh
a2VzLg0KSSdtIGp1c3Qgc2F5aW5nIHRoYXQgKkkgaGF2ZSBub3Qgc2VlbiogYW55IGNyYXNoIGJ5
IGNyb3NzLXJlbGVhc2UuDQoNCkluIHRoYXQgY2FzZSB5b3UgcG9pbnRlZCBvdXQsIGxpa2V3aXNl
LCB0aGUgY3Jhc2ggd2FzIGNhdXNlZCBieSBhZTgxMzMwOGY6DQpsb2NrZGVwOiBBdm9pZCBjcmVh
dGluZyByZWR1bmRhbnQgbGlua3MsIHdoaWNoIGlzIG5vdCByZWxhdGVkIHRvIHRoZSBmZWF0dXJl
DQphY3R1YWxseS4gSXQgd2FzIGFsc28gZmFsc2VseSBhY2N1c2VkIGF0IHRoZSB0aW1lIGFnYWlu
Li4uDQoNCk9mIGNvdXJzZSwgaXQncyBteSBmYXVsdCBub3QgdG8gaGF2ZSBtYWRlIHRoZSBkZXNp
Z24gbW9yZSByb2J1c3Qgc28gdGhhdA0Kb3RoZXJzIGNhbiBtb2RpZnkgbG9ja2RlcCBjb2RlIGNh
cmluZyBsZXNzIGFmdGVyIGNyb3NzLXJlbGVhc2UgY29tbWl0Lg0KVGhhdCdzIHdoYXQgSSdtIHNv
cnJ5IGZvci4NCg0KSSBhbHJlYWR5IG1lbnRpb25lZCB0aGUgYWJvdmUgaW4gdGhlIHRocmVhZCB0
YWxraW5nIGFib3V0IHRoZSBpc3N1ZSB5b3UNCmFyZSBwb2ludGluZyBub3cuIE9mIGNvdXJzZSwg
SSBiYXNpY2FsbHkgYXBwcmVjaWF0ZSBhbGwgY29tbWVudHMgYW5kDQpzdWdnZXN0aW9ucyB5b3Ug
aGF2ZSBnaXZlbiwgYnV0IHlvdSBzZWVtIHRvIGhhdmUgbWlzLXVuZGVyc3Rvb2Qgc29tZQ0KaXNz
dWVzIHdydCBjcm9zcy1yZWxlYXNlIGZlYXR1cmUuDQoNClRoYW5rcywNCkJ5dW5nY2h1bA0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
