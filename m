Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2786B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 06:06:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u185so287422241oie.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 03:06:43 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id u23si24125404ioi.182.2016.05.16.03.06.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 03:06:42 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O7900X3ILF5MSC0@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 16 May 2016 19:06:41 +0900 (KST)
Date: Mon, 16 May 2016 10:06:41 +0000 (GMT)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] drivers: of: of_reserved_mem: fixup the CMA alignment not to
 affect dma-coherent
Reply-to: jaewon31.kim@samsung.com
MIME-version: 1.0
Content-transfer-encoding: base64
Content-type: text/plain; charset=euc-kr
MIME-version: 1.0
Message-id: <1931335297.775331463393198643.JavaMail.weblogic@ep2mlwas08b>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robh+dt@kernel.org
Cc: r64343@freescale.com, m.szyprowski@samsung.com, grant.likely@linaro.org, jaewon31.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

VGhlcmUgd2FzIGFuIGFsaWdubWVudCBtaXNtYXRjaCBpc3N1ZSBmb3IgQ01BIGFuZCBpdCB3YXMg
Zml4ZWQgYnkNCmNvbW1pdCAxY2M4ZTM0NThiNTEgKCJkcml2ZXJzOiBvZjogb2ZfcmVzZXJ2ZWRf
bWVtOiBmaXh1cCB0aGUgYWxpZ25tZW50IHdpdGggQ01BIHNldHVwIikuDQpIb3dldmVyIHRoZSB3
YXkgb2YgdGhlIGNvbW1pdCBjb25zaWRlcnMgbm90IG9ubHkgZG1hLWNvbnRpZ3VvdXMoQ01BKSBi
dXQgYWxzbw0KZG1hLWNvaGVyZW50IHdoaWNoIGhhcyBubyB0aGF0IHJlcXVpcmVtZW50Lg0KDQpU
aGlzIHBhdGNoIGNoZWNrcyBtb3JlIHRvIGRpc3Rpbmd1aXNoIGRtYS1jb250aWd1b3VzKENNQSkg
ZnJvbSBkbWEtY29oZXJlbnQuDQoNClNpZ25lZC1vZmYtYnk6IEphZXdvbiA8amFld29uMzEua2lt
QHNhbXN1bmcuY29tPg0KLS0tDQogZHJpdmVycy9vZi9vZl9yZXNlcnZlZF9tZW0uYyB8IDUgKysr
Ky0NCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQoNCmRp
ZmYgLS1naXQgYS9kcml2ZXJzL29mL29mX3Jlc2VydmVkX21lbS5jIGIvZHJpdmVycy9vZi9vZl9y
ZXNlcnZlZF9tZW0uYw0KaW5kZXggZWQwMWMwMS4uNDViODczZSAxMDA2NDQNCi0tLSBhL2RyaXZl
cnMvb2Yvb2ZfcmVzZXJ2ZWRfbWVtLmMNCisrKyBiL2RyaXZlcnMvb2Yvb2ZfcmVzZXJ2ZWRfbWVt
LmMNCkBAIC0xMjcsNyArMTI3LDEwIEBAIHN0YXRpYyBpbnQgX19pbml0IF9fcmVzZXJ2ZWRfbWVt
X2FsbG9jX3NpemUodW5zaWduZWQgbG9uZyBub2RlLA0KIAl9DQogDQogCS8qIE5lZWQgYWRqdXN0
IHRoZSBhbGlnbm1lbnQgdG8gc2F0aXNmeSB0aGUgQ01BIHJlcXVpcmVtZW50ICovDQotCWlmIChJ
U19FTkFCTEVEKENPTkZJR19DTUEpICYmIG9mX2ZsYXRfZHRfaXNfY29tcGF0aWJsZShub2RlLCAi
c2hhcmVkLWRtYS1wb29sIikpDQorCWlmIChJU19FTkFCTEVEKENPTkZJR19DTUEpDQorCSAgICAm
JiBvZl9mbGF0X2R0X2lzX2NvbXBhdGlibGUobm9kZSwgInNoYXJlZC1kbWEtcG9vbCIpDQorCSAg
ICAmJiBvZl9nZXRfZmxhdF9kdF9wcm9wKG5vZGUsICJyZXVzYWJsZSIsIE5VTEwpDQorCSAgICAm
JiAhb2ZfZ2V0X2ZsYXRfZHRfcHJvcChub2RlLCAibm8tbWFwIiwgTlVMTCkpIHsNCiAJCWFsaWdu
ID0gbWF4KGFsaWduLCAocGh5c19hZGRyX3QpUEFHRV9TSVpFIDw8IG1heChNQVhfT1JERVIgLSAx
LCBwYWdlYmxvY2tfb3JkZXIpKTsNCiANCiAJcHJvcCA9IG9mX2dldF9mbGF0X2R0X3Byb3Aobm9k
ZSwgImFsbG9jLXJhbmdlcyIsICZsZW4pOw0K


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
