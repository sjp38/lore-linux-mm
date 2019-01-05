Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A32C7C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4634C222BD
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="GX6t7spD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4634C222BD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D934D8E0132; Sat,  5 Jan 2019 18:16:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D427C8E00F9; Sat,  5 Jan 2019 18:16:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C59F08E0132; Sat,  5 Jan 2019 18:16:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54CDB8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:16:52 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id s64-v6so10865902lje.19
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:16:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V7trfwmfneYK4SSNw/SfOGj8r9QOI6ygQ5c1r2wUbls=;
        b=ZbMj1CYAHUtXL9R+WHqsFBzPfAFMMwP571pHnqtMWx48OhwTtavqaca2B5+tIXSf40
         iheSoiclh8KHB+SMzwoD0p/geb3MhyXR5ZSIlGc9vhtxEjM5wLda5syZC3hITNsMRS/j
         qGJFpX+4LiDim+cstcMZ1+nl6fycGxO5gv6FyCzKfbOKBIQ8HXpC+qPxKr5tckAdECGz
         KP3BLpqvBE3sB+bg6RBEddsvRIvuBoSjvtoIP6Kt7XfSYQM82z44om+8aGMYamu5hSl9
         /DeQeILUtpAm2eKSer6Gad2YhLKoaV0ig/eTMl4NUb8uQXyAc3EG7+7G0EXtOwlkqXtd
         8IrQ==
X-Gm-Message-State: AJcUukfaxpz/aTvFKVtvCz+C/GuKr0b8V/2AZ69hKQ8o/5V8LQtwjXy7
	QxcfsFJXUCscxU62Qhbkwg+PsqYcbdDVY/kwPh8gtKFw+a74ePhsOF3E0oYWgbOFCftmgOdOCrb
	QIR0lzH6N7baWBvZTTcMBEdBnIwzp0SdXiBxa4fcMI+wsK1e7WIzUScmoju5IANXBfQ2YvXeSQy
	MnurVjoi047iamujJMCglbcumVp/vBickW0pGOlPC2FJhLM6+o6WV6WRA8AUK4l8WE268/fLIUL
	5BlfbkAJ0Fs+2Hio4unlE/M3Wphyz3Fm+mo7Osu4fKBsfB0lrmlSYAhwRjdaY4mgC2J1YtkqQ78
	Og43X/M/PdtDLa9hZIpReONhnSQOLUXffQkeV9Atp4e8422FfiYUtJ7xdWGG4FxjjGVgg9YC0t1
	W
X-Received: by 2002:ac2:55a3:: with SMTP id y3mr1845613lfg.93.1546730211731;
        Sat, 05 Jan 2019 15:16:51 -0800 (PST)
