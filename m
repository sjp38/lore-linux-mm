Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0C296900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:52:09 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2270301pdj.24
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:52:09 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id cl3si3220882pdb.68.2014.10.28.22.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 22:52:09 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 13:52:00 +0800
Subject: [RFC V5 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Rob Herring' <robherring2@gmail.com>, 'Joe Perches' <joe@perches.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

VGhpcyBwYXRjaCBhZGQgYml0cmV2LmggZmlsZSB0byBzdXBwb3J0IHJiaXQgaW5zdHJ1Y3Rpb24s
DQpzbyB0aGF0IHdlIGNhbiBkbyBiaXRyZXYgb3BlcmF0aW9uIGJ5IGhhcmR3YXJlLg0KU2lnbmVk
LW9mZi1ieTogWWFsaW4gV2FuZyA8eWFsaW4ud2FuZ0Bzb255bW9iaWxlLmNvbT4NCi0tLQ0KIGFy
Y2gvYXJtNjQvS2NvbmZpZyAgICAgICAgICAgICAgfCAgMSArDQogYXJjaC9hcm02NC9pbmNsdWRl
L2FzbS9iaXRyZXYuaCB8IDI4ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysNCiAyIGZpbGVz
IGNoYW5nZWQsIDI5IGluc2VydGlvbnMoKykNCiBjcmVhdGUgbW9kZSAxMDA2NDQgYXJjaC9hcm02
NC9pbmNsdWRlL2FzbS9iaXRyZXYuaA0KDQpkaWZmIC0tZ2l0IGEvYXJjaC9hcm02NC9LY29uZmln
IGIvYXJjaC9hcm02NC9LY29uZmlnDQppbmRleCA5NTMyZjhkLi5iMWVjMWRkIDEwMDY0NA0KLS0t
IGEvYXJjaC9hcm02NC9LY29uZmlnDQorKysgYi9hcmNoL2FybTY0L0tjb25maWcNCkBAIC0zNSw2
ICszNSw3IEBAIGNvbmZpZyBBUk02NA0KIAlzZWxlY3QgSEFORExFX0RPTUFJTl9JUlENCiAJc2Vs
ZWN0IEhBUkRJUlFTX1NXX1JFU0VORA0KIAlzZWxlY3QgSEFWRV9BUkNIX0FVRElUU1lTQ0FMTA0K
KwlzZWxlY3QgSEFWRV9BUkNIX0JJVFJFVkVSU0UNCiAJc2VsZWN0IEhBVkVfQVJDSF9KVU1QX0xB
QkVMDQogCXNlbGVjdCBIQVZFX0FSQ0hfS0dEQg0KIAlzZWxlY3QgSEFWRV9BUkNIX1RSQUNFSE9P
Sw0KZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvaW5jbHVkZS9hc20vYml0cmV2LmggYi9hcmNoL2Fy
bTY0L2luY2x1ZGUvYXNtL2JpdHJldi5oDQpuZXcgZmlsZSBtb2RlIDEwMDY0NA0KaW5kZXggMDAw
MDAwMC4uMjkyYTVkZQ0KLS0tIC9kZXYvbnVsbA0KKysrIGIvYXJjaC9hcm02NC9pbmNsdWRlL2Fz
bS9iaXRyZXYuaA0KQEAgLTAsMCArMSwyOCBAQA0KKyNpZm5kZWYgX19BU01fQVJNNjRfQklUUkVW
X0gNCisjZGVmaW5lIF9fQVNNX0FSTTY0X0JJVFJFVl9IDQorDQorc3RhdGljIF9fYWx3YXlzX2lu
bGluZSBfX2F0dHJpYnV0ZV9jb25zdF9fIHUzMiBfX2FyY2hfYml0cmV2MzIodTMyIHgpDQorew0K
KwlpZiAoX19idWlsdGluX2NvbnN0YW50X3AoeCkpIHsNCisJCXggPSAoeCA+PiAxNikgfCAoeCA8
PCAxNik7DQorCQl4ID0gKCh4ICYgMHhGRjAwRkYwMCkgPj4gOCkgfCAoKHggJiAweDAwRkYwMEZG
KSA8PCA4KTsNCisJCXggPSAoKHggJiAweEYwRjBGMEYwKSA+PiA0KSB8ICgoeCAmIDB4MEYwRjBG
MEYpIDw8IDQpOw0KKwkJeCA9ICgoeCAmIDB4Q0NDQ0NDQ0MpID4+IDIpIHwgKCh4ICYgMHgzMzMz
MzMzMykgPDwgMik7DQorCQlyZXR1cm4gKCh4ICYgMHhBQUFBQUFBQSkgPj4gMSkgfCAoKHggJiAw
eDU1NTU1NTU1KSA8PCAxKTsNCisJfQ0KKwlfX2FzbV9fICgicmJpdCAldzAsICV3MSIgOiAiPXIi
ICh4KSA6ICJyIiAoeCkpOw0KKwlyZXR1cm4geDsNCit9DQorDQorc3RhdGljIF9fYWx3YXlzX2lu
bGluZSBfX2F0dHJpYnV0ZV9jb25zdF9fIHUxNiBfX2FyY2hfYml0cmV2MTYodTE2IHgpDQorew0K
KwlyZXR1cm4gX19hcmNoX2JpdHJldjMyKCh1MzIpeCkgPj4gMTY7DQorfQ0KKw0KK3N0YXRpYyBf
X2Fsd2F5c19pbmxpbmUgX19hdHRyaWJ1dGVfY29uc3RfXyB1OCBfX2FyY2hfYml0cmV2OCh1OCB4
KQ0KK3sNCisJcmV0dXJuIF9fYXJjaF9iaXRyZXYzMigodTMyKXgpID4+IDI0Ow0KK30NCisNCisj
ZW5kaWYNCisNCi0tIA0KMi4xLjENCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
