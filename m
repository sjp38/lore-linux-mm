Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADDD86B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 10:37:06 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b202so40293955oii.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 07:37:06 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0063.outbound.protection.outlook.com. [104.47.1.63])
        by mx.google.com with ESMTPS id t128si17248322oig.117.2016.12.09.07.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 07:37:06 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id f82so30639564wmf.1
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 07:37:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACKey4xPsu5_-YcYNWv3xV-9s7heedOkURyOM8m4PJc=4EVQ2Q@mail.gmail.com>
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
 <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz> <CACKey4yB_qXdRn1=qNu65GA0ER-DL+DEqhP9QRGkWX79jVao8g@mail.gmail.com>
 <ef9a07bc-e0d9-46ed-8898-7db6b1d4cb9f@suse.cz> <CACKey4xPsu5_-YcYNWv3xV-9s7heedOkURyOM8m4PJc=4EVQ2Q@mail.gmail.com>
From: Federico Reghenzani <federico.reghenzani@polimi.it>
Date: Fri, 9 Dec 2016 16:36:40 +0100
Message-ID: <CACKey4wD_NwO=eGvbn_ugVRR1Dxa=FtwBdpMY2PcTX86i6k9KQ@mail.gmail.com>
Subject: Re: mlockall() with pid parameter
Content-Type: multipart/mixed; boundary="94eb2c0d45827098a305433b866f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--94eb2c0d45827098a305433b866f
Content-Type: multipart/alternative; boundary="94eb2c0d458270989f05433b866d"

--94eb2c0d458270989f05433b866d
Content-Type: text/plain; charset="UTF-8"

