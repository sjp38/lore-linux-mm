Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 068196B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:51:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so10631685pfc.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:51:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n85si50109337pfj.132.2016.06.01.02.51.57
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 02:51:58 -0700 (PDT)
From: "Barczak, Mariusz" <mariusz.barczak@intel.com>
Subject: [BUG] Possible silent data corruption in filesystems/page cache
Date: Wed, 1 Jun 2016 09:51:46 +0000
Message-ID: <842E055448A75D44BEB94DEB9E5166E91877AAF1@irsmsx110.ger.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_003_842E055448A75D44BEB94DEB9E5166E91877AAF1irsmsx110gercor_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "Wysoczanski, Michal" <michal.wysoczanski@intel.com>, "Baldyga, Robert" <robert.baldyga@intel.com>, "Barczak, Mariusz" <mariusz.barczak@intel.com>, "Roman, Agnieszka" <agnieszka.roman@intel.com>

--_003_842E055448A75D44BEB94DEB9E5166E91877AAF1irsmsx110gercor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi

We run data validation test for buffered workload on filesystems:
ext3, ext4, and XFS.
In context of flushing page cache block device driver returned IO error.
After dropping page cache our validation tool reported data corruption.

We provided a simple patch in order to inject IO error in device mapper.
We run test to verify md5sum of file during IO error.
Test shows checksum mismatch.

Attachments:
0001-drivers-md-dm-add-error-injection.patch - device mapper patch
dm-test.txt - validation test script

Regards,
Mariusz Barczak
Intel Technology Poland

--------------------------------------------------------------------

Intel Technology Poland sp. z o.o.
ul. Slowackiego 173 | 80-298 Gdansk | Sad Rejonowy Gdansk Polnoc | VII Wydz=
ial Gospodarczy Krajowego Rejestru Sadowego - KRS 101882 | NIP 957-07-52-31=
6 | Kapital zakladowy 200.000 PLN.

Ta wiadomosc wraz z zalacznikami jest przeznaczona dla okreslonego adresata=
 i moze zawierac informacje poufne. W razie przypadkowego otrzymania tej wi=
adomosci, prosimy o powiadomienie nadawcy oraz trwale jej usuniecie; jakiek=
olwiek
przegladanie lub rozpowszechnianie jest zabronione.
This e-mail and any attachments may contain confidential material for the s=
ole use of the intended recipient(s). If you are not the intended recipient=
, please contact the sender and delete all copies; any review or distributi=
on by
others is strictly prohibited.

--_003_842E055448A75D44BEB94DEB9E5166E91877AAF1irsmsx110gercor_
Content-Type: application/octet-stream;
	name="0001-drivers-md-dm-add-error-injection.patch"
Content-Description: 0001-drivers-md-dm-add-error-injection.patch
Content-Disposition: attachment;
	filename="0001-drivers-md-dm-add-error-injection.patch"; size=2351;
	creation-date="Wed, 01 Jun 2016 09:38:31 GMT";
	modification-date="Wed, 01 Jun 2016 09:38:31 GMT"
Content-Transfer-Encoding: base64

