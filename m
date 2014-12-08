Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E014D6B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:58:27 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so494550pdj.13
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:58:27 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id xi4si59122112pbc.86.2014.12.08.01.58.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 01:58:26 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 8 Dec 2014 17:58:14 +0800
Subject: [PATCH V2] mm:add VM_BUG_ON() for page_mapcount()
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313F9@CNBJMBX05.corpusers.net>
References: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
In-Reply-To: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hillf Danton' <hillf.zj@alibaba-inc.com>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>

VGhpcyBwYXRjaCBhZGQgVk1fQlVHX09OX1BBR0UoKSBmb3Igc2xhYiBwYWdlLA0KYmVjYXVzZSBf
bWFwY291bnQgaXMgYW4gdW5pb24gd2l0aCBzbGFiIHN0cnVjdCBpbiBzdHJ1Y3QgcGFnZSwNCmF2
b2lkIGFjY2VzcyBfbWFwY291bnQgaWYgdGhpcyBwYWdlIGlzIGEgc2xhYiBwYWdlLg0KQWxzbyBy
ZW1vdmUgdGhlIHVubmVlZGVkIGJyYWNrZXQuDQoNClNpZ25lZC1vZmYtYnk6IFlhbGluIFdhbmcg
PHlhbGluLndhbmdAc29ueW1vYmlsZS5jb20+DQotLS0NCiBpbmNsdWRlL2xpbnV4L21tLmggfCAz
ICsrLQ0KIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCg0K
ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaA0KaW5k
ZXggYjQ2NDYxMS4uYTExNzUyNyAxMDA2NDQNCi0tLSBhL2luY2x1ZGUvbGludXgvbW0uaA0KKysr
IGIvaW5jbHVkZS9saW51eC9tbS5oDQpAQCAtNDQ5LDcgKzQ0OSw4IEBAIHN0YXRpYyBpbmxpbmUg
dm9pZCBwYWdlX21hcGNvdW50X3Jlc2V0KHN0cnVjdCBwYWdlICpwYWdlKQ0KIA0KIHN0YXRpYyBp
bmxpbmUgaW50IHBhZ2VfbWFwY291bnQoc3RydWN0IHBhZ2UgKnBhZ2UpDQogew0KLQlyZXR1cm4g
YXRvbWljX3JlYWQoJihwYWdlKS0+X21hcGNvdW50KSArIDE7DQorCVZNX0JVR19PTl9QQUdFKFBh
Z2VTbGFiKHBhZ2UpLCBwYWdlKTsNCisJcmV0dXJuIGF0b21pY19yZWFkKCZwYWdlLT5fbWFwY291
bnQpICsgMTsNCiB9DQogDQogc3RhdGljIGlubGluZSBpbnQgcGFnZV9jb3VudChzdHJ1Y3QgcGFn
ZSAqcGFnZSkNCi0tIA0KMi4xLjMNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
