Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C7A5A6B006E
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 06:57:26 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so12987462pdi.16
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 03:57:26 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id g8si41719893pdf.6.2014.12.26.03.57.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 03:57:25 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 26 Dec 2014 19:56:49 +0800
Subject: [RFC] mm:change meminfo cached calculation
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E160@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
	<20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
	<35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
	<20141208114601.GA28846@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'minchan@kernel.org'" <minchan@kernel.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'Kirill A. Shutemov'" <kirill@shutemov.name>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>, "'pintu.k@samsung.com'" <pintu.k@samsung.com>

VGhpcyBwYXRjaCBzdWJ0cmFjdCBzaGFyZWRyYW0gZnJvbSBjYWNoZWQsDQpzaGFyZWRyYW0gY2Fu
IG9ubHkgYmUgc3dhcCBpbnRvIHN3YXAgcGFydGl0aW9ucywNCnRoZXkgc2hvdWxkIGJlIHRyZWF0
ZWQgYXMgc3dhcCBwYWdlcywgbm90IGFzIGNhY2hlZCBwYWdlcy4NCg0KU2lnbmVkLW9mZi1ieTog
WWFsaW4gV2FuZyA8eWFsaW4ud2FuZ0Bzb255bW9iaWxlLmNvbT4NCi0tLQ0KIGZzL3Byb2MvbWVt
aW5mby5jIHwgMiArLQ0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlv
bigtKQ0KDQpkaWZmIC0tZ2l0IGEvZnMvcHJvYy9tZW1pbmZvLmMgYi9mcy9wcm9jL21lbWluZm8u
Yw0KaW5kZXggZDNlYmYyZS4uMmI1OThhNiAxMDA2NDQNCi0tLSBhL2ZzL3Byb2MvbWVtaW5mby5j
DQorKysgYi9mcy9wcm9jL21lbWluZm8uYw0KQEAgLTQ1LDcgKzQ1LDcgQEAgc3RhdGljIGludCBt
ZW1pbmZvX3Byb2Nfc2hvdyhzdHJ1Y3Qgc2VxX2ZpbGUgKm0sIHZvaWQgKnYpDQogCWNvbW1pdHRl
ZCA9IHBlcmNwdV9jb3VudGVyX3JlYWRfcG9zaXRpdmUoJnZtX2NvbW1pdHRlZF9hcyk7DQogDQog
CWNhY2hlZCA9IGdsb2JhbF9wYWdlX3N0YXRlKE5SX0ZJTEVfUEFHRVMpIC0NCi0JCQl0b3RhbF9z
d2FwY2FjaGVfcGFnZXMoKSAtIGkuYnVmZmVycmFtOw0KKwkJCXRvdGFsX3N3YXBjYWNoZV9wYWdl
cygpIC0gaS5idWZmZXJyYW0gLSBpLnNoYXJlZHJhbTsNCiAJaWYgKGNhY2hlZCA8IDApDQogCQlj
YWNoZWQgPSAwOw0KIA0KLS0gDQoyLjEuMw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
