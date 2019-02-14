Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE661C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E943222C9
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:57:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="UL/T0oQC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E943222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE7828E0002; Thu, 14 Feb 2019 09:57:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96A98E0001; Thu, 14 Feb 2019 09:57:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C85268E0002; Thu, 14 Feb 2019 09:57:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5A78E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:57:48 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id r85so10706758itc.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:57:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fOPW6Mt+59GqhiXIWQYxkAJiix/xK3/ru9QOvlEjTHQ=;
        b=rlNLqyq0RZ6xNYHx9aIjLQiOX4YyWWTt2NiqKNi2wED6hNh9wc068B8CkY0zz7kwCD
         uGFew5tnF6S0IK9ZIcn4g+E0i1M3JsIaKu3APtYbTS6RYwSrgBmZVDNw+qPVuVGotbDv
         mL7kF+RD/5CgVqg+F1EMQVpKzdL1tany9RCZvqlWL1ZNIyQ7z3SfErCF7iwNm67qrIdc
         4MfcSmZmswBJdsuq/t1GMkjnCOA4BIGauPZBUvAU5Mb7sEgYdeTlVaUQ139Q6uYDMaJ9
         ZNpk1JsydVtI0IgIvAXRWmeZ9mmPQKPLWJSn+0bfbaMjLbsocKhhGpMitaSw4M3h/ikE
         3Wsw==
X-Gm-Message-State: AHQUAuaoITWu57BoL2PCN2O5L0iFaxAZdkXznUHHpE0jM4S61n3J62Ik
	cRqvOKZ3JiFkeSF5+zc9CFG33vF2eLYYJi7tPlwArfsm0qneLNLkZC5a2RXqyHYoz8IFJlWHHMP
	HQnlHiOOzW1pmtGuKcnpHby4vQDoXrZXCh76NQ3iSHP0VXEKJGUSr25qtMNa1ASGTxzMuYGw0FD
	h2hhEkS//7LQYBABhztIuT+YCLZaC7nUGB5AV6Bz0z/Hsy7bkcLbxmTEomzKXgkmziUbBKzn3pd
	RviQi7Se5MADvNrm+PmnN20qfUPcOW+LZwL+UTsBXICj2nr/AYVrITCQIC183uzuhIEVxt+tI7A
	945jlSmTjkw/zcG+Pf8o+Ycjpy5qi5/1ta3YgyG1K2nQGbYCxm5ZmuUVZ1HeG48dcvBASuSoZOX
	Q
X-Received: by 2002:a6b:ca04:: with SMTP id a4mr2724181iog.254.1550156268353;
        Thu, 14 Feb 2019 06:57:48 -0800 (PST)
X-Received: by 2002:a6b:ca04:: with SMTP id a4mr2724131iog.254.1550156267528;
        Thu, 14 Feb 2019 06:57:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550156267; cv=none;
        d=google.com; s=arc-20160816;
        b=rf5NazZL1UIJ0TxufbwMeNGOEbL3TbNp+sdg/N2wuKQGKkZfsLdx/eXjg0j/ERtuNB
         Rj7yxifYYV0Go7sLfgIjnHLx5NoRq2OWxzHPAEaPUa2u/7BTgTEL+Qr2GRuHep+CPFoR
         UtMqER20fbG5LVRZfyqz99K4WDMeE0yz/kwS/Q31GzJYaF/ztj4GJovLv6SUfZSMJvfI
         rstShlREe5EGHBZQUb6dbf+gdCGe+Ak+0XzUW1EG+J4pSxWw+x1sJpHYQrfd89Z3aS9J
         a3NCrx6m5uZzYaRNNsAEdQlvM38jUNhsCbdO0Xn79WnzxhWFMQgiO6RV/Ir9jooIRWYS
         xy2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fOPW6Mt+59GqhiXIWQYxkAJiix/xK3/ru9QOvlEjTHQ=;
        b=gkXGgNNheU2QRvi3AL0HJH1OKxaFVmdpkJBbjQY42DBAdB7ANf9Ykv6e8R2gy6eIZG
         oynDQhLLEnN7rh4ULeZKEooOmviFeNA6ZqJf+UMSQovo1kHshDOW07RSpMIBoTEJ40bC
         f0amLOCkIB/MTwQ5dkG7lwLaCLS67QNLEnJAgios9K9qqqzEkCe9FGRAKgI3c0DbcrHc
         OBHWKK7Ew/BzGpdibGaBmLHGsKSfpL+op2w99+ZvKgNyun9Q3Ct8oLWdwUEH4/I5Xdke
         J8YbDz5PT1YKHlet0F9/L7oHhwoeNYuz1RzfHMeSM/Y7w6efsayxhj6eTr0PLdIfW4+x
         mWUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="UL/T0oQC";
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor4627312itd.1.2019.02.14.06.57.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 06:57:47 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="UL/T0oQC";
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fOPW6Mt+59GqhiXIWQYxkAJiix/xK3/ru9QOvlEjTHQ=;
        b=UL/T0oQCqgKvCW5nPoiBM7Y8F7aSSEpxcfUDxAo0vQC1OvFGRsdq38fuaiFmK2zJBo
         2Y48ArB40B2ckdZDZFdqfMOvPz4DJVWDAVcmt0Ls+wEfe0Ut0/1eluLcGVf9vAc7nuCd
         JL8XMGFeUS7k9t9hmJ+DpgOZSZOAIwiyssmX1DGDTnLLSLZMPy4NGfewXLM43B9udyOY
         ojAmtLxGnIQ7AKcuw/VJJtiRvR+zqQeAqox3TuGMTqwgFXM6CazXz5rYraCH1odEQ0tA
         HfDnBDU+AZJ5RPryWbwaBhn9+fu3QuGq7gf2FtBbZeKz+ECR15yZW43jqKWItcJ9Pzn5
         40Xw==
X-Google-Smtp-Source: AHgI3IZ+2b2BblXqrKvEkrJCR5O+CXFYXnxdZh01OqgqyL/HdORirJm2pPC+jw+AhflBBycYC/+F6UDZm9csI+MDKZ8=
X-Received: by 2002:a24:c3c4:: with SMTP id s187mr2541264itg.158.1550156267008;
 Thu, 14 Feb 2019 06:57:47 -0800 (PST)
MIME-Version: 1.0
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org> <20190214083350.GA9063@rapoport-lnx>
In-Reply-To: <20190214083350.GA9063@rapoport-lnx>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 14 Feb 2019 15:57:35 +0100
Message-ID: <CAKv+Gu8ZvMgS3VgkGVQthh-QWWoAmjxEDhj-pp98_BG4-810Wg@mail.gmail.com>
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-efi <linux-efi@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	James Morse <james.morse@arm.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 at 09:34, Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Wed, Feb 13, 2019 at 02:27:37PM +0100, Ard Biesheuvel wrote:
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
>
> I'd suggest
>
> s/INIT_MEMBLOCK_REGIONS/INIT_MEMORY_REGIONS
> s/INIT_MEMBLOCK_RESERVED_REGIONS/INIT_RESERVED_REGIONS
>

Well, I'd prefer to keep MEMBLOCK in the identifier, given that we are
setting it from an arch header file as well.

> Except that,
>
> Acked-by: Mike Rapoport <rppt@linux.ibm.com>
>

Thanks


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
> > --
> > 2.20.1
> >
>
> --
> Sincerely yours,
> Mike.
>

