Date: Sun, 18 Apr 2004 21:01:10 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418210110.A29171@flint.arm.linux.org.uk>
References: <20040418122344.A11293@flint.arm.linux.org.uk> <Pine.LNX.4.44.0404181331240.20000-100000@localhost.localdomain> <20040418134228.B12222@flint.arm.linux.org.uk> <20040418205513.A27725@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418205513.A27725@flint.arm.linux.org.uk>; from rmk@arm.linux.org.uk on Sun, Apr 18, 2004 at 08:55:13PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 08:55:13PM +0100, Russell King wrote:
> 2. Eliminate asm/pgalloc.h from most files.
> 
>    Many files appear not to use anything from this header file, but
>    include it anyway.  Grepping around for uses of the definitions
>    in asm/pgalloc.h reveals 52 files using or providing pgalloc.h
>    definitions (including pgalloc.h files).  However, a wapping
>    557 files include pgalloc.h.

B*****.  grepped for the wrong include file.  203 files not 557.

>    The only files which need pgalloc.h include are:

The correct list is:

	 ./arch/alpha/mm/init.c
	 ./arch/arm/mm/mm-armv.c
	 ./arch/arm26/mm/mm-memc.c
	 ./arch/i386/mm/pgtable.c
	 ./arch/ia64/kernel/process.c
	 ./arch/ia64/mm/init.c
	 ./arch/parisc/kernel/process.c
	 ./arch/parisc/mm/init.c
	 ./arch/ppc/mm/pgtable.c
	 ./arch/ppc64/mm/tlb.c
	 ./arch/s390/mm/init.c
	 ./arch/sparc/kernel/process.c
	 ./arch/sparc/mm/init.c
	 ./arch/sparc/mm/srmmu.c
	 ./arch/sparc/mm/sun4c.c
	 ./arch/sparc64/kernel/process.c
	 ./arch/sparc64/mm/init.c
	 ./arch/um/kernel/mem.c
	+./include/asm-alpha/tlb.h
	+./include/asm-arm/tlb.h
	+./include/asm-arm26/tlb.h
	+./include/asm-generic/tlb.h
	 ./include/asm-ia64/tlb.h
	+./include/asm-m68k/pgtable.h
	+./include/asm-parisc/tlb.h
	+./include/asm-ppc64/tlb.h
	+./include/asm-sparc64/pgtable.h
	+./include/asm-sparc64/tlb.h
	+./include/asm-x86_64/pgtable.h
	 ./kernel/fork.c
	 ./mm/memory.c


-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
