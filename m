Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 832376B0005
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 21:16:40 -0400 (EDT)
Received: by mail-oi0-f51.google.com with SMTP id p188so190740840oih.2
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 18:16:40 -0700 (PDT)
Received: from smtpbg65.qq.com (smtpbg65.qq.com. [103.7.28.233])
        by mx.google.com with ESMTPS id f8si6110314obh.105.2016.04.10.18.16.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 18:16:39 -0700 (PDT)
From: "=?ISO-8859-1?B?TWluZyBMaQ==?=" <mingli199x@qq.com>
Subject: [PATCH] mm: put activate_page_pvecs and others pagevec together 
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: base64
Date: Mon, 11 Apr 2016 09:16:29 +0800
Message-ID: <tencent_396EED8911B375260606A8A3@qq.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?B?QW5kcmV3IE1vcnRvbg==?= <akpm@linux-foundation.org>, =?ISO-8859-1?B?TWljaGFsIEhvY2tv?= <mhocko@suse.com>, =?ISO-8859-1?B?S2lyaWxsIEEuIFNodXRlbW92?= <kirill.shutemov@linux.intel.com>, =?ISO-8859-1?B?RGF2aWQgUmllbnRqZXM=?= <rientjes@google.com>, =?ISO-8859-1?B?Vmxhc3RpbWlsIEJhYmth?= <Babkavbabka@suse.cz>, =?ISO-8859-1?B?VGVqdW4gSGVv?= <tj@kernel.org>
Cc: =?ISO-8859-1?B?bGludXgtbW0=?= <linux-mm@kvack.org>, =?ISO-8859-1?B?bGludXgta2VybmVs?= <linux-kernel@vger.kernel.org>

aGksIEkgaGF2ZSBiZWVuIHN0dWR5aW5nIG1tIGFuZCBsZWFybiBhZ2V4eHgsIGF0IHRoZSB2
ZXJ5IGJlZ2lubmluZyBJIGZlbHQgY29uZnVzZSB3aGVuIEkgc2F3IGFjdGl2YXRleHh4LCBh
ZnRlciBJIGxlYXJuZWQgdGhlIHdob2xlIHRoaW5nIEkgdW5kZXJzdG9vZCB0aGF0IGl0J3Mg
c2ltaWxhciB3aXRoIG90aGVyIHBhZ2V2ZWMncyBmdW5jdGlvbi4gQ2FuIHdlIHB1dCBpdCB3
aXRoIG90aGVyIHBhZ2V2ZWMgdG9nZXRoZXI/IEkgdGhpbmsgaXQgaXMgZWFzaWVyIGZvciBu
ZXdiaWVzIHRvIHJlYWQgYW5kIHVuZGVyc3RhbmQuCgpyZWdhcmRzLAoKCgpTaWduZWQtb2Zm
LWJ5OiBNaW5nIExpIDxtaW5nbGkxOTl4QHFxLmNvbT4KCi0tLQptbS9zd2FwLmMgfCA1ICsr
Ky0tCjEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbW0vc3dhcC5jIGIvbW0vc3dhcC5jCmluZGV4IDA5ZmU1ZTkuLjVjOTkw
MWMgMTAwNjQ0Ci0tLSBhL21tL3N3YXAuYworKysgYi9tbS9zd2FwLmMKQEAgLTQ3LDYgKzQ3
LDkgQEAgc3RhdGljIERFRklORV9QRVJfQ1BVKHN0cnVjdCBwYWdldmVjLCBscnVfYWRkX3B2
ZWMpOwpzdGF0aWMgREVGSU5FX1BFUl9DUFUoc3RydWN0IHBhZ2V2ZWMsIGxydV9yb3RhdGVf
cHZlY3MpOwpzdGF0aWMgREVGSU5FX1BFUl9DUFUoc3RydWN0IHBhZ2V2ZWMsIGxydV9kZWFj
dGl2YXRlX2ZpbGVfcHZlY3MpOwpzdGF0aWMgREVGSU5FX1BFUl9DUFUoc3RydWN0IHBhZ2V2
ZWMsIGxydV9kZWFjdGl2YXRlX3B2ZWNzKTsKKyNpZmRlZiBDT05GSUdfU01QCitzdGF0aWMg
REVGSU5FX1BFUl9DUFUoc3RydWN0IHBhZ2V2ZWMsIGFjdGl2YXRlX3BhZ2VfcHZlY3MpOwor
I2VuZGlmCgovKgoqIFRoaXMgcGF0aCBhbG1vc3QgbmV2ZXIgaGFwcGVucyBmb3IgVk0gYWN0
aXZpdHkgLSBwYWdlcyBhcmUgbm9ybWFsbHkKQEAgLTI3NCw4ICsyNzcsNiBAQCBzdGF0aWMg
dm9pZCBfX2FjdGl2YXRlX3BhZ2Uoc3RydWN0IHBhZ2UgKnBhZ2UsIHN0cnVjdCBscnV2ZWMg
KmxydXZlYywKfQoKI2lmZGVmIENPTkZJR19TTVAKLXN0YXRpYyBERUZJTkVfUEVSX0NQVShz
dHJ1Y3QgcGFnZXZlYywgYWN0aXZhdGVfcGFnZV9wdmVjcyk7Ci0Kc3RhdGljIHZvaWQgYWN0
aXZhdGVfcGFnZV9kcmFpbihpbnQgY3B1KQp7CnN0cnVjdCBwYWdldmVjICpwdmVjID0gJnBl
cl9jcHUoYWN0aXZhdGVfcGFnZV9wdmVjcywgY3B1KTsKLS0gCjEuOC4zLjE=



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
