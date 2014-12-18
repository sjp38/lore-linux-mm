Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0D16B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 22:50:16 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so504260pdb.32
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:50:15 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id i4si8092816pdh.240.2014.12.17.19.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 19:50:14 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Thu, 18 Dec 2014 11:50:01 +0800
Subject: [RFC] MADV_FREE doesn't work when doesn't have swap partition
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
	<20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
	<35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
	<20141208114601.GA28846@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'minchan@kernel.org'" <minchan@kernel.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'Kirill A. Shutemov'" <kirill@shutemov.name>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>

SSBub3RpY2UgdGhpcyBjb21taXQ6DQptbTogc3VwcG9ydCBtYWR2aXNlKE1BRFZfRlJFRSksDQoN
Cml0IGNhbiBmcmVlIGNsZWFuIGFub255bW91cyBwYWdlcyBkaXJlY3RseSwNCmRvZXNuJ3QgbmVl
ZCBwYWdlb3V0IHRvIHN3YXAgcGFydGl0aW9uLA0KDQpidXQgSSBmb3VuZCBpdCBkb2Vzbid0IHdv
cmsgb24gbXkgcGxhdGZvcm0sDQp3aGljaCBkb24ndCBlbmFibGUgYW55IHN3YXAgcGFydGl0aW9u
cy4NCg0KSSBtYWtlIGEgY2hhbmdlIGZvciB0aGlzLg0KSnVzdCB0byBleHBsYWluIG15IGlzc3Vl
IGNsZWFybHksDQpEbyB3ZSBuZWVkIHNvbWUgb3RoZXIgY2hlY2tzIHRvIHN0aWxsIHNjYW4gYW5v
bnltb3VzIHBhZ2VzIGV2ZW4NCkRvbid0IGhhdmUgc3dhcCBwYXJ0aXRpb24gYnV0IGhhdmUgY2xl
YW4gYW5vbnltb3VzIHBhZ2VzPw0KLS0tDQpkaWZmIC0tZ2l0IGEvbW0vdm1zY2FuLmMgYi9tbS92
bXNjYW4uYw0KaW5kZXggNWU4NzcyYi4uODI1OGYzYSAxMDA2NDQNCi0tLSBhL21tL3Ztc2Nhbi5j
DQorKysgYi9tbS92bXNjYW4uYw0KQEAgLTE5NDEsNyArMTk0MSw3IEBAIHN0YXRpYyB2b2lkIGdl
dF9zY2FuX2NvdW50KHN0cnVjdCBscnV2ZWMgKmxydXZlYywgaW50IHN3YXBwaW5lc3MsDQogICAg
ICAgICAgICAgICAgZm9yY2Vfc2NhbiA9IHRydWU7DQoNCiAgICAgICAgLyogSWYgd2UgaGF2ZSBu
byBzd2FwIHNwYWNlLCBkbyBub3QgYm90aGVyIHNjYW5uaW5nIGFub24gcGFnZXMuICovDQotICAg
ICAgIGlmICghc2MtPm1heV9zd2FwIHx8IChnZXRfbnJfc3dhcF9wYWdlcygpIDw9IDApKSB7DQor
ICAgICAgIGlmICghc2MtPm1heV9zd2FwKSB7DQogICAgICAgICAgICAgICAgc2Nhbl9iYWxhbmNl
ID0gU0NBTl9GSUxFOw0KICAgICAgICAgICAgICAgIGdvdG8gb3V0Ow0KICAgICAgICB9DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
