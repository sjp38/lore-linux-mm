Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBD96B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 10:04:01 -0400 (EDT)
Received: by oixx17 with SMTP id x17so25567095oix.0
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 07:04:00 -0700 (PDT)
Received: from COL004-OMC1S19.hotmail.com (col004-omc1s19.hotmail.com. [65.55.34.29])
        by mx.google.com with ESMTPS id j5si10217654pdd.119.2015.09.05.07.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 05 Sep 2015 07:04:00 -0700 (PDT)
Message-ID: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
Content-Type: multipart/mixed;
	boundary="_148e8dfe-9e04-4d70-ac9b-d0cebaa2b38f_"
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
  find_vma()
Date: Sat, 5 Sep 2015 22:03:59 +0800
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

--_148e8dfe-9e04-4d70-ac9b-d0cebaa2b38f_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

=0A=
>From b12fa5a9263cf4c044988e59f0071f4bcc132215 Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Sat=2C 5 Sep 2015 21:49:56 +0800=0A=
Subject: [PATCH] mm/mmap.c: Remove useless statement "vma =3D NULL" in=0A=
=A0find_vma()=0A=
=0A=
Before the main looping=2C vma is already is NULL=2C so need not set it to=
=0A=
NULL=2C again.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 1 -=0A=
=A01 file changed=2C 1 deletion(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index df6d5f0..4db7cf0 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -2054=2C7 +2054=2C6 @@ struct vm_area_struct *find_vma(struct mm_struct =
*mm=2C unsigned long addr)=0A=
=A0		return vma=3B=0A=
=A0=0A=
=A0	rb_node =3D mm->mm_rb.rb_node=3B=0A=
-	vma =3D NULL=3B=0A=
=A0=0A=
=A0	while (rb_node) {=0A=
=A0		struct vm_area_struct *tmp=3B=0A=
--=A0=0A=
1.9.3=0A=
=0A=
 		 	   		  =

--_148e8dfe-9e04-4d70-ac9b-d0cebaa2b38f_
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-mm-mmap.c-Remove-useless-statement-vma-NULL-in-find_.patch"

RnJvbSBiMTJmYTVhOTI2M2NmNGMwNDQ5ODhlNTlmMDA3MWY0YmNjMTMyMjE1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41aTVqQGdtYWlsLmNvbT4K
RGF0ZTogU2F0LCA1IFNlcCAyMDE1IDIxOjQ5OjU2ICswODAwClN1YmplY3Q6IFtQQVRDSCAxLzJd
IG1tL21tYXAuYzogUmVtb3ZlIHVzZWxlc3Mgc3RhdGVtZW50ICJ2bWEgPSBOVUxMIiBpbgogZmlu
ZF92bWEoKQoKQmVmb3JlIHRoZSBtYWluIGxvb3BpbmcsIHZtYSBpcyBhbHJlYWR5IGlzIE5VTEws
IHNvIG5lZWQgbm90IHNldCBpdCB0bwpOVUxMLCBhZ2Fpbi4KClNpZ25lZC1vZmYtYnk6IENoZW4g
R2FuZyA8Z2FuZy5jaGVuLjVpNWpAZ21haWwuY29tPgotLS0KIG1tL21tYXAuYyB8IDEgLQogMSBm
aWxlIGNoYW5nZWQsIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9t
bWFwLmMKaW5kZXggZGY2ZDVmMC4uNGRiN2NmMCAxMDA2NDQKLS0tIGEvbW0vbW1hcC5jCisrKyBi
L21tL21tYXAuYwpAQCAtMjA1NCw3ICsyMDU0LDYgQEAgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpm
aW5kX3ZtYShzdHJ1Y3QgbW1fc3RydWN0ICptbSwgdW5zaWduZWQgbG9uZyBhZGRyKQogCQlyZXR1
cm4gdm1hOwogCiAJcmJfbm9kZSA9IG1tLT5tbV9yYi5yYl9ub2RlOwotCXZtYSA9IE5VTEw7CiAK
IAl3aGlsZSAocmJfbm9kZSkgewogCQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnRtcDsKLS0gCjEu
OS4zCgo=

--_148e8dfe-9e04-4d70-ac9b-d0cebaa2b38f_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
