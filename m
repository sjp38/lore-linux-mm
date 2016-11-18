Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 696536B03B5
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:25:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so8511608wmd.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:25:26 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id x69si1561180wme.157.2016.11.18.00.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 00:25:25 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so3612692wma.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:25:25 -0800 (PST)
Date: Fri, 18 Nov 2016 09:25:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv3 1/6] lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
Message-ID: <20161118082521.GA7250@gmail.com>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-2-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479431816-5028-2-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


* Laura Abbott <labbott@redhat.com> wrote:

> 
> DEBUG_VIRTUAL currently depends on DEBUG_KERNEL && X86. arm64 is getting
> the same support. Rather than add a list of architectures, switch this
> to ARCH_HAS_DEBUG_VIRTUAL and let architectures select it as
> appropriate.
> 
> Suggested-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> v3: No change, x86 maintainers please ack if you are okay with this.
> ---
>  arch/x86/Kconfig  | 1 +
>  lib/Kconfig.debug | 5 ++++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index bada636..f533321 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -23,6 +23,7 @@ config X86
>  	select ARCH_CLOCKSOURCE_DATA
>  	select ARCH_DISCARD_MEMBLOCK
>  	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
> +	select ARCH_HAS_DEBUG_VIRTUAL
>  	select ARCH_HAS_DEVMEM_IS_ALLOWED
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FAST_MULTIPLIER

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
