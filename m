Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEE9C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AF7621479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="WZmIDWwI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AF7621479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C9726B0007; Thu, 18 Apr 2019 01:28:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079446B0008; Thu, 18 Apr 2019 01:28:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0986B000A; Thu, 18 Apr 2019 01:28:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id C84586B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:28:48 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id z206so183399vsz.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YsXAYO0c8zFLQiUk70GsGhFvh+QJiSpbjT3b+4rW66I=;
        b=HI05orBcafTMB00VR2PHW/fdcWw0eMEt0fGBsN+4Y4ZhbXHPU+Oev5sFCE7EbHfn4R
         4pYJhc6+Hd8vmkS4AdoU1bi6zzuzbQT79vOAN8hXzCQ+dbfOULheAuQ0+wf76M1Vo3bQ
         PBmVWXtSD03HorXpwH6h9nZB6EJ+BzJ8kt+jJHC6abxSiX2iIAFPa+JTsEcAJz5JKrx9
         eV8uCG/jqk4gVLvCjfOtR36254qs7UkakAwpIjtdEu8DqVQsBdmTMsCTBl5TGcKqN+hY
         SyVSpdyzYA7eM2BpS4mjo7tgqgsLkgkgeURt+eiaWUjB5HCcSyzBxJoemw1zDygBCxVH
         688w==
X-Gm-Message-State: APjAAAUIa/MTtr0msDXxh8vPwfW68DC7J+qd+FodgdwGQrfKY8FgiBq7
	fBUyNTpY4U/19jddMYtz0wpwVyB6feqAwzItSo10GeFG5vgy8gT3spK8+TrKexZB8vFH671McSd
	/nNawUImX/D32Iui871zIcaXqz/JpPMYMy7K5C1rc8K3PX0MuDeij1eD5LvUVtVkv0g==
X-Received: by 2002:a1f:b297:: with SMTP id b145mr49650865vkf.74.1555565328571;
        Wed, 17 Apr 2019 22:28:48 -0700 (PDT)
X-Received: by 2002:a1f:b297:: with SMTP id b145mr49650857vkf.74.1555565327942;
        Wed, 17 Apr 2019 22:28:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565327; cv=none;
        d=google.com; s=arc-20160816;
        b=h3mmdq/0ffbIsV4xt7K7lv0VbkR+fQuBdlX3+uDZM2DrK9rgSJZExNuHO9R5oRJAyr
         /H88un/M/Z8MSht/0zO/3ToKLwY0uS+pgCowsLysfxL8cwdPpmt3zfiJ/VWWcwnnNxeA
         cpmdl5S688z2t9dcqBvCpdGCHPo+6Z9dJ4BGcfJB7jRWYhJgOtDcp2y/rMbKzUb4GNvN
         KIOTuFysM/asU7+k2pO6AkrZML45avBR/5lU0+L0l05gmzbVOjDvdauie2+/oXYD36EL
         bdgu5m2q99TOP2bhXpb6Jj/V0CTBLEj+2eCxZEQf5RqG2GBJEom/ALqBEiH87rapE8fH
         JDRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YsXAYO0c8zFLQiUk70GsGhFvh+QJiSpbjT3b+4rW66I=;
        b=lMZaNHhO+E3AzJSm6GXMkTRDFEo/7t9lvJXe4iF7B1wLLCBFBZT6ivIMNERSNsp+gf
         cnKSc3cAJi1fPsZkykNtpgQvYNW/GakIN5MF17HlBNVkDFILCgScG/bzgs1hSwA41pPa
         RzIQ3IwwgL4gHzgUEAKkzCdduYE27axzVK4UIUArSiG/1LuU97KuBCwS2WV4nG1dqLGm
         J5SitZbNmt7d369Z8nVjPwsWogTy+LPwWFoSCdeTpjAkO3x6Qb7WVBaH4lnZBxeEOxpK
         pTDosuYpdxxLM2T8ny1HPYS+0AGJawfsleQ8TvaVMTSAvZ6aDa+BMNwkBmY7L8DbMpev
         Aicg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=WZmIDWwI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11sor520885ual.11.2019.04.17.22.28.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:28:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=WZmIDWwI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YsXAYO0c8zFLQiUk70GsGhFvh+QJiSpbjT3b+4rW66I=;
        b=WZmIDWwIQt+p2U8OFcegWRRVLp6nJI1rwc15/sOJzGCUmcSGRFPVv48qDCitMPl6bn
         rM78n9VYubygolMm6Ghe0eVh8aEQd+wbbsAcLH0uKTj/Hr9dtxdm7CrqSOZUwvjdwtFp
         4/y4Gx8iiVq8g1yfl8tKAiGgIRUjAi38RRMeM=
