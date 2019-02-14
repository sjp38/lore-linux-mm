Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A004C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:55:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBBD521928
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:55:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="d99rXLfY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBBD521928
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EB698E0003; Thu, 14 Feb 2019 11:55:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79AC08E0001; Thu, 14 Feb 2019 11:55:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68A958E0003; Thu, 14 Feb 2019 11:55:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41D318E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:55:41 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id t18so11141172itk.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:55:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SbBKzNBycKxM70itibKfUlYiJ9pJfd1fqDbErtUvpXc=;
        b=ErHoxNb4mMBdYlRU+vOwYm4om2mG3qto6UWxZGCr3RQosuoI6uK5Ko6bw0fSzixZAg
         0ro5XoGfrYVRW3Z8aUufdb5SSZTO1pb4xnfZdLiK3IiUs2nYUshx2FH1dHVJ6Xl/DUhw
         8yg/aArBJ1AxSuqzJhGFn/DEl+YloovVxOy6PW/WtLP3TMHUoOARGPoLVam8supa/tPw
         A2vo7rDZI3bKRdYfDGH1C6EUebB6ImTp72KTPMSj4pclJOGUV8UUH/9bcvb0RyrjzhpL
         kjh9LmBjk/tfhZfll744THK6mGxCXSi9LnLFguCX1QgcLq2lMWhBMMDkXy6k6PQyEvlu
         Q22A==
X-Gm-Message-State: AHQUAuZsTPSTD2ZkH65juyEipqXbK2hz9+Yx/P5QRi31ERtnAYBCNErO
	aZqBZrHSUlGyn0MdqLoNCT/GyOpC+sDAwKDoN731V6n7ZPTXs75PsRW1GmWP9yfllAPjMqGqf4z
	XK4SGHrBg8vgJHmRkvZPx1GP1CKDLZsxNAWwi3HLSATjwPL67pns71wmjWmcCwF9BMhuQtINLiH
	yhhy90h9kaR9+ttfzclgoYSMSvkXAEQQ5EtxCYXqxfgqLeSvqgnQlciYQ1W5a5J7iXoxTTdYOgc
	iQsRMv4dk0nIQolZjbxwiyRZAUBWX+gdTHuai2eRGiuKIL9gBH1wHl0g5RoX/8GQY5nQRzX/gGz
	/Js0oM4XGu5dIWz11yNkvZ1lEko0GcFdCJ1HQrvGLsUelO3HZNRigB3B+G6zc18QeFyosygNB0V
	t
X-Received: by 2002:a5d:9a98:: with SMTP id c24mr2927870iom.227.1550163341005;
        Thu, 14 Feb 2019 08:55:41 -0800 (PST)
