Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 22561900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:00:55 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3CIxcnC015485
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:59:38 -0700
Received: by iwg8 with SMTP id 8so9709303iwg.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:59:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim6ATGxTiMcfK5-03azgcWuT4wtJA@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
 <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com> <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
 <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
 <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com> <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
 <BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com> <BANLkTim0MZfa8vFgHB3W6NsoPHp2jfirrA@mail.gmail.com>
 <BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com> <alpine.LSU.2.00.1104070718120.28555@sister.anvils>
 <BANLkTik_9YW5+64FHrzNy7kPz1FUWrw-rw@mail.gmail.com> <BANLkTiniyAN40p0q+2wxWsRZ5PJFn9zE0Q@mail.gmail.com>
 <BANLkTik6U21r91DYiUsz9A0P--=5QcsBrA@mail.gmail.com> <BANLkTim6ATGxTiMcfK5-03azgcWuT4wtJA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Apr 2011 11:59:18 -0700
Message-ID: <BANLkTiktvcBWsLKEk5iBYVEbPJS3i+U+hA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: multipart/mixed; boundary=0015176f0d283cb13b04a0bd4b62
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

--0015176f0d283cb13b04a0bd4b62
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 12, 2011 at 10:19 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> THIS IS A HACKY AND UNTESTED PATCH!

.. and here is a rather less hacky, but still equally untested patch.
It moves the stack guard page handling into __get_user_pages() itself,
and thus avoids the whole problem.

This one I could easily see myself committing. Assuming I get some
ack's and testing..

Comments?

                          Linus

--0015176f0d283cb13b04a0bd4b62
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmf6z1cm1

