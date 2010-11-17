Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 772C96B00EC
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:28:26 -0500 (EST)
From: Johan MOSSBERG <johan.xx.mossberg@stericsson.com>
Date: Wed, 17 Nov 2010 10:28:13 +0100
Subject: RE: [PATCH 0/3] hwmem: Hardware memory driver
Message-ID: <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73D53@EXDCVYMBSTM005.EQ1STM.local>
References: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <op.vl9p52wp7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE739A0@EXDCVYMBSTM005.EQ1STM.local>
 <op.vl9r6xld7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73A1D@EXDCVYMBSTM005.EQ1STM.local>
 <op.vl9xudve7p4s8u@pikus>
In-Reply-To: <op.vl9xudve7p4s8u@pikus>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

TWljaGHFgiBOYXphcmV3aWN6IHdyb3RlOiANCj4gRG8geW91IHdhbnQgdG8gcmVtYXAgdXNlciBz
cGFjZSBtYXBwaW5ncyB3aGVuIHBhZ2UgaXMgbW92ZWQgZHVyaW5nDQo+IGRlZnJhZ21lbnRhdGlv
bj8gT3Igd291bGQgdXNlciBuZWVkIHRvIHVubWFwIHRoZSByZWdpb24/ICBJZS4gd291bGQNCj4g
bW1hcCgpZWQgYnVmZmVyIGJlIHBpbm5lZD8NCg0KUmVtYXAsIGkuZS4gbm90IHBpbm5lZC4gVGhh
dCBtZWFucyB0aGF0IHRoZSBtYXBwZXIgbmVlZHMgdG8gYmUNCmluZm9ybWVkIGJlZm9yZSBhbmQg
YWZ0ZXIgYSBidWZmZXIgaXMgbW92ZWQuIE1heWJlIGFkZCBhIGZ1bmN0aW9uDQp0byBDTUEgd2hl
cmUgeW91IGNhbiByZWdpc3RlciBhIGNhbGxiYWNrIGZ1bmN0aW9uIHRoYXQgaXMgY2FsbGVkDQpi
ZWZvcmUgYW5kIGFmdGVyIGEgYnVmZmVyIGlzIG1vdmVkPyBUaGUgY2FsbGJhY2sgZnVuY3Rpb24n
cw0KcGFyYW1ldGVycyB3b3VsZCBiZSBidWZmZXIsIG5ldyBwb3NpdGlvbiBhbmQgd2hldGhlciBp
dCB3aWxsIGJlDQptb3ZlZCBvciBoYXMgYmVlbiBtb3ZlZC4gQ01BIHdvdWxkIGFsc28gbmVlZCB0
aGlzIHR5cGUgb2YNCmluZm9ybWF0aW9uIHRvIGJlIGFibGUgdG8gZXZpY3QgdGVtcG9yYXJ5IGRh
dGEgZnJvbSB0aGUNCmRlc3RpbmF0aW9uLg0KDQpJJ20gYSBsaXR0bGUgYml0IHdvcnJpZWQgdGhh
dCB0aGlzIGFwcHJvYWNoIHB1dCBjb25zdHJhaW50cyBvbiB0aGUNCmRlZnJhZ21lbnRhdGlvbiBh
bGdvcml0aG0gYnV0IEkgY2FuJ3QgdGhpbmsgb2YgYW55IHNjZW5hcmlvIHdoZXJlDQp3ZSB3b3Vs
ZCBydW4gaW50byBwcm9ibGVtcy4gSWYgYSBkZWZyYWdtZW50YXRpb24gYWxnb3JpdGhtIGRvZXMN
CnRlbXBvcmFyeSBtb3ZlcywgYW5kIGtub3dzIGl0IGF0IHRoZSB0aW1lIG9mIHRoZSBtb3ZlLCB3
ZSB3b3VsZA0KaGF2ZSB0byBhZGQgYSBmbGFnIHRvIHRoZSBjYWxsYmFjayB0aGF0IGluZGljYXRl
cyB0aGF0IHRoZSBtb3ZlIGlzDQp0ZW1wb3Jhcnkgc28gdGhhdCBpdCBpcyBub3QgdW5uZWNlc3Nh
cmlseSBtYXBwZWQsIGJ1dCB0aGF0IGNhbiBiZQ0KZG9uZSB3aGVuL2lmIHRoZSBwcm9ibGVtIG9j
Y3Vycy4gVGVtcG9yYXJpbHkgbW92aW5nIGEgYnVmZmVyIHRvDQpzY2F0dGVyZWQgbWVtb3J5IGlz
IG5vdCBzdXBwb3J0ZWQgZWl0aGVyIGJ1dCBJIHN1cHBvc2UgdGhhdCBjYW4gYmUNCnNvbHZlZCBi
eSBhZGRpbmcgYSBmbGFnIHRoYXQgaW5kaWNhdGVzIHRoYXQgdGhlIG5ldyBwb3NpdGlvbiBpcw0K
c2NhdHRlcmVkLCBhbHNvIHNvbWV0aGluZyB0aGF0IGNhbiBiZSBkb25lIHdoZW4gbmVlZGVkLg0K
DQovSm9oYW4gTW9zc2JlcmcNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
