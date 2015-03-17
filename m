Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACBC6B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:18:29 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so16985856iec.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:18:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y9si60504pdj.185.2015.03.17.10.18.27
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 10:18:28 -0700 (PDT)
Date: Tue, 17 Mar 2015 17:18:22 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/6] make memtest a generic kernel feature
Message-ID: <20150317171822.GW8399@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <Vladimir.Murzin@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, Mark Rutland <Mark.Rutland@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "baruch@tkos.co.il" <baruch@tkos.co.il>, "rdunlap@infradead.org" <rdunlap@infradead.org>

On Mon, Mar 09, 2015 at 10:27:04AM +0000, Vladimir Murzin wrote:
> Memtest is a simple feature which fills the memory with a given set of
> patterns and validates memory contents, if bad memory regions is detected it
> reserves them via memblock API. Since memblock API is widely used by other
> architectures this feature can be enabled outside of x86 world.
> 
> This patch set promotes memtest to live under generic mm umbrella and enables
> memtest feature for arm/arm64.
> 
> It was reported that this patch set was useful for tracking down an issue with
> some errant DMA on an arm64 platform.
> 
> Since it touches x86 and mm bits it'd be great to get ACK/NAK for these bits.

Is your intention for akpm to merge this? I don't mind how it goes upstream,
but that seems like a sensible route to me.

Will

> Changelog:
> 
>     RFC -> v1
>         - updated kernel-parameters.txt for memtest entry
>         - updated number of test patterns in Kconfig menu
>         - added Acked/Tested tags for arm64 bits
>         - rebased on v4.0-rc3
> 
> Vladimir Murzin (6):
>   mm: move memtest under /mm
>   memtest: use phys_addr_t for physical addresses
>   arm64: add support for memtest
>   arm: add support for memtest
>   Kconfig: memtest: update number of test patterns up to 17
>   Documentation: update arch list in the 'memtest' entry
> 
>  Documentation/kernel-parameters.txt |    2 +-
>  arch/arm/mm/init.c                  |    3 +
>  arch/arm64/mm/init.c                |    2 +
>  arch/x86/Kconfig                    |   11 ----
>  arch/x86/include/asm/e820.h         |    8 ---
>  arch/x86/mm/Makefile                |    2 -
>  arch/x86/mm/memtest.c               |  118 -----------------------------------
>  include/linux/memblock.h            |    8 +++
>  lib/Kconfig.debug                   |   11 ++++
>  mm/Makefile                         |    1 +
>  mm/memtest.c                        |  118 +++++++++++++++++++++++++++++++++++
>  11 files changed, 144 insertions(+), 140 deletions(-)
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
