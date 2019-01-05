Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C25CA8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:13:23 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x9-v6so10766947ljd.21
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:13:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k25sor15478992lfj.26.2019.01.05.12.13.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 12:13:22 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id h21sm12005426lfk.41.2019.01.05.12.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:13:19 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id y11so27602996lfj.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:13:18 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
In-Reply-To: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 12:13:01 -0800
Message-ID: <CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: multipart/mixed; boundary="0000000000006646d6057ebba023"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

--0000000000006646d6057ebba023
Content-Type: text/plain; charset="UTF-8"

On Sat, Jan 5, 2019 at 11:46 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Can we please just limit it to vma's that are either anonymous, or map
> a file that the user actually owns?

.. or slightly simpler: a file that the user opened for writing.

IOW, some (TOTALLY UNTESTED!) patch like this?

               Linus

--0000000000006646d6057ebba023
Content-Type: text/x-patch; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jqjwnxes0>
X-Attachment-Id: f_jqjwnxes0

IG1tL21pbmNvcmUuYyB8IDE0ICsrKysrKysrKysrKystCiAxIGZpbGUgY2hhbmdlZCwgMTMgaW5z
ZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL21tL21pbmNvcmUuYyBiL21t
L21pbmNvcmUuYwppbmRleCAyMTgwOTliNWVkMzEuLjYxZTM4ODk1ZmIwMiAxMDA2NDQKLS0tIGEv
bW0vbWluY29yZS5jCisrKyBiL21tL21pbmNvcmUuYwpAQCAtMTY5LDYgKzE2OSwxMyBAQCBzdGF0
aWMgaW50IG1pbmNvcmVfcHRlX3JhbmdlKHBtZF90ICpwbWQsIHVuc2lnbmVkIGxvbmcgYWRkciwg
dW5zaWduZWQgbG9uZyBlbmQsCiAJcmV0dXJuIDA7CiB9CiAKK3N0YXRpYyBpbmxpbmUgYm9vbCBj
YW5fZG9fbWluY29yZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkKK3sKKwlyZXR1cm4gdm1h
X2lzX2Fub255bW91cyh2bWEpCisJCXx8ICh2bWEtPnZtX2ZpbGUgJiYgKHZtYS0+dm1fZmlsZS0+
Zl9tb2RlICYgRk1PREVfV1JJVEUpKQorCQl8fCBjYXBhYmxlKENBUF9TWVNfQURNSU4pOworfQor
CiAvKgogICogRG8gYSBjaHVuayBvZiAic3lzX21pbmNvcmUoKSIuIFdlJ3ZlIGFscmVhZHkgY2hl
Y2tlZAogICogYWxsIHRoZSBhcmd1bWVudHMsIHdlIGhvbGQgdGhlIG1tYXAgc2VtYXBob3JlOiB3
ZSBzaG91bGQKQEAgLTE4OSw4ICsxOTYsMTMgQEAgc3RhdGljIGxvbmcgZG9fbWluY29yZSh1bnNp
Z25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgcGFnZXMsIHVuc2lnbmVkIGNoYXIgKnYKIAl2
bWEgPSBmaW5kX3ZtYShjdXJyZW50LT5tbSwgYWRkcik7CiAJaWYgKCF2bWEgfHwgYWRkciA8IHZt
YS0+dm1fc3RhcnQpCiAJCXJldHVybiAtRU5PTUVNOwotCW1pbmNvcmVfd2Fsay5tbSA9IHZtYS0+
dm1fbW07CiAJZW5kID0gbWluKHZtYS0+dm1fZW5kLCBhZGRyICsgKHBhZ2VzIDw8IFBBR0VfU0hJ
RlQpKTsKKwlpZiAoIWNhbl9kb19taW5jb3JlKHZtYSkpIHsKKwkJdW5zaWduZWQgbG9uZyBwYWdl
cyA9IChlbmQgLSBhZGRyKSA+PiBQQUdFX1NISUZUOworCQltZW1zZXQodmVjLCAxLCBwYWdlcyk7
CisJCXJldHVybiBwYWdlczsKKwl9CisJbWluY29yZV93YWxrLm1tID0gdm1hLT52bV9tbTsKIAll
cnIgPSB3YWxrX3BhZ2VfcmFuZ2UoYWRkciwgZW5kLCAmbWluY29yZV93YWxrKTsKIAlpZiAoZXJy
IDwgMCkKIAkJcmV0dXJuIGVycjsK
--0000000000006646d6057ebba023--