RnJvbSBjYTQxZjNmMmViZWIyNTU1Y2UxODM5M2Y2ZWY5ODYyOWI2M2E4MGRiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSb2JlcnQgQmFsZHlnYSA8cm9iZXJ0LmJhbGR5Z2FAaW50ZWwu
Y29tPgpEYXRlOiBXZWQsIDEgSnVuIDIwMTYgMTE6MDA6NDcgKzAyMDAKU3ViamVjdDogW0RFQlVH
XSBkcml2ZXJzOiBtZDogZG06IGFkZCBlcnJvciBpbmplY3Rpb24KClRoaXMgcGF0Y2ggYWRkcyBl
cnJvciBpbmplY3Rpb24gbWVjaGFuaXNtIHVzaW5nIGRlYnVnZnMuCkl0IGFsbG93cyB0byBmYWls
IGZldyBCSU8ncyBmb3IgZGVidWcgcHVycG9zZXMuCgpTaWduZWQtb2ZmLWJ5OiBSb2JlcnQgQmFs
ZHlnYSA8cm9iZXJ0LmJhbGR5Z2FAaW50ZWwuY29tPgotLS0KIGRyaXZlcnMvbWQvZG0uYyB8IDQ5
ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIDEgZmls
ZSBjaGFuZ2VkLCA0OSBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9tZC9kbS5j
IGIvZHJpdmVycy9tZC9kbS5jCmluZGV4IDFiMmY5NjIuLjE1YTcwYTIgMTAwNjQ0Ci0tLSBhL2Ry
aXZlcnMvbWQvZG0uYworKysgYi9kcml2ZXJzL21kL2RtLmMKQEAgLTI1LDYgKzI1LDcgQEAKICNp
bmNsdWRlIDxsaW51eC9lbGV2YXRvci5oPiAvKiBmb3IgcnFfZW5kX3NlY3RvcigpICovCiAjaW5j
bHVkZSA8bGludXgvYmxrLW1xLmg+CiAjaW5jbHVkZSA8bGludXgvcHIuaD4KKyNpbmNsdWRlIDxs
aW51eC9kZWJ1Z2ZzLmg+CiAKICNpbmNsdWRlIDx0cmFjZS9ldmVudHMvYmxvY2suaD4KIApAQCAt
NDE1LDggKzQxNiw0NyBAQCBzdGF0aWMgdm9pZCBsb2NhbF9leGl0KHZvaWQpCiAJRE1JTkZPKCJj
bGVhbmVkIHVwIik7CiB9CiAKK3N0YXRpYyBzdHJ1Y3QgZGVudHJ5ICpkYmdmc19yb290Oworc3Rh
dGljIHUzMiBkYmdfZXJyb3JfY291bnRlciA9IDA7CitzdGF0aWMgdTMyIGRiZ19lcnJvcl9tYXgg
PSAxOworc3RhdGljIHUzMiBkYmdfZXJyb3IgPSAwOworCitzdGF0aWMgaW50IF9faW5pdCBkbV9k
ZWJ1Z2ZzX2luaXQodm9pZCkKK3sKKwlzdHJ1Y3QgZGVudHJ5ICpyZXRfZDsKKworCWRiZ2ZzX3Jv
b3QgPSBkZWJ1Z2ZzX2NyZWF0ZV9kaXIoImRtX2RlYnVnIiwgTlVMTCk7CisJaWYgKCFkYmdmc19y
b290KQorCQlyZXR1cm4gLUVOT0VOVDsKKworCXJldF9kID0gZGVidWdmc19jcmVhdGVfdTMyKCJl
cnJvcl9jb3VudGVyIiwgMDY0NCwgZGJnZnNfcm9vdCwgJmRiZ19lcnJvcl9jb3VudGVyKTsKKwlp
ZiAoIXJldF9kKQorCQlnb3RvIGZhaWw7CisKKwlyZXRfZCA9IGRlYnVnZnNfY3JlYXRlX3UzMigi
ZXJyb3JfbWF4IiwgMDY0NCwgZGJnZnNfcm9vdCwgJmRiZ19lcnJvcl9tYXgpOworCWlmICghcmV0
X2QpCisJCWdvdG8gZmFpbDsKKworCXJldF9kID0gZGVidWdmc19jcmVhdGVfdTMyKCJlcnJvciIs
IDA2NDQsIGRiZ2ZzX3Jvb3QsICZkYmdfZXJyb3IpOworCWlmICghcmV0X2QpCisJCWdvdG8gZmFp
bDsKKworCXJldHVybiAwOworCitmYWlsOgorCWRlYnVnZnNfcmVtb3ZlX3JlY3Vyc2l2ZShkYmdm
c19yb290KTsKKwlkYmdmc19yb290ID0gTlVMTDsKKwlyZXR1cm4gLUVOT0VOVDsKK30KKworc3Rh
dGljIHZvaWQgZG1fZGVidWdmc19leGl0KHZvaWQpCit7CisJZGVidWdmc19yZW1vdmVfcmVjdXJz
aXZlKGRiZ2ZzX3Jvb3QpOworfQorCiBzdGF0aWMgaW50ICgqX2luaXRzW10pKHZvaWQpIF9faW5p
dGRhdGEgPSB7CiAJbG9jYWxfaW5pdCwKKwlkbV9kZWJ1Z2ZzX2luaXQsCiAJZG1fdGFyZ2V0X2lu
aXQsCiAJZG1fbGluZWFyX2luaXQsCiAJZG1fc3RyaXBlX2luaXQsCkBAIC00MjgsNiArNDY4LDcg
QEAgc3RhdGljIGludCAoKl9pbml0c1tdKSh2b2lkKSBfX2luaXRkYXRhID0gewogCiBzdGF0aWMg
dm9pZCAoKl9leGl0c1tdKSh2b2lkKSA9IHsKIAlsb2NhbF9leGl0LAorCWRtX2RlYnVnZnNfZXhp
dCwKIAlkbV90YXJnZXRfZXhpdCwKIAlkbV9saW5lYXJfZXhpdCwKIAlkbV9zdHJpcGVfZXhpdCwK
QEAgLTE3ODEsNiArMTgyMiwxNCBAQCBzdGF0aWMgdm9pZCBfX3NwbGl0X2FuZF9wcm9jZXNzX2Jp
byhzdHJ1Y3QgbWFwcGVkX2RldmljZSAqbWQsCiAJCXJldHVybjsKIAl9CiAKKwlpZiAoYmlvX2Rh
dGFfZGlyKGJpbykgPT0gV1JJVEUpIHsKKwkJaWYgKGRiZ19lcnJvciAmJiAhc3RybmNtcChjdXJy
ZW50LT5jb21tLCAia3dvcmtlciIsIDcpICYmCisJCQkJKCsrZGJnX2Vycm9yX2NvdW50ZXIgPCBk
YmdfZXJyb3JfbWF4KSkgeworCQkJYmlvX2lvX2Vycm9yKGJpbyk7CisJCQlyZXR1cm47CisJCX0K
Kwl9CisKIAljaS5tYXAgPSBtYXA7CiAJY2kubWQgPSBtZDsKIAljaS5pbyA9IGFsbG9jX2lvKG1k
KTsKLS0gCjEuOS4xCgo=

