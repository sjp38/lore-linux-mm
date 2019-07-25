Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E61C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFC9F22CBB
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:00:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="VFAYa7L0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFC9F22CBB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DDBB6B0005; Thu, 25 Jul 2019 16:00:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48D1B6B0006; Thu, 25 Jul 2019 16:00:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A51C8E0002; Thu, 25 Jul 2019 16:00:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064916B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:00:37 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d6so26860794pls.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:00:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=czhvpuMA3newxUE1Ok0eyKdEKMeSe/BMrFd/BkJbH88=;
        b=FWZTfEiDrCkmkmS3N4LXSghikjpKrEx0Xsb4hiBt3VntBYnBZaK9xTmuuZ5zD49jHL
         xa6iDS8gmzVJTxt2RU0fULpAosJS2mSKrNHHj4kzHElfe0IzRC1l+6/jJyGGmawyLwFr
         DYTWKH9VNXqdn2NjU3PYChJNdt0NNvMMrvYFL43X15Y1hX52izameam11MJBMLz22OAv
         iZ2KHbRZ6vrqon4+aqI1YQn4LzPgfkwblSe2uXsQB+vrqYzo+flVNdmSneeREwzbruYO
         z66wh5PH2KfjzdU9wgh8bUskcsimAavh44dDCk28upOKmbMdnrdRFEgFFHgiZ7fOT9LV
         AKFA==
X-Gm-Message-State: APjAAAUgEtxWCVO0M0EV26uM9kADgZ5zvtc66CmEtIX+4aXqIp1Zu9e6
	jf+l+pzC3wl02Epqjpg6yCyqLlXqvQGuWGSHzjb0+rBxXwcMhelEZFJKoOv+qlgrOgTJpjXqHXq
	FB4/yRq7IIPapUbQkikASFWbQ55dSVVDPVp16RKj66UXtMORaKZ+d2Ftb3cCBlJqogg==
X-Received: by 2002:a63:e20a:: with SMTP id q10mr86214603pgh.24.1564084836436;
        Thu, 25 Jul 2019 13:00:36 -0700 (PDT)
X-Received: by 2002:a63:e20a:: with SMTP id q10mr86214525pgh.24.1564084835444;
        Thu, 25 Jul 2019 13:00:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564084835; cv=none;
        d=google.com; s=arc-20160816;
        b=azqF9HUALpDXGKgXMXukTxnOPn1Gya/DVjxa51Aw5IBY9emM9+loDNo9BroPJGXVeu
         CNmPtOwUcFsDPhHNR349/AKLtS4/Im4mMeRLpzpOLSsyS98UHhrTn5oQWyL2sH1sx21i
         l7+NrziLPiB6J6oiuG7fIuPUI1NVEXQYLU6ErPUyPCEQs5fx7CdtFZUHBoYmHBFvtIdx
         e08lIx3zWLw+I2+fcvP+A47paoLrQ/KlAQzjO/C5xOcOUIqDRMts1JVPc1nt/sRk211/
         e5ya/Eoeb+Sf11gRtU16GnPd8rQy+SaPQzdA36/JhADbQdebUmkdR7x6HBIrgFyr8up7
         ajIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=czhvpuMA3newxUE1Ok0eyKdEKMeSe/BMrFd/BkJbH88=;
        b=IXquHN7gMhbIDbjDI/cTFyWUYPXOuaTGcwiJ2DAN4QCBZaxkQQUG+KutQaCtg0dZ2I
         1W//PcfOq9zcYiHpYiA2Nj7ZMzEprCLdyVJvAuc+SmwQW0JM+jUc/wcDmSsr9c1C1b/1
         6ZcMycnvfCqfLgrZ0paYv2rI3N6AVfxrACCqK5r/E/JY0BWzYkmN8RFv310xhL+1q/LP
         OX2QyRb3D/z0RaIa3QLCdM/PFC/LdWa7z6QrB9L76QoU1F9+SJ8UPxlSCHjnqriTkiM3
         4EvllRON31XdOpKIwCzkbWyj40cZGFShpSVnfSvePx/IDiUUn22onpEvTV3KTNkCBlHt
         qoww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VFAYa7L0;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66sor31399494pfd.30.2019.07.25.13.00.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 13:00:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VFAYa7L0;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=czhvpuMA3newxUE1Ok0eyKdEKMeSe/BMrFd/BkJbH88=;
        b=VFAYa7L009E7Uphizuk8EUTkPs3Kp07Ow0349Bvlb5HNDgpvBrzunrXj9n7hha+kMS
         bUM5MSI0W1TI2wdDk/dt+iOAY/2LqMW2igW+v6EdmydphptD2J677zHoPzFb2KTmBouE
         B/nckqeeuspAcsyRQBtXmWSYaDMekv/0MycuA=