X-Received: by 2002:ac2:55a3:: with SMTP id y3mr1845606lfg.93.1546730211037;
        Sat, 05 Jan 2019 15:16:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546730211; cv=none;
        d=google.com; s=arc-20160816;
        b=n27PMsieeFemp9tfcmD5UOiliTITuEJFBuIbtVb5dWxRpB0IvvoAGXy6xHYyVBtHH+
         4w0jlMUYNSEAEa5DuusBwqITF41yqnDf0zekJFpPbc9qJk0283n9pKUG8fVXXioLk+Xr
         iA324nJ+Pjv19ha279vrabY0ZgoI5znPF8yKtXhgA+3yirAgkf2q6gwJWNklf7GoDnsW
         Ok6qzmggALXV/ZzqPXwTDwIJdfSr+2IPovcEh7+k1CtHNPyXyNxxEulJpjEr9yrjiHaD
         Ix/4o8JiW3lpxXhlQoorHG5Qdcb4ytDMdPExTM9TQxEIeBBmohloSb8piGs+eOOU3ae2
         3B2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V7trfwmfneYK4SSNw/SfOGj8r9QOI6ygQ5c1r2wUbls=;
        b=S974FIvmQsNaqzKgatXe3v/Dr9GJevNQ9NNxp1qoMnhaxYRh8evKgiw1gewKJ8YwDC
         3faLPsL4o0CZOXs/mM/yTf2IQ4J7uOwjJcwKgZGTY/UCGEMKRFn0AHlzwZe8NHdFdio7
         7IwuJeNYUym00XvU99J4AjILdQvRj7mu5oKUpOeiSfs4SoqBnvdoYtxx3Yxu55xdNlW2
         499BGgjdA5/S0qU7ZeZia3xsc0H3bnrqcrDlb87uzmRVj/+kaWDQTnuSaHJ6ZYfEPRjG
         fX7VQdXqoDuQH4cni7GmgOjl+Ktk1V6LLDW+Bj2sNSKuhD4AA9+rdoo1uEpOyIHHs2on
         SdSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GX6t7spD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u66sor15304574lff.39.2019.01.05.15.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:16:50 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GX6t7spD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V7trfwmfneYK4SSNw/SfOGj8r9QOI6ygQ5c1r2wUbls=;
        b=GX6t7spD5TCxKk9/FB+FddDtgEmf/Maam6t7a9rOK2vbaIIrD7ipWwjLrJy7cSGVdH
         R+Qiu4e2Pu8D4WjZKvjAOeGOLZaOwd61Fj6waEP5yhL2Zf3+tKQ8S/xYB36PjA2OBYon
         MlgJzdnqL24g1b2TS29Yq2aY33fEwWDl2gHu8=
X-Google-Smtp-Source: AFSGD/UX0LZy4o8/qIvDqsc/m2fpsZxS38L97Ugb4Kz0wnNZOE6ZOAZj8I0k/3pPhoZMbWnUxC2nug==
X-Received: by 2002:a19:982:: with SMTP id 124mr26813402lfj.138.1546730209770;
        Sat, 05 Jan 2019 15:16:49 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id y11-v6sm12996721ljc.85.2019.01.05.15.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:16:48 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id n18so27750778lfh.6
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:16:48 -0800 (PST)
X-Received: by 2002:a19:982:: with SMTP id 124mr26813387lfj.138.1546730208114;
 Sat, 05 Jan 2019 15:16:48 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com> <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
In-Reply-To: <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:16:32 -0800
X-Gmail-Original-Message-ID: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
Message-ID:
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: multipart/mixed; boundary="0000000000009e74e7057ebe30b7"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105231632.KrpghCBSirzSSRztsGOArV8UD11GrIVlEp5TM-cMWXk@z>

--0000000000009e74e7057ebe30b7
Content-Type: text/plain; charset="UTF-8"

On Sat, Jan 5, 2019 at 3:05 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> That would be nicer than my patch, simply because removing code is
> always nice. And arguably it's a better semantic anyway.

Yeah, I wonder why we did that thing where mincore() walks the page
tables, but if they are empty it looks in the page cache.

[... goes and looks in history ..]

It goes back to forever, it looks like. I can't find a reason.

Anyway, a removal patch would look something like the attached, I
think. That makes mincore() actually say how many pages are in _this_
mapping, not how many pages could be paged in without doing IO.

Hmm. Maybe we should try this first. Simplicity is always good.

Again, obviously untested.

                   Linus

--0000000000009e74e7057ebe30b7
Content-Type: text/x-patch; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jqk37sgx0>
X-Attachment-Id: f_jqk37sgx0

