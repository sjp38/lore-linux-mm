Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C33D2900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:50:43 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so2443999pad.31
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:50:43 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id v5si3085172pdj.234.2014.10.28.22.50.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 22:50:42 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 13:50:35 +0800
Subject: [RFC V5 1/3] add CONFIG_HAVE_ARCH_BITREVERSE to support rbit
  instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Rob Herring' <robherring2@gmail.com>, 'Joe Perches' <joe@perches.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

dGhpcyBjaGFuZ2UgYWRkIENPTkZJR19IQVZFX0FSQ0hfQklUUkVWRVJTRSBjb25maWcgb3B0aW9u
LA0Kc28gdGhhdCB3ZSBjYW4gdXNlIGFybS9hcm02NCByYml0IGluc3RydWN0aW9uIHRvIGRvIGJp
dHJldiBvcGVyYXRpb24NCmJ5IGhhcmR3YXJlLg0KDQpDaGFuZ2UgYml0cmV2MTYoKSBiaXRyZXYz
MigpIHRvIGJlIGlubGluZSBmdW5jdGlvbiwNCmRvbid0IG5lZWQgZXhwb3J0IHN5bWJvbCBmb3Ig
dGhlc2UgdGlueSBmdW5jdGlvbnMuDQoNClNpZ25lZC1vZmYtYnk6IFlhbGluIFdhbmcgPHlhbGlu
LndhbmdAc29ueW1vYmlsZS5jb20+DQotLS0NCiBpbmNsdWRlL2xpbnV4L2JpdHJldi5oIHwgMjEg
KysrKysrKysrKysrKysrKysrLS0tDQogbGliL0tjb25maWcgICAgICAgICAgICB8ICA5ICsrKysr
KysrKw0KIGxpYi9iaXRyZXYuYyAgICAgICAgICAgfCAxNyArKy0tLS0tLS0tLS0tLS0tLQ0KIDMg
ZmlsZXMgY2hhbmdlZCwgMjkgaW5zZXJ0aW9ucygrKSwgMTggZGVsZXRpb25zKC0pDQoNCmRpZmYg
LS1naXQgYS9pbmNsdWRlL2xpbnV4L2JpdHJldi5oIGIvaW5jbHVkZS9saW51eC9iaXRyZXYuaA0K
aW5kZXggN2ZmZTAzZi4uNDEzYzUyYyAxMDA2NDQNCi0tLSBhL2luY2x1ZGUvbGludXgvYml0cmV2
LmgNCisrKyBiL2luY2x1ZGUvbGludXgvYml0cmV2LmgNCkBAIC0zLDE0ICszLDI5IEBADQogDQog
I2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+DQogDQotZXh0ZXJuIHU4IGNvbnN0IGJ5dGVfcmV2X3Rh
YmxlWzI1Nl07DQorI2lmZGVmIENPTkZJR19IQVZFX0FSQ0hfQklUUkVWRVJTRQ0KKyNpbmNsdWRl
IDxhc20vYml0cmV2Lmg+DQorDQorI2RlZmluZSBiaXRyZXYzMiBfX2FyY2hfYml0cmV2MzINCisj
ZGVmaW5lIGJpdHJldjE2IF9fYXJjaF9iaXRyZXYxNg0KKyNkZWZpbmUgYml0cmV2OCBfX2FyY2hf
Yml0cmV2OA0KIA0KKyNlbHNlDQorZXh0ZXJuIHU4IGNvbnN0IGJ5dGVfcmV2X3RhYmxlWzI1Nl07
DQogc3RhdGljIGlubGluZSB1OCBiaXRyZXY4KHU4IGJ5dGUpDQogew0KIAlyZXR1cm4gYnl0ZV9y
ZXZfdGFibGVbYnl0ZV07DQogfQ0KIA0KLWV4dGVybiB1MTYgYml0cmV2MTYodTE2IGluKTsNCi1l
eHRlcm4gdTMyIGJpdHJldjMyKHUzMiBpbik7DQorc3RhdGljIGlubGluZSB1MTYgYml0cmV2MTYo
dTE2IHgpDQorew0KKwlyZXR1cm4gKGJpdHJldjgoeCAmIDB4ZmYpIDw8IDgpIHwgYml0cmV2OCh4
ID4+IDgpOw0KK30NCisNCitzdGF0aWMgaW5saW5lIHUzMiBiaXRyZXYzMih1MzIgeCkNCit7DQor
CXJldHVybiAoYml0cmV2MTYoeCAmIDB4ZmZmZikgPDwgMTYpIHwgYml0cmV2MTYoeCA+PiAxNik7
DQorfQ0KIA0KKyNlbmRpZiAvKiBDT05GSUdfSEFWRV9BUkNIX0JJVFJFVkVSU0UgKi8NCiAjZW5k
aWYgLyogX0xJTlVYX0JJVFJFVl9IICovDQpkaWZmIC0tZ2l0IGEvbGliL0tjb25maWcgYi9saWIv
S2NvbmZpZw0KaW5kZXggNTRjZjMwOS4uY2QxNzdjYSAxMDA2NDQNCi0tLSBhL2xpYi9LY29uZmln
DQorKysgYi9saWIvS2NvbmZpZw0KQEAgLTEzLDYgKzEzLDE1IEBAIGNvbmZpZyBSQUlENl9QUQ0K
IGNvbmZpZyBCSVRSRVZFUlNFDQogCXRyaXN0YXRlDQogDQorY29uZmlnIEhBVkVfQVJDSF9CSVRS
RVZFUlNFDQorCWJvb2xlYW4NCisJZGVmYXVsdCBuDQorCWRlcGVuZHMgb24gQklUUkVWRVJTRQ0K
KwloZWxwDQorCSAgVGhpcyBvcHRpb24gcHJvdmlkZXMgYW4gY29uZmlnIGZvciB0aGUgYXJjaGl0
ZWN0dXJlIHdoaWNoIGhhdmUgaW5zdHJ1Y3Rpb24NCisJICBjYW4gZG8gYml0cmV2ZXJzZSBvcGVy
YXRpb24sIHdlIHVzZSB0aGUgaGFyZHdhcmUgaW5zdHJ1Y3Rpb24gaWYgdGhlIGFyY2hpdGVjdHVy
ZQ0KKwkgIGhhdmUgdGhpcyBjYXBhYmlsaXR5Lg0KKw0KIGNvbmZpZyBSQVRJT05BTA0KIAlib29s
ZWFuDQogDQpkaWZmIC0tZ2l0IGEvbGliL2JpdHJldi5jIGIvbGliL2JpdHJldi5jDQppbmRleCAz
OTU2MjAzLi40MGZmZGE5IDEwMDY0NA0KLS0tIGEvbGliL2JpdHJldi5jDQorKysgYi9saWIvYml0
cmV2LmMNCkBAIC0xLDMgKzEsNCBAQA0KKyNpZm5kZWYgQ09ORklHX0hBVkVfQVJDSF9CSVRSRVZF
UlNFDQogI2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+DQogI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5o
Pg0KICNpbmNsdWRlIDxsaW51eC9iaXRyZXYuaD4NCkBAIC00MiwxOCArNDMsNCBAQCBjb25zdCB1
OCBieXRlX3Jldl90YWJsZVsyNTZdID0gew0KIH07DQogRVhQT1JUX1NZTUJPTF9HUEwoYnl0ZV9y
ZXZfdGFibGUpOw0KIA0KLXUxNiBiaXRyZXYxNih1MTYgeCkNCi17DQotCXJldHVybiAoYml0cmV2
OCh4ICYgMHhmZikgPDwgOCkgfCBiaXRyZXY4KHggPj4gOCk7DQotfQ0KLUVYUE9SVF9TWU1CT0wo
Yml0cmV2MTYpOw0KLQ0KLS8qKg0KLSAqIGJpdHJldjMyIC0gcmV2ZXJzZSB0aGUgb3JkZXIgb2Yg
Yml0cyBpbiBhIHUzMiB2YWx1ZQ0KLSAqIEB4OiB2YWx1ZSB0byBiZSBiaXQtcmV2ZXJzZWQNCi0g
Ki8NCi11MzIgYml0cmV2MzIodTMyIHgpDQotew0KLQlyZXR1cm4gKGJpdHJldjE2KHggJiAweGZm
ZmYpIDw8IDE2KSB8IGJpdHJldjE2KHggPj4gMTYpOw0KLX0NCi1FWFBPUlRfU1lNQk9MKGJpdHJl
djMyKTsNCisjZW5kaWYgLyogQ09ORklHX0hBVkVfQVJDSF9CSVRSRVZFUlNFICovDQotLSANCjIu
MS4xDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
