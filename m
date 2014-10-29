Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3115D900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:51:30 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so2445272pad.31
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:51:29 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id q7si3168129pdo.134.2014.10.28.22.51.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 22:51:29 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 13:51:17 +0800
Subject: [RFC V5 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
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
Y2gvYXJtL0tjb25maWcgICAgICAgICAgICAgIHwgIDEgKw0KIGFyY2gvYXJtL2luY2x1ZGUvYXNt
L2JpdHJldi5oIHwgMjggKysrKysrKysrKysrKysrKysrKysrKysrKysrKw0KIDIgZmlsZXMgY2hh
bmdlZCwgMjkgaW5zZXJ0aW9ucygrKQ0KIGNyZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL2FybS9pbmNs
dWRlL2FzbS9iaXRyZXYuaA0KDQpkaWZmIC0tZ2l0IGEvYXJjaC9hcm0vS2NvbmZpZyBiL2FyY2gv
YXJtL0tjb25maWcNCmluZGV4IDg5YzRiNWMuLmJlOTJiM2IgMTAwNjQ0DQotLS0gYS9hcmNoL2Fy
bS9LY29uZmlnDQorKysgYi9hcmNoL2FybS9LY29uZmlnDQpAQCAtMjgsNiArMjgsNyBAQCBjb25m
aWcgQVJNDQogCXNlbGVjdCBIQU5ETEVfRE9NQUlOX0lSUQ0KIAlzZWxlY3QgSEFSRElSUVNfU1df
UkVTRU5EDQogCXNlbGVjdCBIQVZFX0FSQ0hfQVVESVRTWVNDQUxMIGlmIChBRUFCSSAmJiAhT0FC
SV9DT01QQVQpDQorCXNlbGVjdCBIQVZFX0FSQ0hfQklUUkVWRVJTRSBpZiAoQ1BVX1Y3TSB8fCBD
UFVfVjcpDQogCXNlbGVjdCBIQVZFX0FSQ0hfSlVNUF9MQUJFTCBpZiAhWElQX0tFUk5FTA0KIAlz
ZWxlY3QgSEFWRV9BUkNIX0tHREINCiAJc2VsZWN0IEhBVkVfQVJDSF9TRUNDT01QX0ZJTFRFUiBp
ZiAoQUVBQkkgJiYgIU9BQklfQ09NUEFUKQ0KZGlmZiAtLWdpdCBhL2FyY2gvYXJtL2luY2x1ZGUv
YXNtL2JpdHJldi5oIGIvYXJjaC9hcm0vaW5jbHVkZS9hc20vYml0cmV2LmgNCm5ldyBmaWxlIG1v
ZGUgMTAwNjQ0DQppbmRleCAwMDAwMDAwLi5jMjFhNWY0DQotLS0gL2Rldi9udWxsDQorKysgYi9h
cmNoL2FybS9pbmNsdWRlL2FzbS9iaXRyZXYuaA0KQEAgLTAsMCArMSwyOCBAQA0KKyNpZm5kZWYg
X19BU01fQVJNX0JJVFJFVl9IDQorI2RlZmluZSBfX0FTTV9BUk1fQklUUkVWX0gNCisNCitzdGF0
aWMgX19hbHdheXNfaW5saW5lIF9fYXR0cmlidXRlX2NvbnN0X18gdTMyIF9fYXJjaF9iaXRyZXYz
Mih1MzIgeCkNCit7DQorCWlmIChfX2J1aWx0aW5fY29uc3RhbnRfcCh4KSkgew0KKwkJeCA9ICh4
ID4+IDE2KSB8ICh4IDw8IDE2KTsNCisJCXggPSAoKHggJiAweEZGMDBGRjAwKSA+PiA4KSB8ICgo
eCAmIDB4MDBGRjAwRkYpIDw8IDgpOw0KKwkJeCA9ICgoeCAmIDB4RjBGMEYwRjApID4+IDQpIHwg
KCh4ICYgMHgwRjBGMEYwRikgPDwgNCk7DQorCQl4ID0gKCh4ICYgMHhDQ0NDQ0NDQykgPj4gMikg
fCAoKHggJiAweDMzMzMzMzMzKSA8PCAyKTsNCisJCXJldHVybiAoKHggJiAweEFBQUFBQUFBKSA+
PiAxKSB8ICgoeCAmIDB4NTU1NTU1NTUpIDw8IDEpOw0KKwl9DQorCV9fYXNtX18gKCJyYml0ICUw
LCAlMSIgOiAiPXIiICh4KSA6ICJyIiAoeCkpOw0KKwlyZXR1cm4geDsNCit9DQorDQorc3RhdGlj
IF9fYWx3YXlzX2lubGluZSBfX2F0dHJpYnV0ZV9jb25zdF9fIHUxNiBfX2FyY2hfYml0cmV2MTYo
dTE2IHgpDQorew0KKwlyZXR1cm4gX19hcmNoX2JpdHJldjMyKCh1MzIpeCkgPj4gMTY7DQorfQ0K
Kw0KK3N0YXRpYyBfX2Fsd2F5c19pbmxpbmUgX19hdHRyaWJ1dGVfY29uc3RfXyB1OCBfX2FyY2hf
Yml0cmV2OCh1OCB4KQ0KK3sNCisJcmV0dXJuIF9fYXJjaF9iaXRyZXYzMigodTMyKXgpID4+IDI0
Ow0KK30NCisNCisjZW5kaWYNCisNCi0tIA0KMi4xLjENCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
