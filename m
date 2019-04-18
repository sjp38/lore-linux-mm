Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED80BC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:31:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D1A121479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:31:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="fB72dc+b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D1A121479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55AE16B0007; Thu, 18 Apr 2019 01:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532246B0008; Thu, 18 Apr 2019 01:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 421CF6B000A; Thu, 18 Apr 2019 01:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20EF16B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:31:48 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id g67so184768vsd.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wdpJY50vmVyqQ1PqbhbBydmQ/xHEoQMQSJOB3RmLp0Q=;
        b=Kd75uqp0EHjDJ4M86dca8w8yya1tSzTT4V3gYWO/XUyzzM2glcg0fwL9Gq+NDkZM21
         8wwI2GrQHY3Fd5frd28opQ0hMZj5MjKkP8JFVGQdO0F9dCVF4Q+fu1Lrr/Z0YDTJXKbc
         rbKto+OjvAwa0la2HwVKAh8KHKcLD1ahelLqDSDkrbo28VHxa5LKFxfc9/u1I7jPIH+b
         uI8CLhmmUhcPoHbcjGv+7QfgYJD5phrVz0Eq+9yj8hCMwBbe6lsdCCRZP0ss9TOb90mF
         XfiNwnbJqQ7WpTD8wN0U+gZd1tUPHeEtwXA5Vljh4MdpjuYqzPXpqN0MAcp2TZoRHTN6
         MIvg==
X-Gm-Message-State: APjAAAVXds1lMZ9VJpZx5iRTBeoaAor3sgv1q7FfKles3dQVTWw8lMKb
	lctfT8ogSkRrvw087WK/CrqHgYctYBFOwNDzwZ0CZC6oQo2kB2GhaupYuJ54w0v74CErQy3e1ZH
	tzv3NoHYNmc96H25HDGK2LzsjOxo0zQpZ2g1wr1lDQlpM7s9ahOLrkufEooggETesGw==
X-Received: by 2002:a67:8c42:: with SMTP id o63mr50774165vsd.160.1555565507880;
        Wed, 17 Apr 2019 22:31:47 -0700 (PDT)
X-Received: by 2002:a67:8c42:: with SMTP id o63mr50774144vsd.160.1555565507158;
        Wed, 17 Apr 2019 22:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565507; cv=none;
        d=google.com; s=arc-20160816;
        b=hgurgL2LnM0Zc0hZz1XRAz42EJeTSSUAU59w/VX9oP2LbdZuO7A6MujFAJf2n0s5ok
         aZOd8F66h6ElQ/98CUK59OBDf3VlPyjezk07Ob/XMDCML4/axebZVucbE3yJz4JKEeOa
         y/m6x0DAImRvBFQzTfgcup3pJhECri+r2D2S7wbJlk6n6SKZtETRcFNB5iDsr6ITTDSW
         1ZZPaYoddCJFM0Nexr31krTfVslgIYx/nrTV2PxXY0Hh6vhek3mGUUHN6QZ3WHCGv1FW
         +S3rSmwIITtgWCWwu2Jj8pI2HqaMU/eN0mVDHVztV4hIeyeOMKXE0i96Hi3d2S/AoU2d
         kqHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wdpJY50vmVyqQ1PqbhbBydmQ/xHEoQMQSJOB3RmLp0Q=;
        b=uS4nNCKLVuzjEP7exwnCXSs6dxSRP4DCirMDKtRZ5zsnsZxgCCSH2wMhvyUtCxXfIm
         UoN+9WNHCHtHAqAoimltzppEmPYzwqYCaYbYSweNFFFpbA1WT2xdGwTFYVtaj6Qhnz5q
         kggRNTS5mzDHz/atYPFNoK8qS4meluQlRKRODV6gpDS8fEP2OJkjIQM/LvdNN1H91TpL
         8UXVS4qhLxkXcbsjfTEqNaSs/hinc2YbYoR9asOUoermy1amwJxKw36E48DK+RWtrVCJ
         7VryQ9BM9n3bz/jZadGPWIQu1l5d5Is92/EK+XPLLctY3S0e+NEDfiYrXTbwLHWvRFsb
         Q7YA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fB72dc+b;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q22sor405426vsk.1.2019.04.17.22.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fB72dc+b;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wdpJY50vmVyqQ1PqbhbBydmQ/xHEoQMQSJOB3RmLp0Q=;
        b=fB72dc+b7uA3lZK0fM9coqknIBIeertJI7ikFyB/vi7+UhDzB4cM6BaPZBCgwdkMbP
         I6OuKXmEOkVuVbufdWR2exS5gdkih7q9m6sKqDvBv1Q9ecvRbsRvxC0p09WYg4f8ZR9Y
         lqwGyEe02y/u1sfKZHci1wzyCEwvxabZUD3T4=
X-Google-Smtp-Source: APXvYqxP9f8me+h+uhxqKEJf37zUPTvPxnB3w9WCjdVlLKDH1RaOKi35SRDDUA1xoBvmKzg6+tP8oA==
X-Received: by 2002:a67:c498:: with SMTP id d24mr30952193vsk.182.1555565505411;
        Wed, 17 Apr 2019 22:31:45 -0700 (PDT)
