Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5863E6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 04:33:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k12so89223049lfb.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 01:33:59 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id i187si4701766lfi.418.2016.09.17.01.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 01:33:57 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id g62so76144875lfe.3
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 01:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474085296.32273.95.camel@perches.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com> <1474085296.32273.95.camel@perches.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 17 Sep 2016 11:33:56 +0300
Message-ID: <CALYGNiNuF1Ggy=DyYG32HXbnJp3Q0cX9ekQ5w2jR1M9rkKaX9A@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: multipart/mixed; boundary=001a1142b6369e0ab7053caff0e7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a1142b6369e0ab7053caff0e7
Content-Type: text/plain; charset=UTF-8

On Sat, Sep 17, 2016 at 7:08 AM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2016-09-16 at 17:040700, Linus Torvalds wrote:
>> On Fri, Sep 16, 2016 at 4:58 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> > Here's a totally untested patch. What do people say?
>> Heh. It looks like "pr_xyz_once()" is used in places that haven't
>> included "ratelimit.h", so this doesn't actually build for everything.
>> But I guess as a concept patch it's not hard to understand, even if
>> the implementation needs a bit of tweaking.
>
> do_just_once just isn't a good name for a global
> rate limited mechanism that does something very
> different than the name.
>
> Maybe allow_once_per_ratelimit or the like
>
> There could be an equivalent do_once
>
> https://lkml.org/lkml/2009/5/22/3
>

What about this printk_reriodic() and pr_warn_once_per_minute()?

It simply remembers next jiffies to print rather than using that
complicated ratelimiting engine.

--001a1142b6369e0ab7053caff0e7
Content-Type: application/octet-stream;
	name=printk-add-pr_warn_once_per_minute
Content-Disposition: attachment;
	filename=printk-add-pr_warn_once_per_minute
Content-Transfer-Encoding: base64
X-Attachment-Id: f_it6xku9n0

