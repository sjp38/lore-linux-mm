Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD839C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 00:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FB48214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 00:01:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="IBLCLtPu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FB48214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E48A16B0005; Wed, 17 Apr 2019 20:01:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA066B0006; Wed, 17 Apr 2019 20:01:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6D896B0007; Wed, 17 Apr 2019 20:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 591B36B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 20:01:18 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id i127so97773lji.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+kn5mtINPt4na060bar/tC0RHNfqAb7J/PmuZQ0Dyi8=;
        b=UJrhthMomBlEGcCUJhJvZfguz6ebS0hRN4mSPfbeKnfBzOrHYfDqeQHgGpnBymS779
         kuRULkkOQuEZeN5AOzimZSwPj6rzALVzdl39twCwxyiuTFxRqtzstqY7yfymp3j5qq2O
         YbP4ayXoIvrVOwtPtKW91jM/3JWmUScND/m0cwwQWk0XuXlt92zAlEL6uX8anG2PmEi5
         s55/9PGJgxOSJw/K3+G/x11Duela1tCrMYS2D24BjxUi48xs/cqP3UmLN09e4L1q2Yyj
         M4ufkR9nrdcQp34Z8sb23IEwJ8PHMs6V28aZ7M+erufVxzhF/CHX2Q8qZaUrdKokJWFa
         A+OQ==
X-Gm-Message-State: APjAAAU/GqH4CST/TmJEzHVXEKookYwkrU+WUEDCZEJHTgXWphRVZzQR
	p0tLpFJ5EtR4VNOxJHkGLe6uKqbWfRQsEysySsyQU6YBb0a2TFW9wB/YkUpvkicHL5svHMUtTRf
	araybhAwKXVUZ695hcfPj9CO5/Un0O+69VZy060Lq5gQbP//QmOYrJbj/4td25XUKdw==
X-Received: by 2002:a2e:74f:: with SMTP id i15mr43517898ljd.156.1555545677526;
        Wed, 17 Apr 2019 17:01:17 -0700 (PDT)
X-Received: by 2002:a2e:74f:: with SMTP id i15mr43517869ljd.156.1555545676528;
        Wed, 17 Apr 2019 17:01:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555545676; cv=none;
        d=google.com; s=arc-20160816;
        b=SBW43cTplBQa3oTEm1Vh6Yww+K00shVpE+idbZhuGauCv6hVE1Nd9YlXEhfk5FBVeW
         xp3riVGZlpInn9qOweX/4Zm8WFc+MIzDl2gYcgkiO86kDMakbdSqzLs8mC1BbF55ae28
         0jZorRGIogGrm7ouboKz3O2nQbq1vSyIa7x52nyzApOxmyqhynLOcLVZCMkGTZkMWF+V
         CW7ykwiq0a9OKEdnyLEgcuIOmNw4dMYyhi7frQrPbhlhcl1+/F6xBvysS2o1VJcGcL3f
         4xOgL5lw/tM5QWWghGJC3wuBrF1xvW6jnX4ABXPaf82cojkEOb/ZX0f9jg7LNAF3hfm2
         nwkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+kn5mtINPt4na060bar/tC0RHNfqAb7J/PmuZQ0Dyi8=;
        b=SsXaeec/yQ1gVDEyaHolQavFTiHK8NS7+b0syGp7s2tEDLHPmahMTQ6xTqqnE1yRw4
         Xj1NoxfQCBRO+WcIVD3rut0704jmablrVzCkWKE/Su7tG16oeE5sUPwKN5z60RCMKlz6
         m0HcHCAiCX74YWUOihkV5KGPD003ZkEUoCoQHtNJtCfUwUnlQlss+5rS+xYwoXMQG5lg
         Q9+uskn4YLX7jpvF7ZX7Xj5XciuX7X48VkNriUXUiwAdlmcGifNavmLjCgLC8doT51Bk
         lJ82OAWP5wfFIxluQZuzI24AjswqaJ4rbM9CYJPk2xB9igbXXCKRrsdeIsosfCs8oZOZ
         rB7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=IBLCLtPu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor139214ljj.10.2019.04.17.17.01.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 17:01:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=IBLCLtPu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+kn5mtINPt4na060bar/tC0RHNfqAb7J/PmuZQ0Dyi8=;
        b=IBLCLtPuOlIJGx6ETpn93rimEqBz5Au/0GjooFZAo0KIJTxoTsJPz413yAtvfmWoXY
         BqvjzirjujDpTm8Z8RGtzbE47EZiPUSxIfegDrH1aTumTX5oM8C5bVyiexfx7ifgxxPB
         UMawmkwQ/X7ZweYBYxIOjMj+Jba1Zio7Xb4vw=
X-Google-Smtp-Source: APXvYqxckqXxWlE6Wltpoi1lHlzLq6zt+ZMYFt2/sYcWqh3sOaeuN0MfOnur0wwMmec/bEQ0FKwSIw==
X-Received: by 2002:a2e:22c4:: with SMTP id i187mr48167621lji.94.1555545675741;
        Wed, 17 Apr 2019 17:01:15 -0700 (PDT)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com. [209.85.208.180])
        by smtp.gmail.com with ESMTPSA id t23sm65957ljc.13.2019.04.17.17.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 17:01:15 -0700 (PDT)
Received: by mail-lj1-f180.google.com with SMTP id q66so269512ljq.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:01:15 -0700 (PDT)
X-Received: by 2002:a2e:5dd2:: with SMTP id v79mr48356924lje.22.1555545190479;
 Wed, 17 Apr 2019 16:53:10 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com> <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Apr 2019 16:52:54 -0700
X-Gmail-Original-Message-ID: <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
Message-ID: <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>, 
	Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, Tycho Andersen <tycho@tycho.ws>, 
	jsteckli@amazon.de, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, 
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com, 
	Tyler Hicks <tyhicks@canonical.com>, David Woodhouse <dwmw@amazon.co.uk>, 
	Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, iommu <iommu@lists.linux-foundation.org>, 
	X86 ML <x86@kernel.org>, 
	"linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, Khalid Aziz <khalid@gonehiking.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 4:42 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Wed, 17 Apr 2019, Linus Torvalds wrote:
>
> > With SMEP, user space pages are always NX.
>
> We talk past each other. The user space page in the ring3 valid virtual
> address space (non negative) is of course protected by SMEP.
>
> The attack utilizes the kernel linear mapping of the physical
> memory. I.e. user space address 0x43210 has a kernel equivalent at
> 0xfxxxxxxxxxx. So if the attack manages to trick the kernel to that valid
> kernel address and that is mapped X --> game over. SMEP does not help
> there.

Oh, agreed.

But that would simply be a kernel bug. We should only map kernel pages
executable when we have kernel code in them, and we should certainly
not allow those pages to be mapped writably in user space.

That kind of "executable in kernel, writable in user" would be a
horrendous and major bug.

So i think it's a non-issue.

> From the top of my head I'd say this is a non issue as those kernel address
> space mappings _should_ be NX, but we got bitten by _should_ in the past:)

I do agree that bugs can happen, obviously, and we might have missed something.

But in the context of XPFO, I would argue (*very* strongly) that the
likelihood of the above kind of bug is absolutely *miniscule* compared
to the likelihood that we'd have something wrong in the software
implementation of XPFO.

So if the argument is "we might have bugs in software", then I think
that's an argument _against_ XPFO rather than for it.

                Linus

