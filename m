Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 047286B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:10:19 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so85546691pac.3
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 04:10:18 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id rf10si8409552pab.94.2015.11.26.04.10.17
        for <linux-mm@kvack.org>;
        Thu, 26 Nov 2015 04:10:18 -0800 (PST)
Date: Thu, 26 Nov 2015 12:10:08 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
Message-ID: <20151126121007.GC32343@leverpostej>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com>
 <5649F783.40109@gmail.com>
 <564B40A7.1000206@arm.com>
 <564B4BFC.1020905@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <564B4BFC.1020905@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, linux-arm-kernel@lists.infradead.org

Hi Catalin,

Can you pick up Andrey's patch below for v4.4, until we have a better
solution?

I stumbled across this myself and was about to post a similar patch.

FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

On Tue, Nov 17, 2015 at 06:47:08PM +0300, Andrey Ryabinin wrote:
> We should either add proper Kconfig dependency for now, or just make it work.
> 
> 
> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Subject: [PATCH] arm64: KASAN depends on !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
> 
> On KASAN + 16K_PAGES + 48BIT_VA
>  arch/arm64/mm/kasan_init.c: In function a??kasan_early_inita??:
>  include/linux/compiler.h:484:38: error: call to a??__compiletime_assert_95a?? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
>     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> 
> Currently KASAN will not work on 16K_PAGES and 48BIT_VA, so
> forbid such configuration to avoid above build failure.
> 
> Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  arch/arm64/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 9ac16a4..bf7de69 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -49,7 +49,7 @@ config ARM64
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
> -	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
> +	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
> -- 
> 2.4.10
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