X-Google-Smtp-Source: APXvYqxpPEGm+2UHeZbjVl2jSdGpMi/b2Xe2soYfLXU2pENpqL6KqScEe4kJzeeCzenWEThRkjVa+g==
X-Received: by 2002:aa7:9713:: with SMTP id a19mr465671pfg.64.1564084835161;
        Thu, 25 Jul 2019 13:00:35 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id j1sm75405528pgl.12.2019.07.25.13.00.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jul 2019 13:00:34 -0700 (PDT)
Date: Thu, 25 Jul 2019 13:00:33 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Will Deacon <will.deacon@arm.com>,
	Russell King <linux@armlinux.org.uk>,
	Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Paul Burton <paul.burton@mips.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	James Hogan <jhogan@kernel.org>, linux-fsdevel@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	linux-arm-kernel@lists.infradead.org,
	Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH REBASE v4 11/14] mips: Adjust brk randomization offset to
 fit generic version
Message-ID: <201907251259.09E0101@keescook>
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-12-alex@ghiti.fr>
 <1ba4061a-c026-3b9e-cd91-3ed3a26fce1b@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ba4061a-c026-3b9e-cd91-3ed3a26fce1b@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 08:22:06AM +0200, Alexandre Ghiti wrote:
> On 7/24/19 7:58 AM, Alexandre Ghiti wrote:
> > This commit simply bumps up to 32MB and 1GB the random offset
> > of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.
> > 
> > Suggested-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > ---
> >   arch/mips/mm/mmap.c | 7 ++++---
> >   1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> > index a7e84b2e71d7..faa5aa615389 100644
> > --- a/arch/mips/mm/mmap.c
> > +++ b/arch/mips/mm/mmap.c
> > @@ -16,6 +16,7 @@
> >   #include <linux/random.h>
> >   #include <linux/sched/signal.h>
> >   #include <linux/sched/mm.h>
> > +#include <linux/sizes.h>
> >   unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
> >   EXPORT_SYMBOL(shm_align_mask);
> > @@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
> >   	unsigned long rnd = get_random_long();
> >   	rnd = rnd << PAGE_SHIFT;
> > -	/* 8MB for 32bit, 256MB for 64bit */
> > +	/* 32MB for 32bit, 1GB for 64bit */
> >   	if (TASK_IS_32BIT_ADDR)
> > -		rnd = rnd & 0x7ffffful;
> > +		rnd = rnd & SZ_32M;
> >   	else
> > -		rnd = rnd & 0xffffffful;
> > +		rnd = rnd & SZ_1G;
> >   	return rnd;
> >   }
> 
> Hi Andrew,
> 
> I have just noticed that this patch is wrong, do you want me to send
> another version of the entire series or is the following diff enough ?
> This mistake gets fixed anyway in patch 13/14 when it gets merged with the
> generic version.

While I can't speak for Andrew, I'd say, since you've got Paul and
Luis's Acks to add now, I'd say go ahead and respin with the fix and the
Acks added.

I'm really looking forward to this cleanup! Thanks again for working on
it. :)

-- 
Kees Cook

