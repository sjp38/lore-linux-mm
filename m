Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 96E746B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 16:41:09 -0500 (EST)
Received: by padhx2 with SMTP id hx2so202759048pad.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 13:41:09 -0800 (PST)
Received: from COL004-OMC1S12.hotmail.com (col004-omc1s12.hotmail.com. [65.55.34.22])
        by mx.google.com with ESMTPS id v13si70332pas.84.2015.11.09.13.41.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Nov 2015 13:41:08 -0800 (PST)
Message-ID: <COL130-W65418E50E899195C9B2134B9150@phx.gbl>
Content-Type: multipart/mixed;
	boundary="_416340d1-4c65-41dd-96a1-c93a826e5e98_"
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Remove redundant local variables for
 may_expand_vm()
Date: Tue, 10 Nov 2015 05:41:08 +0800
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "aarcange@redhat.com" <aarcange@redhat.com>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

--_416340d1-4c65-41dd-96a1-c93a826e5e98_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>From 7050c267d8dda220226067039d815593d2f9a874 Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Tue=2C 10 Nov 2015 05:32:38 +0800=0A=
Subject: [PATCH] mm/mmap.c: Remove redundant local variables for may_expand=
_vm()=0A=
=0A=
After merge the related code into one line=2C the code is still simple and=
=0A=
meaningful enough.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 7 +------=0A=
=A01 file changed=2C 1 insertion(+)=2C 6 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index 2ce04a6..a515260 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -2988=2C12 +2988=2C7 @@ out:=0A=
=A0 */=0A=
=A0int may_expand_vm(struct mm_struct *mm=2C unsigned long npages)=0A=
=A0{=0A=
-	unsigned long cur =3D mm->total_vm=3B	/* pages */=0A=
-	unsigned long lim=3B=0A=
-=0A=
-	lim =3D rlimit(RLIMIT_AS)>> PAGE_SHIFT=3B=0A=
-=0A=
-	if (cur + npages> lim)=0A=
+	if (mm->total_vm + npages> (rlimit(RLIMIT_AS)>> PAGE_SHIFT))=0A=
=A0		return 0=3B=0A=
=A0	return 1=3B=0A=
=A0}=0A=
--=A0=0A=
1.9.3=0A=
=0A=
 		 	   		  =

--_416340d1-4c65-41dd-96a1-c93a826e5e98_
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-mm-mmap.c-Remove-redundant-local-variables-for-may_e.patch"

RnJvbSA3MDUwYzI2N2Q4ZGRhMjIwMjI2MDY3MDM5ZDgxNTU5M2QyZjlhODc0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41aTVqQGdtYWlsLmNvbT4K
RGF0ZTogVHVlLCAxMCBOb3YgMjAxNSAwNTozMjozOCArMDgwMApTdWJqZWN0OiBbUEFUQ0hdIG1t
L21tYXAuYzogUmVtb3ZlIHJlZHVuZGFudCBsb2NhbCB2YXJpYWJsZXMgZm9yIG1heV9leHBhbmRf
dm0oKQoKQWZ0ZXIgbWVyZ2UgdGhlIHJlbGF0ZWQgY29kZSBpbnRvIG9uZSBsaW5lLCB0aGUgY29k
ZSBpcyBzdGlsbCBzaW1wbGUgYW5kCm1lYW5pbmdmdWwgZW5vdWdoLgoKU2lnbmVkLW9mZi1ieTog
Q2hlbiBHYW5nIDxnYW5nLmNoZW4uNWk1akBnbWFpbC5jb20+Ci0tLQogbW0vbW1hcC5jIHwgNyAr
LS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDYgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbW0vbW1hcC5jIGIvbW0vbW1hcC5jCmluZGV4IDJjZTA0YTYuLmE1MTUyNjAg
MTAwNjQ0Ci0tLSBhL21tL21tYXAuYworKysgYi9tbS9tbWFwLmMKQEAgLTI5ODgsMTIgKzI5ODgs
NyBAQCBvdXQ6CiAgKi8KIGludCBtYXlfZXhwYW5kX3ZtKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1
bnNpZ25lZCBsb25nIG5wYWdlcykKIHsKLQl1bnNpZ25lZCBsb25nIGN1ciA9IG1tLT50b3RhbF92
bTsJLyogcGFnZXMgKi8KLQl1bnNpZ25lZCBsb25nIGxpbTsKLQotCWxpbSA9IHJsaW1pdChSTElN
SVRfQVMpID4+IFBBR0VfU0hJRlQ7Ci0KLQlpZiAoY3VyICsgbnBhZ2VzID4gbGltKQorCWlmICht
bS0+dG90YWxfdm0gKyBucGFnZXMgPiAocmxpbWl0KFJMSU1JVF9BUykgPj4gUEFHRV9TSElGVCkp
CiAJCXJldHVybiAwOwogCXJldHVybiAxOwogfQotLSAKMS45LjMKCg==

--_416340d1-4c65-41dd-96a1-c93a826e5e98_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
