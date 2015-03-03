Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 05AAE6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 11:38:13 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so23814184pdb.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 08:38:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id tm5si1732514pbc.65.2015.03.03.08.38.10
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 08:38:11 -0800 (PST)
Date: Tue, 3 Mar 2015 16:37:40 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 0/4] make memtest a generic kernel feature
Message-ID: <20150303163740.GA10239@leverpostej>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <Vladimir.Murzin@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>

On Mon, Mar 02, 2015 at 02:55:41PM +0000, Vladimir Murzin wrote:
> Hi,

Hi Vladimir,
 
> Memtest is a simple feature which fills the memory with a given set of
> patterns and validates memory contents, if bad memory regions is detected it
> reserves them via memblock API. Since memblock API is widely used by other
> architectures this feature can be enabled outside of x86 world.
> 
> This patch set promotes memtest to live under generic mm umbrella and enables
> memtest feature for arm/arm64.
> 
> Patches are built on top of 4.0-rc1

Thanks for putting this together. I've found this extremely useful for
tracking down an issue with some errant DMA on an arm64 platform. For
the first three patches:

Tested-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> 
> Vladimir Murzin (4):
>   mm: move memtest under /mm
>   memtest: use phys_addr_t for physical addresses
>   arm64: add support for memtest
>   arm: add support for memtest
> 
>  arch/arm/mm/init.c          |    3 ++
>  arch/arm64/mm/init.c        |    2 +
>  arch/x86/Kconfig            |   11 ----
>  arch/x86/include/asm/e820.h |    8 ---
>  arch/x86/mm/Makefile        |    2 -
>  arch/x86/mm/memtest.c       |  118 -------------------------------------------
>  include/linux/memblock.h    |    8 +++
>  lib/Kconfig.debug           |   11 ++++
>  mm/Makefile                 |    1 +
>  mm/memtest.c                |  118 +++++++++++++++++++++++++++++++++++++++++++
>  10 files changed, 143 insertions(+), 139 deletions(-)
>  delete mode 100644 arch/x86/mm/memtest.c
>  create mode 100644 mm/memtest.c
> 
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