I attached a patch proposal, it adds mlockall_pid() and munlockall_pid()
syscalls (I've included only the mm/mlock.c file).

I generalized the present code to work on a pointer `p` that in case of
mlockall() and munlockall() corresponds to `current`.
Instead, with mlockall_pid() and munlockall_pid(), after permission checks,
it gets the task_struct from find_task_by_vpid.

I tested the syscalls and they seem ok, but I'm not sure how to test them
thoroughly.


Cheers,
Federico

--94eb2c0d458270989f05433b866d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I attached a patch proposal, it adds mlockall_pid() and mu=
nlockall_pid() syscalls (I&#39;ve included only the mm/mlock.c file).<div><=
br></div><div>I generalized the present code to work on a pointer `p` that =
in case of mlockall() and munlockall() corresponds to `current`.</div><div>=
Instead, with mlockall_pid() and munlockall_pid(), after permission checks,=
 it gets the task_struct from find_task_by_vpid.</div><div><br></div><div>I=
 tested the syscalls and they seem ok, but I&#39;m not sure how to test the=
m thoroughly.</div><div class=3D"gmail_extra"><div class=3D"gmail_signature=
" data-smartmail=3D"gmail_signature"><div dir=3D"ltr"><br></div><div dir=3D=
"ltr"><br></div><div dir=3D"ltr">Cheers,</div><div dir=3D"ltr">Federico<br>=
<div><br></div></div></div>
</div></div>

--94eb2c0d458270989f05433b866d--

--94eb2c0d45827098a305433b866f
Content-Type: text/x-patch; charset="US-ASCII"; name="mlock.patch"
Content-Disposition: attachment; filename="mlock.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iwhydtya0

ZGlmZiAtLWdpdCBhL21tL21sb2NrLmMgYi9tbS9tbG9jay5jCmluZGV4IGNkYmVkOGEuLmYxYzRi
ZGMgMTAwNjQ0Ci0tLSBhL21tL21sb2NrLmMKKysrIGIvbW0vbWxvY2suYwpAQCAtNzUyLDE3ICs3
NTIsMTcgQEAgU1lTQ0FMTF9ERUZJTkUyKG11bmxvY2ssIHVuc2lnbmVkIGxvbmcsIHN0YXJ0LCBz
aXplX3QsIGxlbikKICAqIGlzIGNhbGxlZCBvbmNlIGluY2x1ZGluZyB0aGUgTUNMX0ZVVFVSRSBm
bGFnIGFuZCB0aGVuIGEgc2Vjb25kIHRpbWUgd2l0aG91dAogICogaXQsIFZNX0xPQ0tFRCBhbmQg
Vk1fTE9DS09ORkFVTFQgd2lsbCBiZSBjbGVhcmVkIGZyb20gbW0tPmRlZl9mbGFncy4KICAqLwot
c3RhdGljIGludCBhcHBseV9tbG9ja2FsbF9mbGFncyhpbnQgZmxhZ3MpCitzdGF0aWMgaW50IGFw
cGx5X21sb2NrYWxsX2ZsYWdzKHN0cnVjdCB0YXNrX3N0cnVjdCAqcCwgaW50IGZsYWdzKQogewog
CXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqIHZtYSwgKiBwcmV2ID0gTlVMTDsKIAl2bV9mbGFnc190
IHRvX2FkZCA9IDA7CiAKLQljdXJyZW50LT5tbS0+ZGVmX2ZsYWdzICY9IFZNX0xPQ0tFRF9DTEVB
Ul9NQVNLOworCXAtPm1tLT5kZWZfZmxhZ3MgJj0gVk1fTE9DS0VEX0NMRUFSX01BU0s7CiAJaWYg
KGZsYWdzICYgTUNMX0ZVVFVSRSkgewotCQljdXJyZW50LT5tbS0+ZGVmX2ZsYWdzIHw9IFZNX0xP
Q0tFRDsKKwkJcC0+bW0tPmRlZl9mbGFncyB8PSBWTV9MT0NLRUQ7CiAKIAkJaWYgKGZsYWdzICYg
TUNMX09ORkFVTFQpCi0JCQljdXJyZW50LT5tbS0+ZGVmX2ZsYWdzIHw9IFZNX0xPQ0tPTkZBVUxU
OworCQkJcC0+bW0tPmRlZl9mbGFncyB8PSBWTV9MT0NLT05GQVVMVDsKIAogCQlpZiAoIShmbGFn
cyAmIE1DTF9DVVJSRU5UKSkKIAkJCWdvdG8gb3V0OwpAQCAtNzc0LDcgKzc3NCw3IEBAIHN0YXRp
YyBpbnQgYXBwbHlfbWxvY2thbGxfZmxhZ3MoaW50IGZsYWdzKQogCQkJdG9fYWRkIHw9IFZNX0xP
Q0tPTkZBVUxUOwogCX0KIAotCWZvciAodm1hID0gY3VycmVudC0+bW0tPm1tYXA7IHZtYSA7IHZt
YSA9IHByZXYtPnZtX25leHQpIHsKKwlmb3IgKHZtYSA9IHAtPm1tLT5tbWFwOyB2bWEgOyB2bWEg
PSBwcmV2LT52bV9uZXh0KSB7CiAJCXZtX2ZsYWdzX3QgbmV3ZmxhZ3M7CiAKIAkJbmV3ZmxhZ3Mg
PSB2bWEtPnZtX2ZsYWdzICYgVk1fTE9DS0VEX0NMRUFSX01BU0s7CkBAIC03ODgsNyArNzg4LDcg
QEAgc3RhdGljIGludCBhcHBseV9tbG9ja2FsbF9mbGFncyhpbnQgZmxhZ3MpCiAJcmV0dXJuIDA7
CiB9CiAKLVNZU0NBTExfREVGSU5FMShtbG9ja2FsbCwgaW50LCBmbGFncykKK3N0YXRpYyBpbnQg
X21sb2NrYWxsKHN0cnVjdCB0YXNrX3N0cnVjdCAqcCwgaW50IGZsYWdzKQogewogCXVuc2lnbmVk
IGxvbmcgbG9ja19saW1pdDsKIAlpbnQgcmV0OwpAQCAtODA1LDMxICs4MDUsMTMyIEBAIFNZU0NB
TExfREVGSU5FMShtbG9ja2FsbCwgaW50LCBmbGFncykKIAlsb2NrX2xpbWl0ID0gcmxpbWl0KFJM
SU1JVF9NRU1MT0NLKTsKIAlsb2NrX2xpbWl0ID4+PSBQQUdFX1NISUZUOwogCi0JaWYgKGRvd25f
d3JpdGVfa2lsbGFibGUoJmN1cnJlbnQtPm1tLT5tbWFwX3NlbSkpCisJaWYgKGRvd25fd3JpdGVf
a2lsbGFibGUoJnAtPm1tLT5tbWFwX3NlbSkpCiAJCXJldHVybiAtRUlOVFI7CiAKIAlyZXQgPSAt
RU5PTUVNOwotCWlmICghKGZsYWdzICYgTUNMX0NVUlJFTlQpIHx8IChjdXJyZW50LT5tbS0+dG90
YWxfdm0gPD0gbG9ja19saW1pdCkgfHwKKwlpZiAoIShmbGFncyAmIE1DTF9DVVJSRU5UKSB8fCAo
cC0+bW0tPnRvdGFsX3ZtIDw9IGxvY2tfbGltaXQpIHx8CiAJICAgIGNhcGFibGUoQ0FQX0lQQ19M
T0NLKSkKLQkJcmV0ID0gYXBwbHlfbWxvY2thbGxfZmxhZ3MoZmxhZ3MpOwotCXVwX3dyaXRlKCZj
dXJyZW50LT5tbS0+bW1hcF9zZW0pOworCQlyZXQgPSBhcHBseV9tbG9ja2FsbF9mbGFncyhwLCBm
bGFncyk7CisJdXBfd3JpdGUoJnAtPm1tLT5tbWFwX3NlbSk7CiAJaWYgKCFyZXQgJiYgKGZsYWdz
ICYgTUNMX0NVUlJFTlQpKQogCQltbV9wb3B1bGF0ZSgwLCBUQVNLX1NJWkUpOwogCiAJcmV0dXJu
IHJldDsKIH0KIAotU1lTQ0FMTF9ERUZJTkUwKG11bmxvY2thbGwpCitzdGF0aWMgaW50IF9tdW5s
b2NrYWxsKHN0cnVjdCB0YXNrX3N0cnVjdCAqcCkKIHsKIAlpbnQgcmV0OwogCi0JaWYgKGRvd25f
d3JpdGVfa2lsbGFibGUoJmN1cnJlbnQtPm1tLT5tbWFwX3NlbSkpCisJaWYgKGRvd25fd3JpdGVf
a2lsbGFibGUoJnAtPm1tLT5tbWFwX3NlbSkpCiAJCXJldHVybiAtRUlOVFI7Ci0JcmV0ID0gYXBw
bHlfbWxvY2thbGxfZmxhZ3MoMCk7Ci0JdXBfd3JpdGUoJmN1cnJlbnQtPm1tLT5tbWFwX3NlbSk7
CisJcmV0ID0gYXBwbHlfbWxvY2thbGxfZmxhZ3MocCwgMCk7CisJdXBfd3JpdGUoJnAtPm1tLT5t
bWFwX3NlbSk7CisKKwlyZXR1cm4gcmV0OworfQorCitzdGF0aWMgYm9vbCBjaGVja19zYW1lX293
bmVyKHN0cnVjdCB0YXNrX3N0cnVjdCAqcCkKK3sKKwljb25zdCBzdHJ1Y3QgY3JlZCAqY3JlZCA9
IGN1cnJlbnRfY3JlZCgpLCAqcGNyZWQ7CisJYm9vbCBtYXRjaDsKKworCXJjdV9yZWFkX2xvY2so
KTsKKwlwY3JlZCA9IF9fdGFza19jcmVkKHApOworCW1hdGNoID0gKHVpZF9lcShjcmVkLT5ldWlk
LCBwY3JlZC0+ZXVpZCkgfHwKKwl1aWRfZXEoY3JlZC0+ZXVpZCwgcGNyZWQtPnVpZCkpOworCXJj
dV9yZWFkX3VubG9jaygpOworCXJldHVybiBtYXRjaDsKK30KKworLyoKKyAqIENoZWNrIHRoZSBw
ZXJtaXNzaW9uIHRvIGV4ZWMgdGhlIG1sb2NrYWxsX3BpZCBhbmQgbXVubG9ja2FsbF9waWQgYW5k
IHdyaXRlCisgKiB0aGUgc3RydWN0IGNvcnJlc3BvbmRpbmcgdG8gdGhlIHBpZCBwcm92aWRlZC4K
KyAqLworc3RhdGljIGludCBjaGVja19hbmRfZ2V0X3Byb2Nlc3MocGlkX3QgcGlkLCBzdHJ1Y3Qg
dGFza19zdHJ1Y3QgKipwKQoreworCSpwID0gTlVMTDsKKworCWlmIChwaWQgPCAwKQorCQlyZXR1
cm4gLUVJTlZBTDsKKworCWlmIChwaWQgPT0gMCkgeworCQkqcCA9IGN1cnJlbnQ7CisJCXJldHVy
biAwOworCX0KKworCXJjdV9yZWFkX2xvY2soKTsKKwkqcCA9IGZpbmRfdGFza19ieV92cGlkKHBp
ZCk7CisKKwlpZiAoKnAgPT0gTlVMTCkgeworCQlyY3VfcmVhZF91bmxvY2soKTsKKwkJcmV0dXJu
IC1FU1JDSDsKKwl9CisKKwlpZiAoKCpwKS0+ZmxhZ3MgJiBQRl9LVEhSRUFEKSAgeworCQlyY3Vf
cmVhZF91bmxvY2soKTsKKwkJcmV0dXJuIC1FSU5WQUw7CisJfQorCisJLyogUHJldmVudCBwIGdv
aW5nIGF3YXkgKi8KKwlnZXRfdGFza19zdHJ1Y3QoKnApOworCXJjdV9yZWFkX3VubG9jaygpOwor
CisJaWYgKCFjaGVja19zYW1lX293bmVyKCpwKSAmJiAhY2FwYWJsZShDQVBfSVBDX0xPQ0spKSB7
CisJCXB1dF90YXNrX3N0cnVjdCgqcCk7CisJCXJldHVybiAtRVBFUk07CisJfQorCisJcmV0dXJu
IDA7Cit9CisKK1NZU0NBTExfREVGSU5FMShtbG9ja2FsbCwgaW50LCBmbGFncykKK3sKKwlyZXR1
cm4gX21sb2NrYWxsKGN1cnJlbnQsIGZsYWdzKTsKK30KKworU1lTQ0FMTF9ERUZJTkUwKG11bmxv
Y2thbGwpCit7CisJcmV0dXJuIF9tdW5sb2NrYWxsKGN1cnJlbnQpOworfQorCitTWVNDQUxMX0RF
RklORTIobWxvY2thbGxfcGlkLCBwaWRfdCwgcGlkLCBpbnQsIGZsYWdzKQoreworCWludCByZXQ7
CisJc3RydWN0IHRhc2tfc3RydWN0ICpwOworCisJcmV0ID0gY2hlY2tfYW5kX2dldF9wcm9jZXNz
KHBpZCwgJnApOworCisJaWYgKHJldCkKKwkJcmV0dXJuIHJldDsKKworCXJldCA9IF9tbG9ja2Fs
bChwLCBmbGFncyk7CisKKwlpZiAocCAhPSBjdXJyZW50KQorCQlwdXRfdGFza19zdHJ1Y3QocCk7
CisKIAlyZXR1cm4gcmV0OwogfQogCitTWVNDQUxMX0RFRklORTEobXVubG9ja2FsbF9waWQsIHBp
ZF90LCBwaWQpCit7CisJaW50IHJldDsKKwlzdHJ1Y3QgdGFza19zdHJ1Y3QgKnA7CisKKwlyZXQg
PSBjaGVja19hbmRfZ2V0X3Byb2Nlc3MocGlkLCAmcCk7CisJaWYgKHJldCkKKwkJcmV0dXJuIHJl
dDsKKworCXJldCA9IF9tdW5sb2NrYWxsKHApOworCisJaWYgKHAgIT0gY3VycmVudCkKKwkJcHV0
X3Rhc2tfc3RydWN0KHApOworCisJcmV0dXJuIHJldDsKK30KKworCiAvKgogICogT2JqZWN0cyB3
aXRoIGRpZmZlcmVudCBsaWZldGltZSB0aGFuIHByb2Nlc3NlcyAoU0hNX0xPQ0sgYW5kIFNITV9I
VUdFVExCCiAgKiBzaG0gc2VnbWVudHMpIGdldCBhY2NvdW50ZWQgYWdhaW5zdCB0aGUgdXNlcl9z
dHJ1Y3QgaW5zdGVhZC4K
--94eb2c0d45827098a305433b866f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
