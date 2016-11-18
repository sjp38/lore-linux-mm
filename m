Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A56FD6B0468
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:26:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so266755259pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 10:26:06 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b10si9261718pga.13.2016.11.18.10.26.05
        for <linux-mm@kvack.org>;
        Fri, 18 Nov 2016 10:26:05 -0800 (PST)
Date: Fri, 18 Nov 2016 18:25:24 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv3 6/6] arm64: Add support for CONFIG_DEBUG_VIRTUAL
Message-ID: <20161118182523.GG1197@leverpostej>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-7-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479431816-5028-7-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 17, 2016 at 05:16:56PM -0800, Laura Abbott wrote:
> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
> index 54bb209..0d37c19 100644
> --- a/arch/arm64/mm/Makefile
> +++ b/arch/arm64/mm/Makefile
> @@ -5,6 +5,7 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
>  obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
>  obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
>  obj-$(CONFIG_NUMA)		+= numa.o
> +obj-$(CONFIG_DEBUG_VIRTUAL)	+= physaddr.o

We'll also need:

KASAN_SANITIZE_physaddr.o	:= n

... or code prior to KASAN init will cause the kernel to die if
__virt_to_phys() or __phys_addr_symbol() are called.

>  obj-$(CONFIG_KASAN)		+= kasan_init.o
>  KASAN_SANITIZE_kasan_init.o	:= n

Thanks,
Mark,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
