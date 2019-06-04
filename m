Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CFBAC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:34:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D3E22231F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:34:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sM1mzsQH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D3E22231F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89D736B0010; Tue,  4 Jun 2019 08:34:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84DDA6B026B; Tue,  4 Jun 2019 08:34:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764C76B026C; Tue,  4 Jun 2019 08:34:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF126B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:34:51 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a13so6907409pgw.19
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:34:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZHnFmrFfRfh/AvNJyyWOv1fZiunoT+xaBh/4jOpKvTQ=;
        b=QNC5JHYN42AuXXteZEV/qpFJjp4QBYLAhsAtA4BHG8U3w+5HOjOcmuF/lccHDAPuTr
         LnBMa44MONmflpLU+cVEOO6gXJiZiTZ+rfdIodxJLMjXJ29IKy1wMKIqPNrBKRGUe2T0
         rJNoaIHB+zgW28kGF/lIfHXi1MpSDcvP/CmOJ6isFYxDq8ziiTOzO3cHdAVq391rnYTm
         RAcCPSGlDTCeUw7DqBm45wuuvkHaEiVZ8Pw6um6t9A0qUnzB/xMxavVZFVFgT1iPIIZg
         h5ePYxIevKYyTkUGgPpka5LakX6Ef8j+DztZOMnE6uCFSjdUE9/+H2RgO/tg+E8LE1jd
         Xj4A==
X-Gm-Message-State: APjAAAWnceY2ZyZK9YvOSuf7G0xOmm6yocGc93746fxmiFcjtLGXG+5x
	kmk3KR87iHdQzC8s6Ko8iXeSNNJkHJHdP/GG45C/fIHhC8P18z4NezDd2FKR4UKppHwQlT9l5yQ
	cVQpOVQQGRiMKyCjX8R+4q3MWOBjWu+7gLj0oaDySn6+TQqu1vfB2yYodGEbjt+4m5w==
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr36459772pjd.117.1559651690834;
        Tue, 04 Jun 2019 05:34:50 -0700 (PDT)
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr36459679pjd.117.1559651689926;
        Tue, 04 Jun 2019 05:34:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651689; cv=none;
        d=google.com; s=arc-20160816;
        b=NF5cELHEn+PenKItlNRYvkcWqCvrOdrfBkx+gKpN4XGqXfSaAax0HTu+6AoHWQJ0/q
         AGv4zNBKM4uJjAfHY0teZ6p3GrHLNkizqhmbBAJ+1e9lL3PXXG+6WUk1WXCNdA9PeGtw
         Aehsj5G8bnwhSmNfJ/gGzOb+a3gjVp8yyzkxtSYnibwznYzR27DUmGcNczCBoer9Qt/L
         OkKvE/nqhasq4n8U52JZ8nJHpw4TwCblzl+CUnpSPO7iyNyF56zfVIHFKO5FisKqeatS
         4Dc27EPg8dMQYkrA4nceBmp60awBtW1BTt6AFUmZzoqfbzcdoYH0OGMCdQuUn+B4LxHn
         aYQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZHnFmrFfRfh/AvNJyyWOv1fZiunoT+xaBh/4jOpKvTQ=;
        b=qZmkpMUhLIoAEFBLlkBSPt/NbiEdmbhivCFhrwU0RJY8lDzuwajea/deZrJZKssQMU
         MXQ3ZvQkQyjUjTRrhxQYPNGD3H+VuY48V2i+gHaI3r3cv05xfTGJxfkFp1/7V9oFGAz6
         aZhyHBRx/EMREZq3uf8AzLsZyIIm5IE9TBsReJHApxTk/9HVPGfktr4Zjn4ERR/Z0euW
         JLNfS5ytQLJYbfDb3abkioiOqe7g2dANvhJPHdvEIO7aQbFejK+kGRCSzCVHBCzQQmBm
         j2seIR3JYHt8HgaLpwc7pjngRW8ZA2rn7da5zDyYOeuslY2fnfF1EKfotAnsDA9EL9lF
         sbnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sM1mzsQH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor5453968pfb.26.2019.06.04.05.34.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:34:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sM1mzsQH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZHnFmrFfRfh/AvNJyyWOv1fZiunoT+xaBh/4jOpKvTQ=;
        b=sM1mzsQHPWWZHTawBLKWAgVjQThohDWkimAMcbonijyC54y8P2c26E0W2rM2IJY/m8
         LZvg01A94bMj1WlufObeLPkCPFVWlG1fpPGYAusKcJ0h4TSfntoPqPc6/wpa61VjjeSq
         2wxM/o5o0K1ra4b5zRGlQW204mrf6zT/4yMmHX7lBOfDc4OCCgqvd6tNS4U2wlNLMmtL
         bz7UkkIob9zlNFiuzQFjICyejDPOtW4/NuezAc/NufYaEQ9+bPzfXvEC2VUHLxA3jSpg
         zi75erEDlO6/F+f3w/vSf+LFVBb/kHnrW1/Xu0/niwLqlxDvkQELtydqfx7PnZ4+YwSc
         CMGg==
X-Google-Smtp-Source: APXvYqwn1SWCI6udsJKomLgM6z7+qFO6mHtKOVLBDx9bpSrAmG/bLquj7gkAYUayFTQJ+Kz6TBw6JcOE/LCE3GzhNkY=
X-Received: by 2002:a62:1c91:: with SMTP id c139mr29991024pfc.25.1559651689157;
 Tue, 04 Jun 2019 05:34:49 -0700 (PDT)
MIME-Version: 1.0
References: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
 <20190604122841.GB15385@ziepe.ca>
In-Reply-To: <20190604122841.GB15385@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 14:34:37 +0200
Message-ID: <CAAeHK+x0qYsO+P=8pQ6N0nRa4y+N3HWTh4sFaUMM63X3q_QbBg@mail.gmail.com>
Subject: Re: [PATCH v2] uaccess: add noop untagged_addr definition
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, sparclinux@vger.kernel.org, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 2:28 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Jun 04, 2019 at 02:04:47PM +0200, Andrey Konovalov wrote:
> > Architectures that support memory tagging have a need to perform untagging
> > (stripping the tag) in various parts of the kernel. This patch adds an
> > untagged_addr() macro, which is defined as noop for architectures that do
> > not support memory tagging. The oncoming patch series will define it at
> > least for sparc64 and arm64.
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >  include/linux/mm.h | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0e8834ac32b7..dd0b5f4e1e45 100644
> > +++ b/include/linux/mm.h
> > @@ -99,6 +99,17 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >  #include <asm/pgtable.h>
> >  #include <asm/processor.h>
> >
> > +/*
> > + * Architectures that support memory tagging (assigning tags to memory regions,
> > + * embedding these tags into addresses that point to these memory regions, and
> > + * checking that the memory and the pointer tags match on memory accesses)
> > + * redefine this macro to strip tags from pointers.
> > + * It's defined as noop for arcitectures that don't support memory tagging.
> > + */
> > +#ifndef untagged_addr
> > +#define untagged_addr(addr) (addr)
>
> Can you please make this a static inline instead of this macro? Then
> we can actually know what the input/output types are supposed to be.
>
> Is it
>
> static inline unsigned long untagged_addr(void __user *ptr) {return ptr;}
>
> ?
>
> Which would sort of make sense to me.

Hm, I'm not sure. arm64 specifically defines this as a macro that
works on different kinds of pointer compatible types to avoid casting
everywhere it's used:

https://elixir.bootlin.com/linux/v5.1.7/source/arch/arm64/include/asm/memory.h#L214

>
> Jason

