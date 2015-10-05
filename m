Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 702626B02C6
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 11:55:36 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so180772831pac.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 08:55:36 -0700 (PDT)
Received: from COL004-OMC1S15.hotmail.com (col004-omc1s15.hotmail.com. [65.55.34.25])
        by mx.google.com with ESMTPS id vb1si41153815pac.165.2015.10.05.08.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Oct 2015 08:55:35 -0700 (PDT)
Message-ID: <COL130-W55A6DE834A523637B79293B9480@phx.gbl>
Content-Type: multipart/mixed;
	boundary="_51bf969f-87e7-4aec-9804-682a6baf25f7_"
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Remove redundant statement "error = -ENOMEM"
Date: Mon, 5 Oct 2015 23:55:35 +0800
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "emunson@akamai.com" <emunson@akamai.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

--_51bf969f-87e7-4aec-9804-682a6baf25f7_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>From 4150fd59c4aa35d36e81920ecb2a522c8c7b68b9 Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Mon=2C 5 Oct 2015 23:43:30 +0800=0A=
Subject: [PATCH] mm/mmap.c: Remove redundant statement "error =3D -ENOMEM"=
=0A=
=0A=
It is still a little better to remove it=2C although it should be skipped=
=0A=
by "-O2".=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 1 -=0A=
=A01 file changed=2C 1 deletion(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index 8393580..1da4600 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -1562=2C7 +1562=2C6 @@ unsigned long mmap_region(struct file *file=2C un=
signed long addr=2C=0A=
=A0	}=0A=
=A0=0A=
=A0	/* Clear old maps */=0A=
-	error =3D -ENOMEM=3B=0A=
=A0	while (find_vma_links(mm=2C addr=2C addr + len=2C &prev=2C &rb_link=2C=
=0A=
=A0			 =A0 =A0 =A0&rb_parent)) {=0A=
=A0		if (do_munmap(mm=2C addr=2C len))=0A=
--=A0=0A=
1.9.3=0A=
=0A=
 		 	   		  =

--_51bf969f-87e7-4aec-9804-682a6baf25f7_
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-mm-mmap.c-Remove-redundant-statement-error-ENOMEM.patch"

RnJvbSA0MTUwZmQ1OWM0YWEzNWQzNmU4MTkyMGVjYjJhNTIyYzhjN2I2OGI5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41aTVqQGdtYWlsLmNvbT4K
RGF0ZTogTW9uLCA1IE9jdCAyMDE1IDIzOjQzOjMwICswODAwClN1YmplY3Q6IFtQQVRDSF0gbW0v
bW1hcC5jOiBSZW1vdmUgcmVkdW5kYW50IHN0YXRlbWVudCAiZXJyb3IgPSAtRU5PTUVNIgoKSXQg
aXMgc3RpbGwgYSBsaXR0bGUgYmV0dGVyIHRvIHJlbW92ZSBpdCwgYWx0aG91Z2ggaXQgc2hvdWxk
IGJlIHNraXBwZWQKYnkgIi1PMiIuCgpTaWduZWQtb2ZmLWJ5OiBDaGVuIEdhbmcgPGdhbmcuY2hl
bi41aTVqQGdtYWlsLmNvbT4KLS0tCiBtbS9tbWFwLmMgfCAxIC0KIDEgZmlsZSBjaGFuZ2VkLCAx
IGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbW1hcC5jIGIvbW0vbW1hcC5jCmluZGV4IDgz
OTM1ODAuLjFkYTQ2MDAgMTAwNjQ0Ci0tLSBhL21tL21tYXAuYworKysgYi9tbS9tbWFwLmMKQEAg
LTE1NjIsNyArMTU2Miw2IEBAIHVuc2lnbmVkIGxvbmcgbW1hcF9yZWdpb24oc3RydWN0IGZpbGUg
KmZpbGUsIHVuc2lnbmVkIGxvbmcgYWRkciwKIAl9CiAKIAkvKiBDbGVhciBvbGQgbWFwcyAqLwot
CWVycm9yID0gLUVOT01FTTsKIAl3aGlsZSAoZmluZF92bWFfbGlua3MobW0sIGFkZHIsIGFkZHIg
KyBsZW4sICZwcmV2LCAmcmJfbGluaywKIAkJCSAgICAgICZyYl9wYXJlbnQpKSB7CiAJCWlmIChk
b19tdW5tYXAobW0sIGFkZHIsIGxlbikpCi0tIAoxLjkuMwoK

--_51bf969f-87e7-4aec-9804-682a6baf25f7_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