X-Received: by 2002:a5d:9a98:: with SMTP id c24mr2927828iom.227.1550163340083;
        Thu, 14 Feb 2019 08:55:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550163340; cv=none;
        d=google.com; s=arc-20160816;
        b=a+KtMkC2awngC32rOrIH9/E2YGRD/jiRASeC/MWLXnAeboBJB9oIvBn+7Wk4ZG31P0
         zzNlXhP1BKsvuSGAlYmLowtHMtXeXEKfU8GwwUkpSCVa12Q3diUesryyPd5QJVHI3WG6
         MvB1JMM+uXOt5KqjcpOtxgRwgEBn2Cpcztxg4W6GeTWXg8EFAJmrgxduHKEzwFKmnWgh
         WF7ijlLgYbBmmM7/p/5FRDio7J0sPc+U51HFMDQq9LOGCimRB6VrnpW+BtrB8oo662wm
         +klLaaSoLPW7lt7NWTVVoDFruLrBn4x/nwFfi3BA1qY3Mdnaw1/2IzfQhM0I54OTJpI/
         vF/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SbBKzNBycKxM70itibKfUlYiJ9pJfd1fqDbErtUvpXc=;
        b=vJ7tzz2bEXXj90o97zmyl6xFaTDQE5AvmmqEDpnV5+VkohfdHXtkWxkSsCDzeQnLop
         0XnBUZAEV2IjigXnJMLJjwxLbO2KjeQlkRq4OfpSrPF/0PTypua7ZB72OZ6ZJnNCjAO1
         AY53U1rFC79evCNR5IY7yC+efNLcDUlhw8t8fQYpWUNpc9zPWIpjL3yf06Mdw6Mvfsql
         IAV6CdhLRHYPzYv5flq2QMBo/jZjMZ3P+GTTUxhTYZVsLGp99+M6/cGBur9g71s+esZ8
         xZCvqMgvI4MTeTvjKFrUoqj/n9owAS1aQY+sclyS+ofusmu/jX7MrG3r5yqe12UOxudN
         QsgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=d99rXLfY;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor5122287itk.35.2019.02.14.08.55.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 08:55:40 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=d99rXLfY;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SbBKzNBycKxM70itibKfUlYiJ9pJfd1fqDbErtUvpXc=;
        b=d99rXLfYTXazHCp6agNx8f/TLrwjgUX4pj1ny26fJvjhOaGgaaZY49A6iZYz1cC65e
         uCd3zm7zE3ZYC6rgH67f+DE4uDpu/g3bP0uCzpDWTKuTUmfpwg/SdX6DX2nLNWDIwMN1
         LRPPsMwJgF22mEVbaRzYEG02AaBjDffWJn2u7lz0B8U7IjQV5jOAD00Fl2SUMdCaF1f2
         tui1aHAa/JkdiocARufySsS6A22M3Ml15Zn3nkYZBzPmpubtvxPqADRb73PxSaCp14vP
         rIxjo48gfu+NbF4kw5YiMMgNIebHdF14IKJFs8DhM2qvcdaxK6lgOkGolVYaRKSN7sML
         KS3w==
X-Google-Smtp-Source: AHgI3IZ73trhTnBp56oqdiFpvhVapXV9PZgD9Ci4654hxG67oSOYjdqP39cfx3Orco0gZ94/lV+wvRPodce2JKUFiM4=
X-Received: by 2002:a24:c3c4:: with SMTP id s187mr2932777itg.158.1550163339656;
 Thu, 14 Feb 2019 08:55:39 -0800 (PST)
