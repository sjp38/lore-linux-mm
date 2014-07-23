Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id A22B26B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 05:28:07 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so975993qae.6
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 02:28:07 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id u8si3573377qat.130.2014.07.23.02.28.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 02:28:06 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so1083251qgf.31
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 02:28:06 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 23 Jul 2014 14:58:00 +0530
Message-ID: <CAG6enPwuD2_6U=iELn9C7gMzxre0V-VYmxP14R-qW3sMNddvCg@mail.gmail.com>
Subject: Patch: zram add compressionratio in sysfs interface
From: Yogesh Gaur <yogeshgaur.83@gmail.com>
Content-Type: multipart/mixed; boundary=047d7bacb2aa27923f04fed8f5e1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, ngupta@vflare.org

--047d7bacb2aa27923f04fed8f5e1
Content-Type: multipart/alternative; boundary=047d7bacb2aa27923b04fed8f5df

--047d7bacb2aa27923b04fed8f5df
Content-Type: text/plain; charset=UTF-8

Hello All,

Please find attached patch which adds new entry in existing zram device
sysfs interface, this interface shows compression ratio for asked zram
device.
Sysfs interface for 'orig_data_size' and 'mem_used_total' already present,
'compression_ratio' would be orig_data_size divided by mem_used_total.

Please check patch.

--
Regards,
Yogesh Gaur.

--047d7bacb2aa27923b04fed8f5df
Content-Type: text/html; charset=UTF-8

<p dir="ltr">Hello All,</p>
<p dir="ltr">Please find attached patch which adds new entry in existing zram device sysfs interface, this interface shows compression ratio for asked zram device.<br>
Sysfs interface for &#39;orig_data_size&#39; and &#39;mem_used_total&#39; already present, &#39;compression_ratio&#39; would be orig_data_size divided by mem_used_total.</p>
<p dir="ltr">Please check patch.</p>
<p dir="ltr">--<br>
Regards,<br>
Yogesh Gaur.</p>

--047d7bacb2aa27923b04fed8f5df--