--_003_842E055448A75D44BEB94DEB9E5166E91877AAF1irsmsx110gercor_
Content-Type: text/plain; name="dm-test.txt"
Content-Description: dm-test.txt
Content-Disposition: attachment; filename="dm-test.txt"; size=1553;
	creation-date="Wed, 01 Jun 2016 09:39:16 GMT";
	modification-date="Wed, 01 Jun 2016 09:39:16 GMT"
Content-Transfer-Encoding: base64

IyEvYmluL2Jhc2gKCkRJU0s9L2Rldi92ZGEKCkZJTEVfU0laRT01MAoKUEFSVF9OVU09MTAKUEFS
VF9HQj0yCgpwcmVwYXJlX3Rlc3QoKSB7CglwYXJ0ZWQgLXMgJERJU0sgbWt0YWJsZSBncHQKCWZv
ciBpIGluIGBzZXEgMSAxICRQQVJUX05VTWA7IGRvCgkJcGFydGVkIC1zIC1hIG9wdGltYWwgJERJ
U0sgbWtwYXJ0IHByaW1hcnkgXAoJCQkkKCggUEFSVF9HQiAqIChpIC0gMSkgKSlHaUIgJCgoIFBB
UlRfR0IgKiBpICkpR2lCCglkb25lCgoJZm9yIGkgaW4gYHNlcSAxIDEgJFBBUlRfTlVNYDsgZG8K
CQlTSVpFPWBibG9ja2RldiAtLWdldHNpemUgJHtESVNLfSR7aX1gCgkJZG1zZXR1cCBjcmVhdGUg
bGluZWFyJHtpfSAtLXRhYmxlIFwKCQkJIjAgJHtTSVpFfSBsaW5lYXIgJHtESVNLfSR7aX0gMCIK
CWRvbmUKCglzbGVlcCAyCgoJZm9yIGkgaW4gYHNlcSAxIDEgJFBBUlRfTlVNYDsgZG8KCQlta2Zz
LnhmcyAtZiAvZGV2L2RtLSQoKCBpIC0gMSApKQoJZG9uZQoKCWZvciBpIGluIGBzZXEgMSAxICRQ
QVJUX05VTWA7IGRvCgkJbWtkaXIgL21udC9wJHtpfQoJZG9uZQoKCWZvciBpIGluIGBzZXEgMSAx
ICRQQVJUX05VTWA7IGRvCgkJbW91bnQgL2Rldi9kbS0kKCggaSAtIDEgKSkgL21udC9wJHtpfQoJ
ZG9uZQp9CgpjbGVhbnVwX3Rlc3QoKSB7Cglmb3IgaSBpbiBgc2VxIDEgMSAkUEFSVF9OVU1gOyBk
bwoJCXVtb3VudCAvbW50L3Ake2l9Cglkb25lCgoJZm9yIGkgaW4gYHNlcSAxIDEgJFBBUlRfTlVN
YDsgZG8KCQlybSAtcmYgL21udC9wJHtpfQoJZG9uZQoKCWZvciBpIGluIGBzZXEgMSAxICRQQVJU
X05VTWA7IGRvCgkJZG1zZXR1cCByZW1vdmUgbGluZWFyJHtpfQoJZG9uZQp9CgppbmplY3RfZXJy
b3IoKSB7Cgl3aGlsZSB0cnVlOyBkbwoJCWVjaG8gIkVycm9yID0gMCIKCQllY2hvIDAgPiAvc3lz
L2tlcm5lbC9kZWJ1Zy9kbV9kZWJ1Zy9lcnJvcgoJCWVjaG8gMCA+IC9zeXMva2VybmVsL2RlYnVn
L2RtX2RlYnVnL2Vycm9yX2NvdW50ZXIKCQllY2hvIDEwMCA+IC9zeXMva2VybmVsL2RlYnVnL2Rt
X2RlYnVnL2Vycm9yX21heAoJCXNsZWVwIDEKCQllY2hvICJEcm9wIGNhY2hlcyIKCQllY2hvIDEg
PiAvcHJvYy9zeXMvdm0vZHJvcF9jYWNoZXMKCQlzbGVlcCAxCgkJZWNobyAiRXJyb3IgPSAxIgoJ
CWVjaG8gMSA+IC9zeXMva2VybmVsL2RlYnVnL2RtX2RlYnVnL2Vycm9yCgkJc2xlZXAgMwoJZG9u
ZQp9CgppbmplY3Rfc3RvcCgpIHsKCWVjaG8gMCA+IC9zeXMva2VybmVsL2RlYnVnL2RtX2RlYnVn
L2Vycm9yCn0KCnJ1bl90ZXN0KCkgewoJdHJ1bmNhdGUgLXMgMCBtZDVzdW0ubG9nCglpbmplY3Rf
ZXJyb3IgJgoJUElEPSQhCglmb3IgaSBpbiBgc2VxIDEgMSAkUEFSVF9OVU1gOyBkbwoJCWRkIGlm
PS9kZXYvdXJhbmRvbSBicz0xTSBjb3VudD0kRklMRV9TSVpFIG9mPS9tbnQvcCR7aX0vZmlsZQoJ
CW1kNXN1bSAvbW50L3Ake2l9L2ZpbGUgPj4gbWQ1c3VtLmxvZwoJZG9uZQoJa2lsbCAkUElECglp
bmplY3Rfc3RvcAoJbWQ1c3VtIC1jIG1kNXN1bS5sb2cKfQoKcHJlcGFyZV90ZXN0CnJ1bl90ZXN0
CmNsZWFudXBfdGVzdAo=

--_003_842E055448A75D44BEB94DEB9E5166E91877AAF1irsmsx110gercor_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
