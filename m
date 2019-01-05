Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0BB9C43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1B39222FE
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Ovm4s7qz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1B39222FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D278E012B; Sat,  5 Jan 2019 15:13:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DCBE8E00F9; Sat,  5 Jan 2019 15:13:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CB938E012B; Sat,  5 Jan 2019 15:13:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C25CA8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:13:23 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x9-v6so10766947ljd.21
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:13:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Pdi+Bg1i6iYAyJ/YB9jfmxDEJpBzO7ZGd7liVQjUxaA=;
        b=tsLGlJkaKL7SIajCljJMhRomRLgwjD+lMv/oLF6U6malIDIjVyhctSEXFG8x8KVWW8
         onYavlJq1NoY1FSSdI+iHK3Br3rLXe7MngozxdD82ux3fCHvjlJ5I9Af7YONqwmD+2SA
         EfnKsUBYc4zoIPXj1g3Iz4LUqR3uij3Szaa7LwHM46JEOvs1EFfD7DgyvC7oSUIPsApO
         1YcRXRJWKE1WRpKiysYzWh4XODX2PMkKP5bj5Q0PCxKugf6BWP9XY04VzPNiBmXjl8GO
         werR3atp40GhnaaZX7pGVx9jFuMS8jgF+dZNXJvD+XkjI5pnPUd/Z/SnMwVM+arEilFu
         eHxg==
X-Gm-Message-State: AA+aEWbhncUfvqRodyWBko8V5Qkfcs7xy17bi9ib7f854IhDRWIG04Rn
	e5fOEo9U1oOW9620V7tvKDVGmeiRQcvafwU+yb0VqUDKMnnbdUUGlUccCPuwXNch8P75h7ne08A
	n637pc9l0otJWlwSQjjUPtT/U0eNLihTrhSFxlhJykkWFRw8Avr/bWUMRqBQ5UrtIrIImE5ff19
	tx0KPN/9TlVfjaGJ5tvIP+z9bR3SrECKHEj647dxv99ZQ3NPxmInHIxcPsnV1/DAKb9o2/FXptW
	bLOYKmzrhY9d9QhbDaa6LGk6CeB+h3fhkQN/UHjNkZy54vQC8aWsfYDi6vrHGqi1X5xRYo0VG35
	agK/etdCVVinxpiJ4oXbwc/0iDu9WsEDy9sPsgOwXgsgRFGvvZHfJSHlPXzuGg2wrR5pzNc9SxK
	a
X-Received: by 2002:a19:3809:: with SMTP id f9mr26915420lfa.148.1546719202868;
        Sat, 05 Jan 2019 12:13:22 -0800 (PST)
X-Received: by 2002:a19:3809:: with SMTP id f9mr26915407lfa.148.1546719202287;
        Sat, 05 Jan 2019 12:13:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546719202; cv=none;
        d=google.com; s=arc-20160816;
        b=LIRCH/Ne3PRveLE5vbuzVV9ZTHqZyGoe2cCXDqlQRgkLCTFYg/JwFBurn7yWgA87Wm
         wDDDxWa63CYUZAT2PwGFmFKbwEE3LsB5au6roJxBppwCpcpWjQmIb2XafAJlQQhAThM8
         /m6WEnNwSP7OxEj5KVQ0gj70Z36fueuFH/9x4qtTN+1dBnIbLg/Q0R8dZaU5FIchaOs8
         Fe9omx5NMXtHeJ4FbY5po15Wg2TDEivhCBe8yLjVygdGIfA/o6+rKRLcUOKMc0g1VPVD
         UZFOM5fK2APTw98yleLvdkuKCHXqf+0AJj7kXVYRAh2jgYxDmjXx2VgWLlg2QQw3Q1mz
         HQow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Pdi+Bg1i6iYAyJ/YB9jfmxDEJpBzO7ZGd7liVQjUxaA=;
        b=H4MhgbTL0G57QcbXrayONJ4cqwFDa8qkkc2MVyzCV9lB8yAKJI9SeJ/FvKnX4MczfD
         CB7Fkc00pJxaG9SINDru5jIgtjKgFiGnx7GS3gqiNClBQXmh/keOvSub+ZmRqcZCw4jl
         ZhfyQl52+eZEgupsk2ZydEWH00rw68BkQSLWnBUMxKAMlWLbn10nsjl96nuLzySml1tW
         Wd5K6TDEDH2HV57zpCi03BQn3zm26EmjFIpmOz0xKfKXL+vF8mfRvwTOahcvR6p/cfMr
         2hWsfOjMasHQNxOsO63dp6tut3kWcKFwm0nf5OLntOJBY469UJ+ZUtdvvwOGCsEpIYwX
         a3eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Ovm4s7qz;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k25sor15478992lfj.26.2019.01.05.12.13.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 12:13:22 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Ovm4s7qz;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Pdi+Bg1i6iYAyJ/YB9jfmxDEJpBzO7ZGd7liVQjUxaA=;
        b=Ovm4s7qzBlZaFkhRQHYQAfhZuyMy8xnAoaOuLMym+53o/QgkGGfnxgHlttRFkYO0Gj
         7+uqgCM/NMv2jKFKNKxBNgXexzIvyLZduESW3zVSmxX5oY85FuDM23SDZkRu/VBjDrFH
         ktPUT1ftZfADhqSMujGo9gCGz4FRn/hgRLlz8=
X-Google-Smtp-Source: ALg8bN6+k3IVplDQEP4aiY2q3Eo+vNAmJ8s8GBMGKxcFmxdupU1CbTNaPCkgjk6gaBY5NUYj340Xzg==
X-Received: by 2002:a19:4948:: with SMTP id l8mr7114585lfj.156.1546719201634;
        Sat, 05 Jan 2019 12:13:21 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id h21sm12005426lfk.41.2019.01.05.12.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:13:19 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id y11so27602996lfj.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:13:18 -0800 (PST)
X-Received: by 2002:a19:3fcf:: with SMTP id m198mr26631654lfa.106.1546719198576;
 Sat, 05 Jan 2019 12:13:18 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
In-Reply-To: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 12:13:01 -0800
X-Gmail-Original-Message-ID: <CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com>
Message-ID:
 <CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org
Content-Type: multipart/mixed; boundary="0000000000006646d6057ebba023"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105201301.Ah9qlnOi-DZv01yBdmtP0dkFvfFTxuN6BGvc5uoyksE@z>

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