MIME-Version: 1.0
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org> <325ae70b-6520-a186-c65f-8ab29a5be3a5@arm.com>
In-Reply-To: <325ae70b-6520-a186-c65f-8ab29a5be3a5@arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 14 Feb 2019 17:55:28 +0100
Message-ID: <CAKv+Gu9BpVDg1=2bsR6ouWM2Xw1OZGMOZ4DXv5fQxE=HQXJsRg@mail.gmail.com>
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux-efi <linux-efi@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, James Morse <james.morse@arm.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 at 16:48, Marc Zyngier <marc.zyngier@arm.com> wrote:
>
> Hi Ard,
>
> On 13/02/2019 13:27, Ard Biesheuvel wrote:
> > In the irqchip and EFI code, we have what basically amounts to a quirk
> > to work around a peculiarity in the GICv3 architecture, which permits
> > the system memory address of LPI tables to be programmable only once
> > after a CPU reset. This means kexec kernels must use the same memory
> > as the first kernel, and thus ensure that this memory has not been
> > given out for other purposes by the time the ITS init code runs, which
> > is not very early for secondary CPUs.
> >
> > On systems with many CPUs, these reservations could overflow the
> > memblock reservation table, and this was addressed in commit
> > eff896288872 ("efi/arm: Defer persistent reservations until after
> > paging_init()"). However, this turns out to have made things worse,
> > since the allocation of page tables and heap space for the resized
> > memblock reservation table itself may overwrite the regions we are
> > attempting to reserve, which may cause all kinds of corruption,
> > also considering that the ITS will still be poking bits into that
> > memory in response to incoming MSIs.
> >
> > So instead, let's grow the static memblock reservation table on such
> > systems so it can accommodate these reservations at an earlier time.
> > This will permit us to revert the above commit in a subsequent patch.
> >
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > ---
> >  arch/arm64/include/asm/memory.h | 11 +++++++++++
> >  include/linux/memblock.h        |  3 ---
> >  mm/memblock.c                   | 10 ++++++++--
> >  3 files changed, 19 insertions(+), 5 deletions(-)
> >
> > diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> > index e1ec947e7c0c..7e2b13cdd970 100644
> > --- a/arch/arm64/include/asm/memory.h
> > +++ b/arch/arm64/include/asm/memory.h
> > @@ -332,6 +332,17 @@ static inline void *phys_to_virt(phys_addr_t x)
> >  #define virt_addr_valid(kaddr)               \
> >       (_virt_addr_is_linear(kaddr) && _virt_addr_valid(kaddr))
> >
> > +/*
> > + * Given that the GIC architecture permits ITS implementations that can only be
> > + * configured with a LPI table address once, GICv3 systems with many CPUs may
> > + * end up reserving a lot of different regions after a kexec for their LPI
> > + * tables, as we are forced to reuse the same memory after kexec (and thus
> > + * reserve it persistently with EFI beforehand)
> > + */
> > +#if defined(CONFIG_EFI) && defined(CONFIG_ARM_GIC_V3_ITS)
> > +#define INIT_MEMBLOCK_RESERVED_REGIONS       (INIT_MEMBLOCK_REGIONS + 2 * NR_CPUS)
>
> Since GICv3 has 1 pending table per CPU, plus one global property table,
> can we make this 2 * NR_CPUS + 1? Or is that enough already?
>

Ah, I misread the code then. That would mean we'll only need 1 extra
slot per CPU.

So I will change this to

> > +#define INIT_MEMBLOCK_RESERVED_REGIONS       (INIT_MEMBLOCK_REGIONS + NR_CPUS)

considering that INIT_MEMBLOCK_REGIONS defaults to 128, so that one
global table is already accounted for.


> > +#endif
> > +
> >  #include <asm-generic/memory_model.h>
> >
> >  #endif
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index 64c41cf45590..859b55b66db2 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -29,9 +29,6 @@ extern unsigned long max_pfn;
> >   */
> >  extern unsigned long long max_possible_pfn;
> >
> > -#define INIT_MEMBLOCK_REGIONS        128
> > -#define INIT_PHYSMEM_REGIONS 4
> > -
> >  /**
> >   * enum memblock_flags - definition of memory region attributes
> >   * @MEMBLOCK_NONE: no special request
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 022d4cbb3618..a526c3ab8390 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -26,6 +26,12 @@
> >
> >  #include "internal.h"
> >
> > +#define INIT_MEMBLOCK_REGIONS                128
> > +#define INIT_PHYSMEM_REGIONS         4
> > +#ifndef INIT_MEMBLOCK_RESERVED_REGIONS
> > +#define INIT_MEMBLOCK_RESERVED_REGIONS       INIT_MEMBLOCK_REGIONS
> > +#endif
> > +
> >  /**
> >   * DOC: memblock overview
> >   *
> > @@ -92,7 +98,7 @@ unsigned long max_pfn;
> >  unsigned long long max_possible_pfn;
> >
> >  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> > -static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> > +static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_RESERVED_REGIONS] __initdata_memblock;
> >  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> >  static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS] __initdata_memblock;
> >  #endif
> > @@ -105,7 +111,7 @@ struct memblock memblock __initdata_memblock = {
> >
> >       .reserved.regions       = memblock_reserved_init_regions,
> >       .reserved.cnt           = 1,    /* empty dummy entry */
> > -     .reserved.max           = INIT_MEMBLOCK_REGIONS,
> > +     .reserved.max           = INIT_MEMBLOCK_RESERVED_REGIONS,
> >       .reserved.name          = "reserved",
> >
> >  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> >
>
> Otherwise:
>
> Acked-by: Marc Zyngier <marc.zyngier@arm.com>
>
>         M.
> --
> Jazz is not dead. It just smells funny...

