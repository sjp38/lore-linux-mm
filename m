Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 69D796B02C3
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 15:38:49 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so135973442pab.3
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 12:38:49 -0700 (PDT)
Received: from COL004-OMC1S6.hotmail.com (col004-omc1s6.hotmail.com. [65.55.34.16])
        by mx.google.com with ESMTPS id di4si8867258pad.183.2015.10.03.12.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Oct 2015 12:38:48 -0700 (PDT)
Message-ID: <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl>
Content-Type: multipart/mixed;
	boundary="_3f00bea1-81d8-47a6-97d0-0033d4d9b19c_"
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Remove redundant vma looping
Date: Sun, 4 Oct 2015 03:38:48 +0800
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "asha.levin@oracle.com" <asha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

--_3f00bea1-81d8-47a6-97d0-0033d4d9b19c_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>From 36dbcc145819655682f80efd49e72b01515b4e9a Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Sun=2C 4 Oct 2015 03:22:41 +0800=0A=
Subject: [PATCH] mm/mmap.c: Remove redundant vma looping=0A=
=0A=
vma->vm_file->f_mapping and vma->anon_vma are shared with the same vma=0A=
looping=2C so merge them.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 2 --=0A=
=A01 file changed=2C 2 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index 8393580..f7c1631 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -3201=2C9 +3201=2C7 @@ int mm_take_all_locks(struct mm_struct *mm)=0A=
=A0			goto out_unlock=3B=0A=
=A0		if (vma->vm_file && vma->vm_file->f_mapping)=0A=
=A0			vm_lock_mapping(mm=2C vma->vm_file->f_mapping)=3B=0A=
-	}=0A=
=A0=0A=
-	for (vma =3D mm->mmap=3B vma=3B vma =3D vma->vm_next) {=0A=
=A0		if (signal_pending(current))=0A=
=A0			goto out_unlock=3B=0A=
=A0		if (vma->anon_vma)=0A=
--=A0=0A=
1.9.3=0A=
=0A=
=0A=
Chen Gang=0A=
=0A=
Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed=0A=
 		 	   		  =

--_3f00bea1-81d8-47a6-97d0-0033d4d9b19c_
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-mm-mmap.c-Remove-redundant-vma-looping.patch"

RnJvbSAzNmRiY2MxNDU4MTk2NTU2ODJmODBlZmQ0OWU3MmIwMTUxNWI0ZTlhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41aTVqQGdtYWlsLmNvbT4K
RGF0ZTogU3VuLCA0IE9jdCAyMDE1IDAzOjIyOjQxICswODAwClN1YmplY3Q6IFtQQVRDSF0gbW0v
bW1hcC5jOiBSZW1vdmUgcmVkdW5kYW50IHZtYSBsb29waW5nCgp2bWEtPnZtX2ZpbGUtPmZfbWFw
cGluZyBhbmQgdm1hLT5hbm9uX3ZtYSBhcmUgc2hhcmVkIHdpdGggdGhlIHNhbWUgdm1hCmxvb3Bp
bmcsIHNvIG1lcmdlIHRoZW0uCgpTaWduZWQtb2ZmLWJ5OiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41
aTVqQGdtYWlsLmNvbT4KLS0tCiBtbS9tbWFwLmMgfCAyIC0tCiAxIGZpbGUgY2hhbmdlZCwgMiBk
ZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9tbWFwLmMKaW5kZXggODM5
MzU4MC4uZjdjMTYzMSAxMDA2NDQKLS0tIGEvbW0vbW1hcC5jCisrKyBiL21tL21tYXAuYwpAQCAt
MzIwMSw5ICszMjAxLDcgQEAgaW50IG1tX3Rha2VfYWxsX2xvY2tzKHN0cnVjdCBtbV9zdHJ1Y3Qg
Km1tKQogCQkJZ290byBvdXRfdW5sb2NrOwogCQlpZiAodm1hLT52bV9maWxlICYmIHZtYS0+dm1f
ZmlsZS0+Zl9tYXBwaW5nKQogCQkJdm1fbG9ja19tYXBwaW5nKG1tLCB2bWEtPnZtX2ZpbGUtPmZf
bWFwcGluZyk7Ci0JfQogCi0JZm9yICh2bWEgPSBtbS0+bW1hcDsgdm1hOyB2bWEgPSB2bWEtPnZt
X25leHQpIHsKIAkJaWYgKHNpZ25hbF9wZW5kaW5nKGN1cnJlbnQpKQogCQkJZ290byBvdXRfdW5s
b2NrOwogCQlpZiAodm1hLT5hbm9uX3ZtYSkKLS0gCjEuOS4zCgo=

--_3f00bea1-81d8-47a6-97d0-0033d4d9b19c_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
