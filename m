Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C1FF06B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 02:09:21 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so4117554pdb.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 23:09:21 -0800 (PST)
Received: from COL004-OMC1S9.hotmail.com (col004-omc1s9.hotmail.com. [65.55.34.19])
        by mx.google.com with ESMTPS id av1si339643pbc.154.2015.03.03.23.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Mar 2015 23:09:21 -0800 (PST)
Message-ID: <COL130-W6418F460A06AF52D2330F3B91E0@phx.gbl>
From: gchen gchen <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm: nommu: Export symbol max_mapnr
Date: Wed, 4 Mar 2015 15:09:20 +0800
In-Reply-To: <54F6B163.9000605@hotmail.com>
References: <54F6B163.9000605@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mark Salter <msalter@redhat.com>, "a-jacquiot@ti.com" <a-jacquiot@ti.com>

U2V2ZXJhbCBtb2R1bGVzIG1heSBuZWVkIG1heF9tYXBuciwgc28gZXhwb3J0LCB0aGUgcmVsYXRl
ZCBlcnJvciB3aXRoCmFsbG1vZGNvbmZpZyB1bmRlciBjNng6CgpNT0RQT1NUIDMzMjcgbW9kdWxl
cwpFUlJPUjogIm1heF9tYXBuciIgW2ZzL3BzdG9yZS9yYW1vb3BzLmtvXSB1bmRlZmluZWQhCkVS
Uk9SOiAibWF4X21hcG5yIiBbZHJpdmVycy9tZWRpYS92NGwyLWNvcmUvdmlkZW9idWYyLWRtYS1j
b250aWcua29dIHVuZGVmaW5lZCEKClNpZ25lZC1vZmYtYnk6IENoZW4gR2FuZyA8Z2FuZy5jaGVu
LjVpNWpAZ21haWwuY29tPgotLS0KbW0vbm9tbXUuYyB8IDEgKwoxIGZpbGUgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKykKCmRpZmYgLS1naXQgYS9tbS9ub21tdS5jIGIvbW0vbm9tbXUuYwppbmRleCAz
ZTY3ZTc1Li4zZmJhMmRjIDEwMDY0NAotLS0gYS9tbS9ub21tdS5jCisrKyBiL21tL25vbW11LmMK
QEAgLTYyLDYgKzYyLDcgQEAgdm9pZCAqaGlnaF9tZW1vcnk7CkVYUE9SVF9TWU1CT0woaGlnaF9t
ZW1vcnkpOwpzdHJ1Y3QgcGFnZSAqbWVtX21hcDsKdW5zaWduZWQgbG9uZyBtYXhfbWFwbnI7CitF
WFBPUlRfU1lNQk9MKG1heF9tYXBucik7CnVuc2lnbmVkIGxvbmcgaGlnaGVzdF9tZW1tYXBfcGZu
OwpzdHJ1Y3QgcGVyY3B1X2NvdW50ZXIgdm1fY29tbWl0dGVkX2FzOwppbnQgc3lzY3RsX292ZXJj
b21taXRfbWVtb3J5ID0gT1ZFUkNPTU1JVF9HVUVTUzsgLyogaGV1cmlzdGljIG92ZXJjb21taXQg
Ki8KLS0KMS45LjMKIAkJIAkgICAJCSAg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