IG1tL21pbmNvcmUuYyB8IDc0ICsrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwg
NjggZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbWluY29yZS5jIGIvbW0vbWluY29yZS5j
CmluZGV4IDIxODA5OWI1ZWQzMS4uMzE3ZWI2NGVhNGVmIDEwMDY0NAotLS0gYS9tbS9taW5jb3Jl
LmMKKysrIGIvbW0vbWluY29yZS5jCkBAIC00Miw2NCArNDIsMTIgQEAgc3RhdGljIGludCBtaW5j
b3JlX2h1Z2V0bGIocHRlX3QgKnB0ZSwgdW5zaWduZWQgbG9uZyBobWFzaywgdW5zaWduZWQgbG9u
ZyBhZGRyLAogCXJldHVybiAwOwogfQogCi0vKgotICogTGF0ZXIgd2UgY2FuIGdldCBtb3JlIHBp
Y2t5IGFib3V0IHdoYXQgImluIGNvcmUiIG1lYW5zIHByZWNpc2VseS4KLSAqIEZvciBub3csIHNp
bXBseSBjaGVjayB0byBzZWUgaWYgdGhlIHBhZ2UgaXMgaW4gdGhlIHBhZ2UgY2FjaGUsCi0gKiBh
bmQgaXMgdXAgdG8gZGF0ZTsgaS5lLiB0aGF0IG5vIHBhZ2UtaW4gb3BlcmF0aW9uIHdvdWxkIGJl
IHJlcXVpcmVkCi0gKiBhdCB0aGlzIHRpbWUgaWYgYW4gYXBwbGljYXRpb24gd2VyZSB0byBtYXAg
YW5kIGFjY2VzcyB0aGlzIHBhZ2UuCi0gKi8KLXN0YXRpYyB1bnNpZ25lZCBjaGFyIG1pbmNvcmVf
cGFnZShzdHJ1Y3QgYWRkcmVzc19zcGFjZSAqbWFwcGluZywgcGdvZmZfdCBwZ29mZikKLXsKLQl1
bnNpZ25lZCBjaGFyIHByZXNlbnQgPSAwOwotCXN0cnVjdCBwYWdlICpwYWdlOwotCi0JLyoKLQkg
KiBXaGVuIHRtcGZzIHN3YXBzIG91dCBhIHBhZ2UgZnJvbSBhIGZpbGUsIGFueSBwcm9jZXNzIG1h
cHBpbmcgdGhhdAotCSAqIGZpbGUgd2lsbCBub3QgZ2V0IGEgc3dwX2VudHJ5X3QgaW4gaXRzIHB0
ZSwgYnV0IHJhdGhlciBpdCBpcyBsaWtlCi0JICogYW55IG90aGVyIGZpbGUgbWFwcGluZyAoaWUu
IG1hcmtlZCAhcHJlc2VudCBhbmQgZmF1bHRlZCBpbiB3aXRoCi0JICogdG1wZnMncyAuZmF1bHQp
LiBTbyBzd2FwcGVkIG91dCB0bXBmcyBtYXBwaW5ncyBhcmUgdGVzdGVkIGhlcmUuCi0JICovCi0j
aWZkZWYgQ09ORklHX1NXQVAKLQlpZiAoc2htZW1fbWFwcGluZyhtYXBwaW5nKSkgewotCQlwYWdl
ID0gZmluZF9nZXRfZW50cnkobWFwcGluZywgcGdvZmYpOwotCQkvKgotCQkgKiBzaG1lbS90bXBm
cyBtYXkgcmV0dXJuIHN3YXA6IGFjY291bnQgZm9yIHN3YXBjYWNoZQotCQkgKiBwYWdlIHRvby4K
LQkJICovCi0JCWlmICh4YV9pc192YWx1ZShwYWdlKSkgewotCQkJc3dwX2VudHJ5X3Qgc3dwID0g
cmFkaXhfdG9fc3dwX2VudHJ5KHBhZ2UpOwotCQkJcGFnZSA9IGZpbmRfZ2V0X3BhZ2Uoc3dhcF9h
ZGRyZXNzX3NwYWNlKHN3cCksCi0JCQkJCSAgICAgc3dwX29mZnNldChzd3ApKTsKLQkJfQotCX0g
ZWxzZQotCQlwYWdlID0gZmluZF9nZXRfcGFnZShtYXBwaW5nLCBwZ29mZik7Ci0jZWxzZQotCXBh
Z2UgPSBmaW5kX2dldF9wYWdlKG1hcHBpbmcsIHBnb2ZmKTsKLSNlbmRpZgotCWlmIChwYWdlKSB7
Ci0JCXByZXNlbnQgPSBQYWdlVXB0b2RhdGUocGFnZSk7Ci0JCXB1dF9wYWdlKHBhZ2UpOwotCX0K
LQotCXJldHVybiBwcmVzZW50OwotfQotCiBzdGF0aWMgaW50IF9fbWluY29yZV91bm1hcHBlZF9y
YW5nZSh1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLAogCQkJCXN0cnVjdCB2
bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBjaGFyICp2ZWMpCiB7CiAJdW5zaWduZWQgbG9u
ZyBuciA9IChlbmQgLSBhZGRyKSA+PiBQQUdFX1NISUZUOwotCWludCBpOwogCi0JaWYgKHZtYS0+
dm1fZmlsZSkgewotCQlwZ29mZl90IHBnb2ZmOwotCi0JCXBnb2ZmID0gbGluZWFyX3BhZ2VfaW5k
ZXgodm1hLCBhZGRyKTsKLQkJZm9yIChpID0gMDsgaSA8IG5yOyBpKyssIHBnb2ZmKyspCi0JCQl2
ZWNbaV0gPSBtaW5jb3JlX3BhZ2Uodm1hLT52bV9maWxlLT5mX21hcHBpbmcsIHBnb2ZmKTsKLQl9
IGVsc2UgewotCQlmb3IgKGkgPSAwOyBpIDwgbnI7IGkrKykKLQkJCXZlY1tpXSA9IDA7Ci0JfQor
CW1lbXNldCh2ZWMsIDAsIG5yKTsKIAlyZXR1cm4gbnI7CiB9CiAKQEAgLTE0NCwyMSArOTIsMTEg
QEAgc3RhdGljIGludCBtaW5jb3JlX3B0ZV9yYW5nZShwbWRfdCAqcG1kLCB1bnNpZ25lZCBsb25n
IGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLAogCQllbHNlIHsgLyogcHRlIGlzIGEgc3dhcCBlbnRy
eSAqLwogCQkJc3dwX2VudHJ5X3QgZW50cnkgPSBwdGVfdG9fc3dwX2VudHJ5KHB0ZSk7CiAKLQkJ
CWlmIChub25fc3dhcF9lbnRyeShlbnRyeSkpIHsKLQkJCQkvKgotCQkJCSAqIG1pZ3JhdGlvbiBv
ciBod3BvaXNvbiBlbnRyaWVzIGFyZSBhbHdheXMKLQkJCQkgKiB1cHRvZGF0ZQotCQkJCSAqLwot
CQkJCSp2ZWMgPSAxOwotCQkJfSBlbHNlIHsKLSNpZmRlZiBDT05GSUdfU1dBUAotCQkJCSp2ZWMg
PSBtaW5jb3JlX3BhZ2Uoc3dhcF9hZGRyZXNzX3NwYWNlKGVudHJ5KSwKLQkJCQkJCSAgICBzd3Bf
b2Zmc2V0KGVudHJ5KSk7Ci0jZWxzZQotCQkJCVdBUk5fT04oMSk7Ci0JCQkJKnZlYyA9IDE7Ci0j
ZW5kaWYKLQkJCX0KKwkJCS8qCisJCQkgKiBtaWdyYXRpb24gb3IgaHdwb2lzb24gZW50cmllcyBh
cmUgYWx3YXlzCisJCQkgKiB1cHRvZGF0ZQorCQkJICovCisJCQkqdmVjID0gISFub25fc3dhcF9l
bnRyeShlbnRyeSk7CiAJCX0KIAkJdmVjKys7CiAJfQo=
--0000000000009e74e7057ebe30b7--

