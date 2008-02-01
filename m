Received: by py-out-1112.google.com with SMTP id f47so1102187pye.20
        for <linux-mm@kvack.org>; Thu, 31 Jan 2008 23:39:07 -0800 (PST)
Message-ID: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
Date: Fri, 1 Feb 2008 16:39:07 +0900
From: "Kenichi Okuyama" <kenichi.okuyama@gmail.com>
Subject: [patch] NULL pointer check for vma->vm_mm
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4980_21923991.1201851547127"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

------=_Part_4980_21923991.1201851547127
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dear all,

I was looking at the ./mm/rmap.c .. I found that, in function
"page_referenced_one()",
   struct mm_struct *mm = vma->vm_mm;
was being refererred without NULL check.

Though I do agree that this works for most of the cases, I thought it
is better to add
BUG_ON() for case of mm being NULL.

attached is the patch for this

thank you in advance for taking your time.
best regards,
-- 
(Kenichi Okuyama)
URL: http://www.dd.iij4u.or.jp/~okuyamak/

------=_Part_4980_21923991.1201851547127
Content-Type: application/octet-stream; name=patch.mm
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fc4ezkog
Content-Disposition: attachment; filename=patch.mm

LS0tIC4vbW0vcm1hcC5jLm9yaWcJMjAwOC0wMi0wMSAxNTozNjo1MC4wMDAwMDAwMDAgKzA5MDAK
KysrIC4vbW0vcm1hcC5jCTIwMDgtMDItMDEgMTU6NDI6NDMuMDAwMDAwMDAwICswOTAwCkBAIC0y
NzYsNiArMjc2LDggQEAgc3RhdGljIGludCBwYWdlX3JlZmVyZW5jZWRfb25lKHN0cnVjdCBwYQog
CXNwaW5sb2NrX3QgKnB0bDsKIAlpbnQgcmVmZXJlbmNlZCA9IDA7CiAKKwlCVUdfT04oKCBtbSA9
PSBOVUxMICkpOworCiAJYWRkcmVzcyA9IHZtYV9hZGRyZXNzKHBhZ2UsIHZtYSk7CiAJaWYgKGFk
ZHJlc3MgPT0gLUVGQVVMVCkKIAkJZ290byBvdXQ7Cg==
------=_Part_4980_21923991.1201851547127--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
