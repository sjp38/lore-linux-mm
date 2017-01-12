Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB1166B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:33:52 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so64184865pfy.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:33:52 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g9si9876895plk.185.2017.01.12.09.33.51
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 09:33:51 -0800 (PST)
Date: Thu, 12 Jan 2017 17:33:53 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv7 00/11] CONFIG_DEBUG_VIRTUAL for arm64
Message-ID: <20170112173352.GJ13843@arm.com>
References: <1484084150-1523-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484084150-1523-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Florian Fainelli <f.fainelli@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>

On Tue, Jan 10, 2017 at 01:35:39PM -0800, Laura Abbott wrote:
> This is v7 of the patches to add CONFIG_DEBUG_VIRTUAL for arm64. This is
> a simple reordering of patches from v6 per request of Will Deacon for ease
> of merging support for arm which depends on this series.
> 
> Laura Abbott (11):
>   lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
>   mm/cma: Cleanup highmem check
>   mm: Introduce lm_alias
>   kexec: Switch to __pa_symbol
>   mm/kasan: Switch to using __pa_symbol and lm_alias
>   mm/usercopy: Switch to using lm_alias
>   drivers: firmware: psci: Use __pa_symbol for kernel symbol
>   arm64: Move some macros under #ifndef __ASSEMBLY__
>   arm64: Add cast for virt_to_pfn
>   arm64: Use __pa_symbol for kernel symbols
>   arm64: Add support for CONFIG_DEBUG_VIRTUAL

I've pushed this into linux-next and, assuming it survives the
autobuilders etc I'll co-ordinate with Russell to get the common parts
pulled into the ARM tree too (so he can take Florian's series). They're
currently split out on the arm64 for-next/debug-virtual branch.

Thanks!

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
