Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4416B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:10:31 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so5670460pab.18
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:10:31 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id bz4si20939983pbb.26.2014.09.14.23.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 23:10:30 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 14:10:19 +0800
Subject: RE: [RFC V2] Free the reserved memblock when free cma pages
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB4915FF@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <20140915052151.GI2160@bbox>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FD@CNBJMBX05.corpusers.net>
 <20140915054236.GJ2160@bbox>
In-Reply-To: <20140915054236.GJ2160@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

VGhpcyBwYXRjaCBhZGQgbWVtYmxvY2tfZnJlZSB0byBhbHNvIGZyZWUgdGhlIHJlc2VydmVkIG1l
bWJsb2NrLA0Kc28gdGhhdCB0aGUgY21hIHBhZ2VzIGFyZSBub3QgbWFya2VkIGFzIHJlc2VydmVk
IG1lbW9yeSBpbg0KL3N5cy9rZXJuZWwvZGVidWcvbWVtYmxvY2svcmVzZXJ2ZWQgZGVidWcgZmls
ZQ0KDQpTaWduZWQtb2ZmLWJ5OiBZYWxpbiBXYW5nIDx5YWxpbi53YW5nQHNvbnltb2JpbGUuY29t
Pg0KLS0tDQogbW0vY21hLmMgICAgICAgIHwgNiArKysrKy0NCiBtbS9wYWdlX2FsbG9jLmMgfCAy
ICstDQogMiBmaWxlcyBjaGFuZ2VkLCA2IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQoN
CmRpZmYgLS1naXQgYS9tbS9jbWEuYyBiL21tL2NtYS5jDQppbmRleCBjMTc3NTFjLi5lYzY5YzY5
IDEwMDY0NA0KLS0tIGEvbW0vY21hLmMNCisrKyBiL21tL2NtYS5jDQpAQCAtMTk2LDcgKzE5Niwx
MSBAQCBpbnQgX19pbml0IGNtYV9kZWNsYXJlX2NvbnRpZ3VvdXMocGh5c19hZGRyX3QgYmFzZSwN
CiAJaWYgKCFJU19BTElHTkVEKHNpemUgPj4gUEFHRV9TSElGVCwgMSA8PCBvcmRlcl9wZXJfYml0
KSkNCiAJCXJldHVybiAtRUlOVkFMOw0KIA0KLQkvKiBSZXNlcnZlIG1lbW9yeSAqLw0KKwkvKg0K
KwkgKiBSZXNlcnZlIG1lbW9yeSwgYW5kIHRoZSByZXNlcnZlZCBtZW1vcnkgYXJlIG1hcmtlZCBh
cyByZXNlcnZlZCBieQ0KKwkgKiBtZW1ibG9jayBkcml2ZXIsIHJlbWVtYmVyIHRvIGNsZWFyIHRo
ZSByZXNlcnZlZCBzdGF0dXMgd2hlbiBmcmVlDQorCSAqIHRoZXNlIGNtYSBwYWdlcywgc2VlIGlu
aXRfY21hX3Jlc2VydmVkX3BhZ2VibG9jaygpDQorCSAqLw0KIAlpZiAoYmFzZSAmJiBmaXhlZCkg
ew0KIAkJaWYgKG1lbWJsb2NrX2lzX3JlZ2lvbl9yZXNlcnZlZChiYXNlLCBzaXplKSB8fA0KIAkJ
ICAgIG1lbWJsb2NrX3Jlc2VydmUoYmFzZSwgc2l6ZSkgPCAwKSB7DQpkaWZmIC0tZ2l0IGEvbW0v
cGFnZV9hbGxvYy5jIGIvbW0vcGFnZV9hbGxvYy5jDQppbmRleCAxOGNlZTBkLi5mZmZiYjg0IDEw
MDY0NA0KLS0tIGEvbW0vcGFnZV9hbGxvYy5jDQorKysgYi9tbS9wYWdlX2FsbG9jLmMNCkBAIC04
MzYsOCArODM2LDggQEAgdm9pZCBfX2luaXQgaW5pdF9jbWFfcmVzZXJ2ZWRfcGFnZWJsb2NrKHN0
cnVjdCBwYWdlICpwYWdlKQ0KIAkJc2V0X3BhZ2VfcmVmY291bnRlZChwYWdlKTsNCiAJCV9fZnJl
ZV9wYWdlcyhwYWdlLCBwYWdlYmxvY2tfb3JkZXIpOw0KIAl9DQotDQogCWFkanVzdF9tYW5hZ2Vk
X3BhZ2VfY291bnQocGFnZSwgcGFnZWJsb2NrX25yX3BhZ2VzKTsNCisJbWVtYmxvY2tfZnJlZShw
YWdlX3RvX3BoeXMocGFnZSksIHBhZ2VibG9ja19ucl9wYWdlcyA8PCBQQUdFX1NISUZUKTsNCiB9
DQogI2VuZGlmDQogDQotLSANCjIuMS4wDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
