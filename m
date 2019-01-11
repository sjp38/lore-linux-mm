Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 840BFC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40E8B2084C
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:49:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dJmuXoxo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40E8B2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C20AD8E0004; Fri, 11 Jan 2019 08:49:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCE418E0001; Fri, 11 Jan 2019 08:49:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABED88E0004; Fri, 11 Jan 2019 08:49:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D80C8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:49:05 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so10340973pfk.12
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:49:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RXKHpApbXWxCHzZIFxDaePnTRIPPkx7fd2gBjWXrl0Q=;
        b=OzkjxAWesD/tuQ+ToGWTyARu3480+bsBRJ9ccuSyIVsCgTrQsqEqnN5ozkSY/TiqTJ
         5JDAsCKuZd8RdyK3AYIbXsar/RQyz/41x0XqOVNwC2zt+tdpzsdlvp0MiVlpzuiUr1Nc
         kAq13FK03XbEXwTPAGyvjZ959ULuSZ29o85YOjCEfSxIa92qDB+TJ4F6+Ha5DFc7Gent
         g9UWW6BifCPryvdG4nOJQ46Gh1TObwEmtNaKw07WvucBJ+MIaVZ5nHT7NN82x/UWU0oM
         A/RkdSUUXzxbP6FUWJK9bpDNWs7qeu4sLpB7Ltxu/7bWLcdFzFo/b+CX5Vmd0xKsHnyJ
         m00g==
X-Gm-Message-State: AJcUukeZMcij2lv/qP8zu9+E8hjWTZjccJesmxppSVwnLAERZZedDES5
	Uau12LltldmPneHs20xaNbXEKPpb6G2iUejaDR/rAZuCKveW/1gKZddJ6jlebdQz3IMKTldVNMO
	xJ1KxzhV6AO+uFY9Vy5iRJCUjAT9iw+UVD3BbtaE7SB9e+8lFM6g5o/uASgRNEWtFrOpH8Omzsd
	WWRx8ml8rltjD3obNuypa/SM/iGZhcXFR6mWO9m9rQcKeM2y3LfSx1WBfDcSriXLrAVZr4+Vy7X
	P3ZCHmL6fiOBCJpWO05rtjM+Pn5DInjATmyHG5r7Z4AORLEWU6Xs0isbiUMSdtmMo6Q7JGXA2rd
	sS5bGAXbTL78VjylzVMmZOx4vVGOp1n7xRF74TUc+BtVUmZqFyus+ALbdUHqlmZQmVtiWTEsC9f
	P
X-Received: by 2002:a17:902:201:: with SMTP id 1mr14591491plc.62.1547214545079;
        Fri, 11 Jan 2019 05:49:05 -0800 (PST)
X-Received: by 2002:a17:902:201:: with SMTP id 1mr14591452plc.62.1547214544034;
        Fri, 11 Jan 2019 05:49:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547214544; cv=none;
        d=google.com; s=arc-20160816;
        b=xId0dyt0tW9p1NcpFLRVjSU0ZmoMqNK0l5TJ4TbGz8cGQG9BfRMwyqxskaeoZ7Ht7b
         ZqUkZN2LWUPDEl13wCHt3idK5PawfxU+BeFpCulDBqTFXDwAQp8DxfdySBb+DdV+k0OY
         mgCGu1nSWv+Rpt0cNZDOvvu/142+Q5cDtywBAWQ4nEFU8mU/6kIk2wy+SZVOuDfSuiTf
         FOUUf7b/YnETMqVkBdmSPoQ7UMiQcbEx2HUAMUOMzVpo4HA2+jXyB9mh3SKQrqT9cDye
         t4P0k7VafKZS3DxVHGPWkV3zr16lguJLQKfIQvod2mqyXYCq4oxSToQHSuKewD8Y5HVq
         43dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RXKHpApbXWxCHzZIFxDaePnTRIPPkx7fd2gBjWXrl0Q=;
        b=UuqjDf7Br/L2cwhzLMFlBlQwEhcXpMvPZoDkSCRUBdanNg+nXs1ibkN6u3lwspm6Aa
         aX1+Qxe8bgT/q5eO4UNuv/ScmYIDicO9EzzyTgYBkhLKaPfBmaqSlE5c21GMZ0ZGkWza
         UeEuWmZzeB8sjQBOUgOa23RcIwF2Rb+wmEYkXE2VVeFZo5EWoyVVrLO0sf9IRrsNoC3H
         QP1OJ+GAydHtn/AeLBCl12ZxW4nalIdvatj28dLnhyB7/WHQUTtYlaIWKcRurpzAAGFg
         4jTK5cN1Twe8DadAu7qwZte5W1Y4Lim4C44/NVu8aJljDC8MFe4A5s7s50R3vtzcYn5Z
         4bpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dJmuXoxo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17sor56420440pga.2.2019.01.11.05.49.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 05:49:04 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dJmuXoxo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RXKHpApbXWxCHzZIFxDaePnTRIPPkx7fd2gBjWXrl0Q=;
        b=dJmuXoxoR2ebKOkVPfg/NJObqzbDxo0T1be0tynDB7z6tYj7G9hM8VM8rRfre8xL/V
         J+Mhfuo76Dpr63Aw9Nx1khyw6zIEO4MCNMrBfBI4bsC1uKIcpqgsTkXaJiPhA7PU4ypq
         itA0I7fvkdFB1bQqI0Iw+nFS+6FYEUIgYhaWX0RwgO6Yc6h2MLeMR9LWzeKWA1XVbY67
         RJFRIZTQDBGbYvJARugClvD7yC7wXXL3KUNIli7rE4gdOKYyYJjWvTsqAYPH2zkzkYwD
         n/MXITuQcZ+pBj1xyd1fo5wD2Td1v3bOR0R7eMo/k2I8zhFzEHgr2JM8YCmRgIlh0iyd
         4V/A==
