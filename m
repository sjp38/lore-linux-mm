Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 448F6C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 083C12083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:30:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="g1mjJHSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 083C12083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E9438E0002; Thu, 20 Jun 2019 13:30:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89A968E0001; Thu, 20 Jun 2019 13:30:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 788768E0002; Thu, 20 Jun 2019 13:30:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1674B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:30:14 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id d22so522187lja.20
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8s7nWa83ZrllVywYBO3+qENQEvSqioKh5iSEDp3yvQc=;
        b=DYpzgdcd7cgd+IQg9sqodQrDAJJN/7kkICDNusrRVMsOEWCvD4iKgDYALUsXC0VgjG
         YQNnadg1BgeIk38Gneca7Q3mVgW5Sgxs8FDjR3iG/OS4BOk/eEkhb5M2Lzm9ceDbZhPI
         hU/zaxtqaFnTaKGezeZehaF9k9H5eSsett6o8WEQI8CXOkc661LSbDJb+X5ruP36tuTu
         iK7Gb2xamiXb5PdfDXXN2F69OsDnLKGUSuMNH5kGQkA7JREbLYcNCryTHWNDQR2OkZkf
         UnHl4MA2elBzrJxLsZpcyrzkjdPGjhaeEYxL4gSl4hK7Z7fsFG1LHEHU7gxTRX0+iBH6
         8YdQ==
X-Gm-Message-State: APjAAAW28it+mctvNGvjImOTKwHm3rp1XuRrOPnhUU6axPyHAhrIur17
	hfNdUbjHpyDZMRbDU+zwpsIzfDt2vuWkEBQfktrPgY6awngqWo0BMs3xniyqvL54meBb3BnrQbY
	rbZlumj26VknyQuPZ32jG3XIFPFVJKoRmXw0bRRnrKrXuYwQRP+iAwViTHFwwz/lVGw==
X-Received: by 2002:a19:230e:: with SMTP id j14mr25728524lfj.13.1561051813226;
        Thu, 20 Jun 2019 10:30:13 -0700 (PDT)
X-Received: by 2002:a19:230e:: with SMTP id j14mr25728501lfj.13.1561051812386;
        Thu, 20 Jun 2019 10:30:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051812; cv=none;
        d=google.com; s=arc-20160816;
        b=RDe2WptKE4ePQ3ssBtABfIbNcK8KQj3izS9zBUYByJ1QhqZANF4eCBNLsXW+hvEFSz
         Scy1Jmn/tLrW3R8/dBZMZ2ToU6SxUBKiuYmCiKUebFYq82BbhAej+3O+ZllN98HgTZLk
         WtZlxeyZK+isgoSZbu/xNBywa+wIfEToPZd8z47a/2AMODCxmr8TFogtJTZte9TGwacu
         DBvXd9usqEy1cb4en1OAYyni3ymg5uNuk00GtKiYGTv4xz4FlFSuZCnd7p94mSiXoP1B
         n7MtjNWhFn+0xkiYuxZ4z728F06dq1yTzY8eVsMlQrp9tIbSVOGEyZ2FDx945zW7p9Po
         Mx7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8s7nWa83ZrllVywYBO3+qENQEvSqioKh5iSEDp3yvQc=;
        b=PZwN582GKiF76wf/NRJ76Gp4xcVAD85sfpCCwEJAY8TlGB9dfQ+/eZu30P9xF2Zwjp
         kIU2iF8EvvC8Fk1yQSkGpIWd55zsRHQM6N8GJyqYsQ5e5lWvWlgIu2zg03sGffbDb/zr
         NCJkOQymr/kTk13hYbZyc/CEOkMRhEOukeTIqdbhER9j6McRun/I0Rw+s4aZI0D5jF+I
         yIvM74scytKBBJ3xAXK0WIHLgtvn48X2JAeDK2Fx3GpwLjilVtuUTEWy2X/e7q1zy8sF
         cW45bSZ1EFy4bv/3DS3hHmpfwSRPSW7U5iTKPfVRHuXDlGQS+9kKwF5a9JYI55d5kdst
         hS6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g1mjJHSB;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor120310lfk.31.2019.06.20.10.30.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 10:30:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g1mjJHSB;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8s7nWa83ZrllVywYBO3+qENQEvSqioKh5iSEDp3yvQc=;
        b=g1mjJHSB+/44ZB7V3d991RQ8lmWdxyz7cRKmwtk9byrjcNUD9YP2uS+RZIIrKE7lKn
         tVpZNvyJkolb6AtIXbb56yLA6c56wf2OFIIZEIPMa1TRDMJb6FE75meYgwCBSBqSYdRC
         O8jEDgU+LfyGIAqseIIvIOnHddyiMVgjB9lIw=
X-Google-Smtp-Source: APXvYqx0hcrgzbHM/YNGNQqlhYJp9Y3KoIgt+5o0kcjGxVVcW2yB+zsncMwOo3wwtOaaGgTt5TNOsQ==
X-Received: by 2002:a19:ca1e:: with SMTP id a30mr114609lfg.163.1561051811545;
        Thu, 20 Jun 2019 10:30:11 -0700 (PDT)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id q4sm31252lje.99.2019.06.20.10.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:30:11 -0700 (PDT)
Received: by mail-lf1-f50.google.com with SMTP id y198so3049727lfa.1
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:30:11 -0700 (PDT)
X-Received: by 2002:ac2:5601:: with SMTP id v1mr51955604lfd.106.1561051322002;
 Thu, 20 Jun 2019 10:22:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-17-hch@lst.de>
 <1560300464.nijubslu3h.astroid@bobo.none> <CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
 <1561032202.0qfct43s2c.astroid@bobo.none>
In-Reply-To: <1561032202.0qfct43s2c.astroid@bobo.none>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 20 Jun 2019 10:21:46 -0700
X-Gmail-Original-Message-ID: <CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
Message-ID: <CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>, James Hogan <jhogan@kernel.org>, 
	Khalid Aziz <khalid.aziz@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Paul Burton <paul.burton@mips.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, 
	"the arch/x86 maintainers" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 5:19 AM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> The processor aliasing problem happens because the struct will
> be initialised with stores using one base register (e.g., stack
> register), and then same memory is loaded using a different
> register (e.g., parameter register).

Hmm. Honestly, I've never seen anything like that in any kernel profiles.

Compared to the problems I _do_ see (which is usually the obvious
cache misses, and locking), it must either be in the noise or it's
some problem specific to whatever CPU you are doing performance work
on?

I've occasionally seen pipeline hiccups in profiles, but it's usually
been either some serious glass jaw of the core, or it's been something
really stupid we did (or occasionally that the compiler did: one in
particular I remember was how there was a time when gcc would narrow
stores when it could, so if you set a bit in a word, it would do it
with a byte store, and then when you read the whole word afterwards
you'd get a major pipeline stall and it happened to show up in some
really hot paths).

            Linus

