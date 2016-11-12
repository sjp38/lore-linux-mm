Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 587A82802A1
	for <linux-mm@kvack.org>; Sat, 12 Nov 2016 00:43:17 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id kr7so39552267pab.5
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 21:43:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j19si13845779pgk.185.2016.11.11.21.43.16
        for <linux-mm@kvack.org>;
        Fri, 11 Nov 2016 21:43:16 -0800 (PST)
Date: Sat, 12 Nov 2016 05:43:19 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC] mm: Add debug_virt_to_phys()
Message-ID: <20161112054318.GB24127@arm.com>
References: <20161112004449.30566-1-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161112004449.30566-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>, Chris Brandt <chris.brandt@renesas.com>, Pratyush Anand <panand@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Neeraj Upadhyay <neeraju@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Nov 11, 2016 at 04:44:43PM -0800, Florian Fainelli wrote:
> When CONFIG_DEBUG_VM is turned on, virt_to_phys() maps to
> debug_virt_to_phys() which helps catch vmalloc space addresses being
> passed. This is helpful in debugging bogus drivers that just assume
> linear mappings all over the place.
> 
> For ARM, ARM64, Unicore32 and Microblaze, the architectures define
> __virt_to_phys() as being the functional implementation of the address
> translation, so we special case the debug stub to call into
> __virt_to_phys directly.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  arch/arm/include/asm/memory.h      |  4 ++++
>  arch/arm64/include/asm/memory.h    |  4 ++++
>  include/asm-generic/memory_model.h |  4 ++++
>  mm/debug.c                         | 15 +++++++++++++++
>  4 files changed, 27 insertions(+)

What's the interaction between this and the DEBUG_VIRTUAL patches from Laura?

http://lkml.kernel.org/r/20161102210054.16621-7-labbott@redhat.com

They seem to be tackling the exact same problem afaict.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