X-Google-Smtp-Source: ALg8bN79Ji5SFeOBKJt3PLt4o/figJFVOUJpjacA7qTyh0mPZs5n0LFnTClGYX1AY0wZk8bxKDxdW0PBUJ/+g9Pum+o=
X-Received: by 2002:a63:4706:: with SMTP id u6mr3155263pga.95.1547214543132;
 Fri, 11 Jan 2019 05:49:03 -0800 (PST)
MIME-Version: 1.0
References: <cover.1546540962.git.andreyknvl@google.com> <52ddd881916bcc153a9924c154daacde78522227.1546540962.git.andreyknvl@google.com>
 <fc93e5a4-fa54-98a1-ea5f-4708568d7857@arm.com>
In-Reply-To: <fc93e5a4-fa54-98a1-ea5f-4708568d7857@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 11 Jan 2019 14:48:52 +0100
Message-ID:
 <CAAeHK+wYo95G3pSoxDWwUs2wf-tBoupwf+0XjO68WXjLzsNWaw@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] kasan, arm64: use ARCH_SLAB_MINALIGN instead of
 manual aligning
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, 
	Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, 
	Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, 
	Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, 
	Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Vishwath Mohan <vishwath@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111134852.wrremXHB74PXCLvYv4wxR2kGkNQnKiE6ccA95ezHRvQ@z>

On Wed, Jan 9, 2019 at 11:10 AM Vincenzo Frascino
<vincenzo.frascino@arm.com> wrote:
>
> On 03/01/2019 18:45, Andrey Konovalov wrote:
> > Instead of changing cache->align to be aligned to KASAN_SHADOW_SCALE_SIZE
> > in kasan_cache_create() we can reuse the ARCH_SLAB_MINALIGN macro.
> >
> > Suggested-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  arch/arm64/include/asm/cache.h | 6 ++++++
> >  mm/kasan/common.c              | 2 --
> >  2 files changed, 6 insertions(+), 2 deletions(-)
> >
> > diff --git a/arch/arm64/include/asm/cache.h b/arch/arm64/include/asm/cache.h
> > index 13dd42c3ad4e..eb43e09c1980 100644
> > --- a/arch/arm64/include/asm/cache.h
> > +++ b/arch/arm64/include/asm/cache.h
> > @@ -58,6 +58,12 @@
> >   */
> >  #define ARCH_DMA_MINALIGN    (128)
> >
> > +#ifdef CONFIG_KASAN_SW_TAGS
> > +#define ARCH_SLAB_MINALIGN   (1ULL << KASAN_SHADOW_SCALE_SHIFT)
> > +#else
> > +#define ARCH_SLAB_MINALIGN   __alignof__(unsigned long long)
> > +#endif
> > +
>
> Could you please remove the "#else" case here, because it is redundant (it is
> defined in linux/slab.h as ifndef) and could be misleading in future?

Sure, sent a patch. Thanks!

>
> >  #ifndef __ASSEMBLY__
> >
> >  #include <linux/bitops.h>
> > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > index 03d5d1374ca7..44390392d4c9 100644
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -298,8 +298,6 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
> >               return;
> >       }
> >
> > -     cache->align = round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
> > -
> >       *flags |= SLAB_KASAN;
> >  }
> >
> >
>
> --
> Regards,
> Vincenzo
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/fc93e5a4-fa54-98a1-ea5f-4708568d7857%40arm.com.
> For more options, visit https://groups.google.com/d/optout.

