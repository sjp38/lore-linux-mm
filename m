Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 04A846B0005
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 21:36:55 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id g8so60117848igr.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 18:36:54 -0700 (PDT)
Received: from smtpbgau1.qq.com (smtpbgau1.qq.com. [54.206.16.166])
        by mx.google.com with ESMTPS id 25si14685779ioj.47.2016.04.10.18.36.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 18:36:54 -0700 (PDT)
From: "=?ISO-8859-1?B?TWluZyBMaQ==?=" <mingli199x@qq.com>
Subject: [PATCH] mm: put activate_page_pvecs and others pagevec together 
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: base64
Date: Mon, 11 Apr 2016 09:36:46 +0800
Message-ID: <tencent_5CF8AA8413F8563C681F8DC9@qq.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?B?QW5kcmV3IE1vcnRvbg==?= <akpm@linux-foundation.org>, =?ISO-8859-1?B?TWljaGFsIEhvY2tv?= <mhocko@suse.com>, =?ISO-8859-1?B?S2lyaWxsIEEuIFNodXRlbW92?= <kirill.shutemov@linux.intel.com>, =?ISO-8859-1?B?RGF2aWQgUmllbnRqZXM=?= <rientjes@google.com>, =?ISO-8859-1?B?Vmxhc3RpbWlsIEJhYmth?= <Babkavbabka@suse.cz>, =?ISO-8859-1?B?VGVqdW4gSGVv?= <tj@kernel.org>
Cc: =?ISO-8859-1?B?bGludXgtbW0=?= <linux-mm@kvack.org>, =?ISO-8859-1?B?bGludXgta2VybmVs?= <linux-kernel@vger.kernel.org>

aGksIGlgbSBzb3JyeSwgSSBtYWRlIHNvbWUgbWlzdGFrZXMgaW4gbGFzdCBlbWFpbC4gSSBo
YXZlIGJlZW4gc3R1ZHlpbmcgbW0gYW5kIGxlYXJuIGFnZV9hY3RpdmF0ZV9hbm9uKCksIGF0
IHRoZSB2ZXJ5IGJlZ2lubmluZyBJIGZlbHQgY29uZnVzZSB3aGVuIEkgc2F3IGFjdGl2YXRl
X3BhZ2VfcHZlY3MsIGFmdGVyIEkgbGVhcm5lZCB0aGUgd2hvbGUgdGhpbmcgSSB1bmRlcnN0
b29kIHRoYXQgaXQncyBzaW1pbGFyIHdpdGggb3RoZXIgcGFnZXZlYydzIGZ1bmN0aW9uLiBD
YW4gd2UgcHV0IGl0IHdpdGggb3RoZXIgcGFnZXZlYyB0b2dldGhlcj8gSSB0aGluayBpdCBp
cyBlYXNpZXIgZm9yIG5ld2JpZXMgdG8gcmVhZCBhbmQgdW5kZXJzdGFuZC4KCnJlZ2FyZHMs
CgoKClNpZ25lZC1vZmYtYnk6IE1pbmcgTGkgPG1pbmdsaTE5OXhAcXEuY29tPgoKLS0tCm1t
L3N3YXAuYyB8IDUgKysrLS0KMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMiBk
ZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9zd2FwLmMgYi9tbS9zd2FwLmMKaW5kZXgg
MDlmZTVlOS4uNWM5OTAxYyAxMDA2NDQKLS0tIGEvbW0vc3dhcC5jCisrKyBiL21tL3N3YXAu
YwpAQCAtNDcsNiArNDcsOSBAQCBzdGF0aWMgREVGSU5FX1BFUl9DUFUoc3RydWN0IHBhZ2V2
ZWMsIGxydV9hZGRfcHZlYyk7CnN0YXRpYyBERUZJTkVfUEVSX0NQVShzdHJ1Y3QgcGFnZXZl
YywgbHJ1X3JvdGF0ZV9wdmVjcyk7CnN0YXRpYyBERUZJTkVfUEVSX0NQVShzdHJ1Y3QgcGFn
ZXZlYywgbHJ1X2RlYWN0aXZhdGVfZmlsZV9wdmVjcyk7CnN0YXRpYyBERUZJTkVfUEVSX0NQ
VShzdHJ1Y3QgcGFnZXZlYywgbHJ1X2RlYWN0aXZhdGVfcHZlY3MpOworI2lmZGVmIENPTkZJ
R19TTVAKK3N0YXRpYyBERUZJTkVfUEVSX0NQVShzdHJ1Y3QgcGFnZXZlYywgYWN0aXZhdGVf
cGFnZV9wdmVjcyk7CisjZW5kaWYKCi8qCiogVGhpcyBwYXRoIGFsbW9zdCBuZXZlciBoYXBw
ZW5zIGZvciBWTSBhY3Rpdml0eSAtIHBhZ2VzIGFyZSBub3JtYWxseQpAQCAtMjc0LDggKzI3
Nyw2IEBAIHN0YXRpYyB2b2lkIF9fYWN0aXZhdGVfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSwg
c3RydWN0IGxydXZlYyAqbHJ1dmVjLAp9CgojaWZkZWYgQ09ORklHX1NNUAotc3RhdGljIERF
RklORV9QRVJfQ1BVKHN0cnVjdCBwYWdldmVjLCBhY3RpdmF0ZV9wYWdlX3B2ZWNzKTsKLQpz
dGF0aWMgdm9pZCBhY3RpdmF0ZV9wYWdlX2RyYWluKGludCBjcHUpCnsKc3RydWN0IHBhZ2V2
ZWMgKnB2ZWMgPSAmcGVyX2NwdShhY3RpdmF0ZV9wYWdlX3B2ZWNzLCBjcHUpOwotLSAKMS44
LjMuMQ==



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
