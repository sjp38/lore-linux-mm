Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id C17976B0069
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 05:19:56 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so638615vcb.10
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 02:19:56 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id tf4si3327308vcb.1.2014.10.09.02.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 02:19:55 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so608218vcb.24
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 02:19:55 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 9 Oct 2014 17:19:54 +0800
Message-ID: <CADUXgx7QTWBMxesxgCet5rjpGu-V-xK_-5f2rX9R+v-ggi902A@mail.gmail.com>
Subject: [PATCH] smaps should deal with huge zero page exactly same as normal
 zero page
From: Fengwei Yin <yfw.kernel@gmail.com>
Content-Type: multipart/mixed; boundary=089e010d9f147fb4e90504f9ef6f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: fengguang.wu@intel.com

--089e010d9f147fb4e90504f9ef6f
Content-Type: text/plain; charset=UTF-8

Hi,
Fengguang found that the RSS/PSS shown in smaps is not correct
if the file is /dev/zero.

Example:
7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989
  /dev/zero
Size:           4294967296 kB
Rss:            10612736 kB
Pss:            10612736 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:  10612736 kB
Private_Dirty:         0 kB
Referenced:     10612736 kB
Anonymous:             0 kB
AnonHugePages:  10612736 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
VmFlags: rd mr mw me

--089e010d9f147fb4e90504f9ef6f
Content-Type: application/octet-stream;
	name="0001-smaps-should-deal-with-huge-zero-page-exactly-same.patch"
Content-Disposition: attachment;
	filename="0001-smaps-should-deal-with-huge-zero-page-exactly-same.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i11w94zu0