--047d7bacb2aa27923f04fed8f5e1
Content-Type: */*;
	name="0001-zram-add-compressionratio-sysfs-interface.patch"
Content-Disposition: attachment;
	filename="0001-zram-add-compressionratio-sysfs-interface.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: 1474410612404518912-local0

RnJvbSAzNDg3NTdmNzNlZjJlNWI1YjFjNjc5NzkwOGFhZTRmNDE4NzcyNjUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZb2dlc2ggR2F1ciA8eW9nZXNoZ2F1ci44M0BnbWFpbC5jb20+
CkRhdGU6IFdlZCwgMjMgSnVsIDIwMTQgMjI6NTM6MTkgKzA1MzAKU3ViamVjdDogW1BBVENIIDEv
MV0gY29tcHJlc3Npb24tcmF0aW8KCkFkZGl0aW9uIG9mIG5ldyBzeXNmcyBpbnRlcmZhY2UgdG8g
c2hvdyBjb21wcmVzc2lvbiByYXRpbyBmb3IgWlJBTSBkZXZpY2VzLgpTeXNmcyBpbnRlcmZhY2Ug
Zm9yICdvcmlnX2RhdGFfc2l6ZScgYW5kICdtZW1fdXNlZF90b3RhbCcgYWxyZWFkeSBwcmVzZW50
LgonY29tcHJlc3Npb25fcmF0aW8nIHdvdWxkIGJlIG9yaWdfZGF0YV9zaXplIGRpdmlkZWQgYnkg
bWVtX3VzZWRfdG90YWwuCgphLiBCZWZvcmUgY3JlYXRpbmcgenJhbSBkZXZpY2UKJCM+IGNhdCBz
eXMvYmxvY2svenJhbTAvY29tcHJlc3Npb25fcmF0aW8KWyAgMTQwLjY3MjAwMF0genJhbTogV0FS
TiAhISBtZW1fdXNlZF90b3RhbCBpcyAnMCcKJCM+CmIuIEFmdGVyIGNyZWF0aW5nIHpyYW0gZGV2
aWNlLCBmb3JtYXRpbmcgd2l0aCBta2ZzLnZmYXQgYW5kIHJ1bm5pbmcgCiAgIGlvem9uZSB0ZXN0
IG9uIHpyYW0wIGRldmljZQokIz4gY2F0IC9zeXMvYmxvY2svenJhbTAvY29tcHJlc3Npb25fcmF0
aW8KNTcKJCM+CgpTaWduZWQtb2ZmLWJ5OiBZb2dlc2ggR2F1ciA8eW9nZXNoZ2F1ci44M0BnbWFp
bC5jb20+Ci0tLQogZHJpdmVycy9ibG9jay96cmFtL3pyYW1fZHJ2LmMgfCAgIDI2ICsrKysrKysr
KysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDI2IGluc2VydGlvbnMoKyksIDAg
ZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9ibG9jay96cmFtL3pyYW1fZHJ2LmMg
Yi9kcml2ZXJzL2Jsb2NrL3pyYW0venJhbV9kcnYuYwppbmRleCAwODllNzJjLi5kYmFiMGMzIDEw
MDY0NAotLS0gYS9kcml2ZXJzL2Jsb2NrL3pyYW0venJhbV9kcnYuYworKysgYi9kcml2ZXJzL2Js
b2NrL3pyYW0venJhbV9kcnYuYwpAQCAtOTQsNiArOTQsMzAgQEAgc3RhdGljIHNzaXplX3Qgb3Jp
Z19kYXRhX3NpemVfc2hvdyhzdHJ1Y3QgZGV2aWNlICpkZXYsCiAJCSh1NjQpKGF0b21pYzY0X3Jl
YWQoJnpyYW0tPnN0YXRzLnBhZ2VzX3N0b3JlZCkpIDw8IFBBR0VfU0hJRlQpOwogfQogCitzdGF0
aWMgc3NpemVfdCBjb21wcl9yYXRpb19zaG93KHN0cnVjdCBkZXZpY2UgKmRldiwKKwkJc3RydWN0
IGRldmljZV9hdHRyaWJ1dGUgKmF0dHIsIGNoYXIgKmJ1ZikKK3sKKwl1NjQgbWVtX3VzZWRfdG90
YWwgPSAwOworCXU2NCBvcmlnX2RhdGFfc2l6ZSA9IDA7CisJdTMyIGNvbXByX3JhdGlvID0gMDsK
KwlzdHJ1Y3QgenJhbSAqenJhbSA9IGRldl90b196cmFtKGRldik7CisJc3RydWN0IHpyYW1fbWV0
YSAqbWV0YSA9IHpyYW0tPm1ldGE7CisKKwlvcmlnX2RhdGFfc2l6ZSA9ICh1NjQpKGF0b21pYzY0
X3JlYWQoJnpyYW0tPnN0YXRzLnBhZ2VzX3N0b3JlZCkpIFwKKwkJCQkJCTw8IFBBR0VfU0hJRlQ7
CisJZG93bl9yZWFkKCZ6cmFtLT5pbml0X2xvY2spOworCWlmIChpbml0X2RvbmUoenJhbSkpCisJ
CW1lbV91c2VkX3RvdGFsID0genNfZ2V0X3RvdGFsX3NpemVfYnl0ZXMobWV0YS0+bWVtX3Bvb2wp
OworCXVwX3JlYWQoJnpyYW0tPmluaXRfbG9jayk7CisJaWYgKG1lbV91c2VkX3RvdGFsID09IDAp
IHsKKwkJcHJfaW5mbygiV0FSTiAhISBtZW1fdXNlZF90b3RhbCBpcyAnMCdcbiIpOworCQlyZXR1
cm4gMDsKKwl9CisJY29tcHJfcmF0aW8gPSBkaXZfdTY0KG9yaWdfZGF0YV9zaXplLCBtZW1fdXNl
ZF90b3RhbCk7CisKKwlyZXR1cm4gc2NucHJpbnRmKGJ1ZiwgUEFHRV9TSVpFLCAiJWRcbiIsIGNv
bXByX3JhdGlvKTsKK30KKwogc3RhdGljIHNzaXplX3QgbWVtX3VzZWRfdG90YWxfc2hvdyhzdHJ1
Y3QgZGV2aWNlICpkZXYsCiAJCXN0cnVjdCBkZXZpY2VfYXR0cmlidXRlICphdHRyLCBjaGFyICpi
dWYpCiB7CkBAIC04MjgsNiArODUyLDcgQEAgc3RhdGljIERFVklDRV9BVFRSKG1heF9jb21wX3N0
cmVhbXMsIFNfSVJVR08gfCBTX0lXVVNSLAogCQltYXhfY29tcF9zdHJlYW1zX3Nob3csIG1heF9j
b21wX3N0cmVhbXNfc3RvcmUpOwogc3RhdGljIERFVklDRV9BVFRSKGNvbXBfYWxnb3JpdGhtLCBT
X0lSVUdPIHwgU19JV1VTUiwKIAkJY29tcF9hbGdvcml0aG1fc2hvdywgY29tcF9hbGdvcml0aG1f
c3RvcmUpOworc3RhdGljIERFVklDRV9BVFRSKGNvbXByZXNzaW9uX3JhdGlvLCBTX0lSVUdPLCBj
b21wcl9yYXRpb19zaG93LCBOVUxMKTsKIAogWlJBTV9BVFRSX1JPKG51bV9yZWFkcyk7CiBaUkFN
X0FUVFJfUk8obnVtX3dyaXRlcyk7CkBAIC04NTQsNiArODc5LDcgQEAgc3RhdGljIHN0cnVjdCBh
dHRyaWJ1dGUgKnpyYW1fZGlza19hdHRyc1tdID0gewogCSZkZXZfYXR0cl9tZW1fdXNlZF90b3Rh
bC5hdHRyLAogCSZkZXZfYXR0cl9tYXhfY29tcF9zdHJlYW1zLmF0dHIsCiAJJmRldl9hdHRyX2Nv
bXBfYWxnb3JpdGhtLmF0dHIsCisJJmRldl9hdHRyX2NvbXByZXNzaW9uX3JhdGlvLmF0dHIsCiAJ
TlVMTCwKIH07CiAKLS0gCjEuNy4xCgo=
--047d7bacb2aa27923f04fed8f5e1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