X-Google-Smtp-Source: APXvYqwdRwhY1CNojGvmOHJW4LwFgrbvTinvwuvZWMSXNqrZ1kzv84OIelFVtJiQ4FsHpXYqMmoOng==
X-Received: by 2002:ab0:3058:: with SMTP id x24mr49112657ual.95.1555565327733;
        Wed, 17 Apr 2019 22:28:47 -0700 (PDT)
Received: from mail-vk1-f173.google.com (mail-vk1-f173.google.com. [209.85.221.173])
        by smtp.gmail.com with ESMTPSA id q128sm329404vke.2.2019.04.17.22.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:28:47 -0700 (PDT)
Received: by mail-vk1-f173.google.com with SMTP id 195so209094vkx.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:46 -0700 (PDT)
X-Received: by 2002:a1f:7245:: with SMTP id n66mr38243289vkc.40.1555565326448;
 Wed, 17 Apr 2019 22:28:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-8-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-8-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:28:34 -0500
X-Gmail-Original-Message-ID: <CAGXu5jLhZS3+tiDCMsQQ=s9_f5ZBTLEYfcSfmtDRYv8Pp-KF2Q@mail.gmail.com>
Message-ID: <CAGXu5jLhZS3+tiDCMsQQ=s9_f5ZBTLEYfcSfmtDRYv8Pp-KF2Q@mail.gmail.com>
Subject: Re: [PATCH v3 07/11] arm: Use generic mmap top-down layout
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

On Wed, Apr 17, 2019 at 12:30 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> arm uses a top-down mmap layout by default that exactly fits the generic
> functions, so get rid of arch specific code and use the generic version
> by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/arm/Kconfig                 |  1 +
>  arch/arm/include/asm/processor.h |  2 --
>  arch/arm/mm/mmap.c               | 62 --------------------------------
>  3 files changed, 1 insertion(+), 64 deletions(-)
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 850b4805e2d1..f8f603da181f 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -28,6 +28,7 @@ config ARM
>         select ARCH_SUPPORTS_ATOMIC_RMW
>         select ARCH_USE_BUILTIN_BSWAP
>         select ARCH_USE_CMPXCHG_LOCKREF
> +       select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>         select ARCH_WANT_IPC_PARSE_VERSION
>         select BUILDTIME_EXTABLE_SORT if MMU
>         select CLONE_BACKWARDS
> diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
> index 57fe73ea0f72..944ef1fb1237 100644
> --- a/arch/arm/include/asm/processor.h
> +++ b/arch/arm/include/asm/processor.h
> @@ -143,8 +143,6 @@ static inline void prefetchw(const void *ptr)
>  #endif
>  #endif
>
> -#define HAVE_ARCH_PICK_MMAP_LAYOUT
> -
>  #endif
>
>  #endif /* __ASM_ARM_PROCESSOR_H */
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index 0b94b674aa91..b8d912ac9e61 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -17,43 +17,6 @@
>         ((((addr)+SHMLBA-1)&~(SHMLBA-1)) +      \
>          (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
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
>  /*
>   * We need to ensure that shared mappings are correctly aligned to
>   * avoid aliasing issues with VIPT caches.  We need to ensure that
> @@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>         return addr;
>  }
>
> -unsigned long arch_mmap_rnd(void)
> -{
> -       unsigned long rnd;
> -
> -       rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
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
>  /*
>   * You really shouldn't be using read() or write() on /dev/mem.  This
>   * might go away in the future.
> --
> 2.20.1
>


-- 
Kees Cook