Received: from mail-vk1-f174.google.com (mail-vk1-f174.google.com. [209.85.221.174])
        by smtp.gmail.com with ESMTPSA id t128sm493091vka.36.2019.04.17.22.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:31:44 -0700 (PDT)
Received: by mail-vk1-f174.google.com with SMTP id w140so216616vkd.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:31:43 -0700 (PDT)
X-Received: by 2002:a1f:3458:: with SMTP id b85mr50194265vka.4.1555565503193;
 Wed, 17 Apr 2019 22:31:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-11-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-11-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:31:32 -0500
X-Gmail-Original-Message-ID: <CAGXu5jJSgHKjrQ2Z-aKofqroUDBjPnLOjiORw9pHT_cANhAqpg@mail.gmail.com>
Message-ID: <CAGXu5jJSgHKjrQ2Z-aKofqroUDBjPnLOjiORw9pHT_cANhAqpg@mail.gmail.com>
Subject: Re: [PATCH v3 10/11] mips: Use generic mmap top-down layout
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, 
	Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, 
	linux-riscv@lists.infradead.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:33 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> mips uses a top-down layout by default that fits the generic functions.
> At the same time, this commit allows to fix problem uncovered
> and not fixed for mips here:
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/Kconfig                 |  1 +
>  arch/mips/include/asm/processor.h |  5 ---
>  arch/mips/mm/mmap.c               | 67 -------------------------------
>  3 files changed, 1 insertion(+), 72 deletions(-)
>
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index 4a5f5b0ee9a9..ec2f07561e4d 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -14,6 +14,7 @@ config MIPS
>         select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
>         select ARCH_USE_QUEUED_RWLOCKS
>         select ARCH_USE_QUEUED_SPINLOCKS
> +       select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>         select ARCH_WANT_IPC_PARSE_VERSION
>         select BUILDTIME_EXTABLE_SORT
>         select CLONE_BACKWARDS
> diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
> index aca909bd7841..fba18d4a9190 100644
> --- a/arch/mips/include/asm/processor.h
> +++ b/arch/mips/include/asm/processor.h
> @@ -29,11 +29,6 @@
>
>  extern unsigned int vced_count, vcei_count;
>
> -/*
> - * MIPS does have an arch_pick_mmap_layout()
> - */
> -#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
> -
>  #ifdef CONFIG_32BIT
>  #ifdef CONFIG_KVM_GUEST
>  /* User space process size is limited to 1GB in KVM Guest Mode */
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index ffbe69f3a7d9..61e65a69bb09 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -20,43 +20,6 @@
>  unsigned long shm_align_mask = PAGE_SIZE - 1;  /* Sane caches */
>  EXPORT_SYMBOL(shm_align_mask);
>
> -/* gap between mmap and stack */
> -#define MIN_GAP                (128*1024*1024UL)
> -#define MAX_GAP                ((STACK_TOP)/6*5)
> -#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
> -
> -static int mmap_is_legacy(struct rlimit *rlim_stack)
> -{
> -       if (current->personality & ADDR_COMPAT_LAYOUT)
> -               return 1;
> -
> -       if (rlim_stack->rlim_cur == RLIM_INFINITY)
> -               return 1;
> -
> -       return sysctl_legacy_va_layout;
> -}
> -
> -static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
> -{
> -       unsigned long gap = rlim_stack->rlim_cur;
> -       unsigned long pad = stack_guard_gap;
> -
> -       /* Account for stack randomization if necessary */
> -       if (current->flags & PF_RANDOMIZE)
> -               pad += (STACK_RND_MASK << PAGE_SHIFT);
> -
> -       /* Values close to RLIM_INFINITY can overflow. */
> -       if (gap + pad > gap)
> -               gap += pad;
> -
> -       if (gap < MIN_GAP)
> -               gap = MIN_GAP;
> -       else if (gap > MAX_GAP)
> -               gap = MAX_GAP;
> -
> -       return PAGE_ALIGN(STACK_TOP - gap - rnd);
> -}
> -
>  #define COLOUR_ALIGN(addr, pgoff)                              \
>         ((((addr) + shm_align_mask) & ~shm_align_mask) +        \
>          (((pgoff) << PAGE_SHIFT) & shm_align_mask))
> @@ -154,36 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
>                         addr0, len, pgoff, flags, DOWN);
>  }
>
> -unsigned long arch_mmap_rnd(void)
> -{
> -       unsigned long rnd;
> -
> -#ifdef CONFIG_COMPAT
> -       if (TASK_IS_32BIT_ADDR)
> -               rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> -       else
> -#endif /* CONFIG_COMPAT */
> -               rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> -
> -       return rnd << PAGE_SHIFT;
> -}
> -
> -void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
> -{
> -       unsigned long random_factor = 0UL;
> -
> -       if (current->flags & PF_RANDOMIZE)
> -               random_factor = arch_mmap_rnd();
> -
> -       if (mmap_is_legacy(rlim_stack)) {
> -               mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
> -               mm->get_unmapped_area = arch_get_unmapped_area;
> -       } else {
> -               mm->mmap_base = mmap_base(random_factor, rlim_stack);
> -               mm->get_unmapped_area = arch_get_unmapped_area_topdown;
> -       }
> -}
> -
>  static inline unsigned long brk_rnd(void)
>  {
>         unsigned long rnd = get_random_long();
> --
> 2.20.1
>


-- 
Kees Cook