IG1tL21lbW9yeS5jIHwgICAyNiArKysrKysrKysrKysrKysrKystLS0tLS0tLQogbW0vbWxvY2su
YyAgfCAgIDEzIC0tLS0tLS0tLS0tLS0KIDIgZmlsZXMgY2hhbmdlZCwgMTggaW5zZXJ0aW9ucygr
KSwgMjEgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMgYi9tbS9tZW1vcnku
YwppbmRleCA5ZGE4Y2FiMWIxYjAuLmI2MjNhMjQ5OTE4YyAxMDA2NDQKLS0tIGEvbW0vbWVtb3J5
LmMKKysrIGIvbW0vbWVtb3J5LmMKQEAgLTE0MTAsNiArMTQxMCwxMyBAQCBub19wYWdlX3RhYmxl
OgogCXJldHVybiBwYWdlOwogfQogCitzdGF0aWMgaW5saW5lIGludCBzdGFja19ndWFyZF9wYWdl
KHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIpCit7CisJcmV0
dXJuICh2bWEtPnZtX2ZsYWdzICYgVk1fR1JPV1NET1dOKSAmJgorCQkodm1hLT52bV9zdGFydCA9
PSBhZGRyKSAmJgorCQkhdm1hX3N0YWNrX2NvbnRpbnVlKHZtYS0+dm1fcHJldiwgYWRkcik7Cit9
CisKIC8qKgogICogX19nZXRfdXNlcl9wYWdlcygpIC0gcGluIHVzZXIgcGFnZXMgaW4gbWVtb3J5
CiAgKiBAdHNrOgl0YXNrX3N0cnVjdCBvZiB0YXJnZXQgdGFzawpAQCAtMTQ4OCw3ICsxNDk1LDYg
QEAgaW50IF9fZ2V0X3VzZXJfcGFnZXMoc3RydWN0IHRhc2tfc3RydWN0ICp0c2ssIHN0cnVjdCBt
bV9zdHJ1Y3QgKm1tLAogCQl2bWEgPSBmaW5kX2V4dGVuZF92bWEobW0sIHN0YXJ0KTsKIAkJaWYg
KCF2bWEgJiYgaW5fZ2F0ZV9hcmVhKG1tLCBzdGFydCkpIHsKIAkJCXVuc2lnbmVkIGxvbmcgcGcg
PSBzdGFydCAmIFBBR0VfTUFTSzsKLQkJCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqZ2F0ZV92bWEg
PSBnZXRfZ2F0ZV92bWEobW0pOwogCQkJcGdkX3QgKnBnZDsKIAkJCXB1ZF90ICpwdWQ7CiAJCQlw
bWRfdCAqcG1kOwpAQCAtMTUxMywxMCArMTUxOSwxMSBAQCBpbnQgX19nZXRfdXNlcl9wYWdlcyhz
dHJ1Y3QgdGFza19zdHJ1Y3QgKnRzaywgc3RydWN0IG1tX3N0cnVjdCAqbW0sCiAJCQkJcHRlX3Vu
bWFwKHB0ZSk7CiAJCQkJcmV0dXJuIGkgPyA6IC1FRkFVTFQ7CiAJCQl9CisJCQl2bWEgPSBnZXRf
Z2F0ZV92bWEobW0pOwogCQkJaWYgKHBhZ2VzKSB7CiAJCQkJc3RydWN0IHBhZ2UgKnBhZ2U7CiAK
LQkJCQlwYWdlID0gdm1fbm9ybWFsX3BhZ2UoZ2F0ZV92bWEsIHN0YXJ0LCAqcHRlKTsKKwkJCQlw
YWdlID0gdm1fbm9ybWFsX3BhZ2Uodm1hLCBzdGFydCwgKnB0ZSk7CiAJCQkJaWYgKCFwYWdlKSB7
CiAJCQkJCWlmICghKGd1cF9mbGFncyAmIEZPTExfRFVNUCkgJiYKIAkJCQkJICAgICBpc196ZXJv
X3BmbihwdGVfcGZuKCpwdGUpKSkKQEAgLTE1MzAsMTIgKzE1MzcsNyBAQCBpbnQgX19nZXRfdXNl
cl9wYWdlcyhzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRzaywgc3RydWN0IG1tX3N0cnVjdCAqbW0sCiAJ
CQkJZ2V0X3BhZ2UocGFnZSk7CiAJCQl9CiAJCQlwdGVfdW5tYXAocHRlKTsKLQkJCWlmICh2bWFz
KQotCQkJCXZtYXNbaV0gPSBnYXRlX3ZtYTsKLQkJCWkrKzsKLQkJCXN0YXJ0ICs9IFBBR0VfU0la
RTsKLQkJCW5yX3BhZ2VzLS07Ci0JCQljb250aW51ZTsKKwkJCWdvdG8gbmV4dF9wYWdlOwogCQl9
CiAKIAkJaWYgKCF2bWEgfHwKQEAgLTE1NDksNiArMTU1MSwxMyBAQCBpbnQgX19nZXRfdXNlcl9w
YWdlcyhzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRzaywgc3RydWN0IG1tX3N0cnVjdCAqbW0sCiAJCQlj
b250aW51ZTsKIAkJfQogCisJCS8qCisJCSAqIElmIHdlIGRvbid0IGFjdHVhbGx5IHdhbnQgdGhl
IHBhZ2UgaXRzZWxmLAorCQkgKiBhbmQgaXQncyB0aGUgc3RhY2sgZ3VhcmQgcGFnZSwganVzdCBz
a2lwIGl0LgorCQkgKi8KKwkJaWYgKCFwYWdlcyAmJiBzdGFja19ndWFyZF9wYWdlKHZtYSwgc3Rh
cnQpKQorCQkJZ290byBuZXh0X3BhZ2U7CisKIAkJZG8gewogCQkJc3RydWN0IHBhZ2UgKnBhZ2U7
CiAJCQl1bnNpZ25lZCBpbnQgZm9sbF9mbGFncyA9IGd1cF9mbGFnczsKQEAgLTE2MzEsNiArMTY0
MCw3IEBAIGludCBfX2dldF91c2VyX3BhZ2VzKHN0cnVjdCB0YXNrX3N0cnVjdCAqdHNrLCBzdHJ1
Y3QgbW1fc3RydWN0ICptbSwKIAkJCQlmbHVzaF9hbm9uX3BhZ2Uodm1hLCBwYWdlLCBzdGFydCk7
CiAJCQkJZmx1c2hfZGNhY2hlX3BhZ2UocGFnZSk7CiAJCQl9CituZXh0X3BhZ2U6CiAJCQlpZiAo
dm1hcykKIAkJCQl2bWFzW2ldID0gdm1hOwogCQkJaSsrOwpkaWZmIC0tZ2l0IGEvbW0vbWxvY2su
YyBiL21tL21sb2NrLmMKaW5kZXggMjY4OWEwOGM3OWFmLi42YjU1ZTNlZmUwZGYgMTAwNjQ0Ci0t
LSBhL21tL21sb2NrLmMKKysrIGIvbW0vbWxvY2suYwpAQCAtMTM1LDEzICsxMzUsNiBAQCB2b2lk
IG11bmxvY2tfdm1hX3BhZ2Uoc3RydWN0IHBhZ2UgKnBhZ2UpCiAJfQogfQogCi1zdGF0aWMgaW5s
aW5lIGludCBzdGFja19ndWFyZF9wYWdlKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNp
Z25lZCBsb25nIGFkZHIpCi17Ci0JcmV0dXJuICh2bWEtPnZtX2ZsYWdzICYgVk1fR1JPV1NET1dO
KSAmJgotCQkodm1hLT52bV9zdGFydCA9PSBhZGRyKSAmJgotCQkhdm1hX3N0YWNrX2NvbnRpbnVl
KHZtYS0+dm1fcHJldiwgYWRkcik7Ci19Ci0KIC8qKgogICogX19tbG9ja192bWFfcGFnZXNfcmFu
Z2UoKSAtICBtbG9jayBhIHJhbmdlIG9mIHBhZ2VzIGluIHRoZSB2bWEuCiAgKiBAdm1hOiAgIHRh
cmdldCB2bWEKQEAgLTE4OCwxMiArMTgxLDYgQEAgc3RhdGljIGxvbmcgX19tbG9ja192bWFfcGFn
ZXNfcmFuZ2Uoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiAJaWYgKHZtYS0+dm1fZmxhZ3Mg
JiBWTV9MT0NLRUQpCiAJCWd1cF9mbGFncyB8PSBGT0xMX01MT0NLOwogCi0JLyogV2UgZG9uJ3Qg
dHJ5IHRvIGFjY2VzcyB0aGUgZ3VhcmQgcGFnZSBvZiBhIHN0YWNrIHZtYSAqLwotCWlmIChzdGFj
a19ndWFyZF9wYWdlKHZtYSwgc3RhcnQpKSB7Ci0JCWFkZHIgKz0gUEFHRV9TSVpFOwotCQlucl9w
YWdlcy0tOwotCX0KLQogCXJldHVybiBfX2dldF91c2VyX3BhZ2VzKGN1cnJlbnQsIG1tLCBhZGRy
LCBucl9wYWdlcywgZ3VwX2ZsYWdzLAogCQkJCU5VTEwsIE5VTEwsIG5vbmJsb2NraW5nKTsKIH0K
--0015176f0d283cb13b04a0bd4b62--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
