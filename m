Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5079003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:40:42 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so79580979igb.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 09:40:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ka10si6578874igb.53.2015.07.27.09.40.41
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 09:40:41 -0700 (PDT)
Date: Mon, 27 Jul 2015 17:40:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v4 1/7] x86/kasan: generate KASAN_SHADOW_OFFSET in
 Makefile
Message-ID: <20150727164034.GC350@e104818-lin.cambridge.arm.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-2-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437756119-12817-2-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Michal Marek <mmarek@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, Jul 24, 2015 at 07:41:53PM +0300, Andrey Ryabinin wrote:
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index b3a1a5d..6d6dd6f 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -255,11 +255,6 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
>  config ARCH_SUPPORTS_DEBUG_PAGEALLOC
>  	def_bool y
>  
> -config KASAN_SHADOW_OFFSET
> -	hex
> -	depends on KASAN
> -	default 0xdffffc0000000000
> -
>  config HAVE_INTEL_TXT
>  	def_bool y
>  	depends on INTEL_IOMMU && ACPI
> diff --git a/arch/x86/Makefile b/arch/x86/Makefile
> index 118e6de..c666989 100644
> --- a/arch/x86/Makefile
> +++ b/arch/x86/Makefile
> @@ -39,6 +39,8 @@ ifdef CONFIG_X86_NEED_RELOCS
>          LDFLAGS_vmlinux := --emit-relocs
>  endif
>  
> +KASAN_SHADOW_OFFSET := 0xdffffc0000000000

To keep things simple for x86, can you not just define:

KASAN_SHADOW_OFFSET := $(CONFIG_KASAN_SHADOW_OFFSET)

or, even better, in scripts/Makefile.kasan:

KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)

and set it under arch/arm64/Makefile only.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