RnJvbSA1ZTg2MWQ1NTBmODUxMDQwYzRkMDQ1OGViZDNmMGZkOGZlOTRkYWRkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBGZW5nd2VpIFlpbiA8eWZ3Lmtlcm5lbEBnbWFpbC5jb20+CkRh
dGU6IFRodSwgOSBPY3QgMjAxNCAyMjoyMDo1OCArMDgwMApTdWJqZWN0OiBbUEFUQ0hdIHNtYXBz
IHNob3VsZCBkZWFsIHdpdGggaHVnZSB6ZXJvIHBhZ2UgZXhhY3RseSBzYW1lIGFzIG5vcm1hbAog
emVybyBwYWdlLgoKU2lnbmVkLW9mZi1ieTogRmVuZ3dlaSBZaW4gPHlmdy5rZXJuZWxAZ21haWwu
Y29tPgotLS0KIGZzL3Byb2MvdGFza19tbXUuYyAgICAgIHwgNSArKystLQogaW5jbHVkZS9saW51
eC9odWdlX21tLmggfCA0ICsrKysKIG1tL2h1Z2VfbWVtb3J5LmMgICAgICAgIHwgNCArKy0tCiAz
IGZpbGVzIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1n
aXQgYS9mcy9wcm9jL3Rhc2tfbW11LmMgYi9mcy9wcm9jL3Rhc2tfbW11LmMKaW5kZXggODBjYTRm
Yi4uODU1MGIyNyAxMDA2NDQKLS0tIGEvZnMvcHJvYy90YXNrX21tdS5jCisrKyBiL2ZzL3Byb2Mv
dGFza19tbXUuYwpAQCAtNDc2LDcgKzQ3Niw3IEBAIHN0YXRpYyB2b2lkIHNtYXBzX3B0ZV9lbnRy
eShwdGVfdCBwdGVudCwgdW5zaWduZWQgbG9uZyBhZGRyLAogCQkJbXNzLT5ub25saW5lYXIgKz0g
cHRlbnRfc2l6ZTsKIAl9CiAKLQlpZiAoIXBhZ2UpCisJaWYgKCFwYWdlIHx8IGlzX2h1Z2VfemVy
b19wYWdlKHBhZ2UpKQogCQlyZXR1cm47CiAKIAlpZiAoUGFnZUFub24ocGFnZSkpCkBAIC01MTYs
NyArNTE2LDggQEAgc3RhdGljIGludCBzbWFwc19wdGVfcmFuZ2UocG1kX3QgKnBtZCwgdW5zaWdu
ZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwKIAlpZiAocG1kX3RyYW5zX2h1Z2VfbG9j
ayhwbWQsIHZtYSwgJnB0bCkgPT0gMSkgewogCQlzbWFwc19wdGVfZW50cnkoKihwdGVfdCAqKXBt
ZCwgYWRkciwgSFBBR0VfUE1EX1NJWkUsIHdhbGspOwogCQlzcGluX3VubG9jayhwdGwpOwotCQlt
c3MtPmFub255bW91c190aHAgKz0gSFBBR0VfUE1EX1NJWkU7CisJCWlmICghaXNfaHVnZV96ZXJv
X3BtZCgqcG1kKSkKKwkJCW1zcy0+YW5vbnltb3VzX3RocCArPSBIUEFHRV9QTURfU0laRTsKIAkJ
cmV0dXJuIDA7CiAJfQogCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2h1Z2VfbW0uaCBiL2lu
Y2x1ZGUvbGludXgvaHVnZV9tbS5oCmluZGV4IDYzNTc5Y2IuLjc1OGY1NjkgMTAwNjQ0Ci0tLSBh
L2luY2x1ZGUvbGludXgvaHVnZV9tbS5oCisrKyBiL2luY2x1ZGUvbGludXgvaHVnZV9tbS5oCkBA
IC0zNCw2ICszNCwxMCBAQCBleHRlcm4gaW50IGNoYW5nZV9odWdlX3BtZChzdHJ1Y3Qgdm1fYXJl
YV9zdHJ1Y3QgKnZtYSwgcG1kX3QgKnBtZCwKIAkJCXVuc2lnbmVkIGxvbmcgYWRkciwgcGdwcm90
X3QgbmV3cHJvdCwKIAkJCWludCBwcm90X251bWEpOwogCitleHRlcm4gYm9vbCBpc19odWdlX3pl
cm9fcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSk7CisKK2V4dGVybiBib29sIGlzX2h1Z2VfemVyb19w
bWQocG1kX3QgcG1kKTsKKwogZW51bSB0cmFuc3BhcmVudF9odWdlcGFnZV9mbGFnIHsKIAlUUkFO
U1BBUkVOVF9IVUdFUEFHRV9GTEFHLAogCVRSQU5TUEFSRU5UX0hVR0VQQUdFX1JFUV9NQURWX0ZM
QUcsCmRpZmYgLS1naXQgYS9tbS9odWdlX21lbW9yeS5jIGIvbW0vaHVnZV9tZW1vcnkuYwppbmRl
eCBkOWEyMWQwNi4uYmVkYzNhZSAxMDA2NDQKLS0tIGEvbW0vaHVnZV9tZW1vcnkuYworKysgYi9t
bS9odWdlX21lbW9yeS5jCkBAIC0xNzMsMTIgKzE3MywxMiBAQCBzdGF0aWMgaW50IHN0YXJ0X2to
dWdlcGFnZWQodm9pZCkKIHN0YXRpYyBhdG9taWNfdCBodWdlX3plcm9fcmVmY291bnQ7CiBzdGF0
aWMgc3RydWN0IHBhZ2UgKmh1Z2VfemVyb19wYWdlIF9fcmVhZF9tb3N0bHk7CiAKLXN0YXRpYyBp
bmxpbmUgYm9vbCBpc19odWdlX3plcm9fcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSkKK2Jvb2wgaXNf
aHVnZV96ZXJvX3BhZ2Uoc3RydWN0IHBhZ2UgKnBhZ2UpCiB7CiAJcmV0dXJuIEFDQ0VTU19PTkNF
KGh1Z2VfemVyb19wYWdlKSA9PSBwYWdlOwogfQogCi1zdGF0aWMgaW5saW5lIGJvb2wgaXNfaHVn
ZV96ZXJvX3BtZChwbWRfdCBwbWQpCitib29sIGlzX2h1Z2VfemVyb19wbWQocG1kX3QgcG1kKQog
ewogCXJldHVybiBpc19odWdlX3plcm9fcGFnZShwbWRfcGFnZShwbWQpKTsKIH0KLS0gCjIuMC4x
Cgo=
--089e010d9f147fb4e90504f9ef6f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