cHJpbnRrOiBhZGQgcHJfd2Fybl9vbmNlX3Blcl9taW51dGUKCkZyb206IEtvbnN0YW50aW4gS2hs
ZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KClNpZ25lZC1vZmYtYnk6IEtvbnN0YW50aW4gS2hs
ZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KLS0tCiBpbmNsdWRlL2xpbnV4L3ByaW50ay5oIHwg
ICAxNiArKysrKysrKysrKysrKysrCiBtbS9tbWFwLmMgICAgICAgICAgICAgIHwgICAgMiArLQog
MiBmaWxlcyBjaGFuZ2VkLCAxNyBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9wcmludGsuaCBiL2luY2x1ZGUvbGludXgvcHJpbnRrLmgKaW5k
ZXggNjk2YTU2YmU3ZDNlLi5hZjE2NDY0ODNkYmIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgv
cHJpbnRrLmgKKysrIGIvaW5jbHVkZS9saW51eC9wcmludGsuaApAQCAtMzQxLDExICszNDEsMjQg
QEAgZXh0ZXJuIGFzbWxpbmthZ2Ugdm9pZCBkdW1wX3N0YWNrKHZvaWQpIF9fY29sZDsKIAl9CQkJ
CQkJCVwKIAl1bmxpa2VseShfX3JldF9wcmludF9vbmNlKTsJCQkJXAogfSkKKyNkZWZpbmUgcHJp
bnRrX3BlcmlvZGljKHBlcmlvZCwgZm10LCAuLi4pCQkJXAorKHsJCQkJCQkJCVwKKwlzdGF0aWMg
dW5zaWduZWQgbG9uZyBfX3ByaW50X25leHQgX19yZWFkX21vc3RseSA9IElOSVRJQUxfSklGRklF
UzsgXAorCWJvb2wgX19kb19wcmludCA9IHRpbWVfYWZ0ZXJfZXEoamlmZmllcywgX19wcmludF9u
ZXh0KTsgXAorCQkJCQkJCQlcCisJaWYgKF9fZG9fcHJpbnQpIHsJCQkJCVwKKwkJX19wcmludF9u
ZXh0ID0gamlmZmllcyArIChwZXJpb2QpOwkJXAorCQlwcmludGsoZm10LCAjI19fVkFfQVJHU19f
KTsJCQlcCisJfQkJCQkJCQlcCisJdW5saWtlbHkoX19kb19wcmludCk7CQkJCQlcCit9KQogI2Vs
c2UKICNkZWZpbmUgcHJpbnRrX29uY2UoZm10LCAuLi4pCQkJCQlcCiAJbm9fcHJpbnRrKGZtdCwg
IyNfX1ZBX0FSR1NfXykKICNkZWZpbmUgcHJpbnRrX2RlZmVycmVkX29uY2UoZm10LCAuLi4pCQkJ
CVwKIAlub19wcmludGsoZm10LCAjI19fVkFfQVJHU19fKQorI2RlZmluZSBwcmludGtfcGVyaW9k
aWMocGVyaW9kLCBmbXQsIC4uLikJCQlcCisJbm9fcHJpbnRrKGZtdCwgIyNfX1ZBX0FSR1NfXykK
ICNlbmRpZgogCiAjZGVmaW5lIHByX2VtZXJnX29uY2UoZm10LCAuLi4pCQkJCQlcCkBAIC0zNjUs
NiArMzc4LDkgQEAgZXh0ZXJuIGFzbWxpbmthZ2Ugdm9pZCBkdW1wX3N0YWNrKHZvaWQpIF9fY29s
ZDsKICNkZWZpbmUgcHJfY29udF9vbmNlKGZtdCwgLi4uKQkJCQkJXAogCXByaW50a19vbmNlKEtF
Uk5fQ09OVCBwcl9mbXQoZm10KSwgIyNfX1ZBX0FSR1NfXykKIAorI2RlZmluZSBwcl93YXJuX29u
Y2VfcGVyX21pbnV0ZShmbXQsIC4uLikJCQlcCisJcHJpbnRrX3BlcmlvZGljKEhaICogNjAsIEtF
Uk5fV0FSTklORyBwcl9mbXQoZm10KSwgIyNfX1ZBX0FSR1NfXykKKwogI2lmIGRlZmluZWQoREVC
VUcpCiAjZGVmaW5lIHByX2RldmVsX29uY2UoZm10LCAuLi4pCQkJCQlcCiAJcHJpbnRrX29uY2Uo
S0VSTl9ERUJVRyBwcl9mbXQoZm10KSwgIyNfX1ZBX0FSR1NfXykKZGlmZiAtLWdpdCBhL21tL21t
YXAuYyBiL21tL21tYXAuYwppbmRleCBjYTlkOTFiY2EwZDYuLjM0ZjlmYjJhZGNhYiAxMDA2NDQK
LS0tIGEvbW0vbW1hcC5jCisrKyBiL21tL21tYXAuYwpAQCAtMjkzNSw3ICsyOTM1LDcgQEAgYm9v
bCBtYXlfZXhwYW5kX3ZtKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB2bV9mbGFnc190IGZsYWdzLCB1
bnNpZ25lZCBsb25nIG5wYWdlcykKIAkJICAgIG1tLT5kYXRhX3ZtICsgbnBhZ2VzIDw9IHJsaW1p
dF9tYXgoUkxJTUlUX0RBVEEpID4+IFBBR0VfU0hJRlQpCiAJCQlyZXR1cm4gdHJ1ZTsKIAkJaWYg
KCFpZ25vcmVfcmxpbWl0X2RhdGEpIHsKLQkJCXByX3dhcm5fb25jZSgiJXMgKCVkKTogVm1EYXRh
ICVsdSBleGNlZWQgZGF0YSB1bGltaXQgJWx1LiBVcGRhdGUgbGltaXRzIG9yIHVzZSBib290IG9w
dGlvbiBpZ25vcmVfcmxpbWl0X2RhdGEuXG4iLAorCQkJcHJfd2Fybl9vbmNlX3Blcl9taW51dGUo
IiVzICglZCk6IFZtRGF0YSAlbHUgZXhjZWVkIGRhdGEgdWxpbWl0ICVsdS4gVXBkYXRlIGxpbWl0
cyBvciB1c2UgYm9vdCBvcHRpb24gaWdub3JlX3JsaW1pdF9kYXRhLlxuIiwKIAkJCQkgICAgIGN1
cnJlbnQtPmNvbW0sIGN1cnJlbnQtPnBpZCwKIAkJCQkgICAgIChtbS0+ZGF0YV92bSArIG5wYWdl
cykgPDwgUEFHRV9TSElGVCwKIAkJCQkgICAgIHJsaW1pdChSTElNSVRfREFUQSkpOwo=
--001a1142b6369e0ab7053caff0e7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
