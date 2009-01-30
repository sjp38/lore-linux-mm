Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86FDD6B005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 13:03:00 -0500 (EST)
Date: Fri, 30 Jan 2009 19:02:48 +0100 (CET)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions fix for m68k
 sun3
In-Reply-To: <1233266297-12995-1-git-send-email-righi.andrea@gmail.com>
Message-ID: <Pine.LNX.4.64.0901301902140.23582@anakin>
References: <1233266297-12995-1-git-send-email-righi.andrea@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jan 2009, Andrea Righi wrote:
> sun3_defconfig fails with:
> 
>     CC      mm/memory.o
>   mm/memory.c: In function 'free_pmd_range':
>   mm/memory.c:176: error: implicit declaration of function '__pmd_free_tlb'
>   mm/memory.c: In function '__pmd_alloc':
>   mm/memory.c:2903: error: implicit declaration of function 'pmd_alloc_one_bug'
>   mm/memory.c:2903: warning: initialization makes pointer from integer without a cast
>   mm/memory.c:2917: error: implicit declaration of function 'pmd_free'
>   make[3]: *** [mm/memory.o] Error 1
> 
> Add the missing include.
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> ---
>  include/asm-m68k/sun3_pgalloc.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/asm-m68k/sun3_pgalloc.h b/include/asm-m68k/sun3_pgalloc.h
> index 0fe28fc..399d280 100644
> --- a/include/asm-m68k/sun3_pgalloc.h
> +++ b/include/asm-m68k/sun3_pgalloc.h
> @@ -11,6 +11,7 @@
>  #define _SUN3_PGALLOC_H
>  
>  #include <asm/tlb.h>
> +#include <asm-generic/pgtable-nopmd.h>

Which makes it worse:

  CC      arch/m68k/kernel/traps.o
In file included from include/asm-generic/pgtable-nopmd.h:6,
                 from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopud.h:17:1: warning: "PUD_SIZE" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:7:1: warning: this is the location of the previous definition
In file included from include/asm-generic/pgtable-nopmd.h:6,
                 from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopud.h:18:1: warning: "PUD_MASK" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:8:1: warning: this is the location of the previous definition
In file included from include/asm-generic/pgtable-nopmd.h:6,
                 from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopud.h:29:1: warning: "pud_ERROR" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:22:1: warning: this is the location of the previous definition
In file included from include/asm-generic/pgtable-nopmd.h:6,
                 from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopud.h:43:1: warning: "pud_val" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:24:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:20:1: warning: "PMD_SHIFT" redefined
In file included from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
arch/m68k/include/asm/pgtable_mm.h:33:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:34:1: warning: "pmd_ERROR" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:132,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
arch/m68k/include/asm/sun3_pgtable.h:157:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:36:1: warning: "pud_populate" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:25:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:49:1: warning: "pmd_val" redefined
In file included from arch/m68k/include/asm/page.h:4,
                 from arch/m68k/include/asm/thread_info_mm.h:5,
                 from arch/m68k/include/asm/thread_info.h:4,
                 from include/linux/thread_info.h:55,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/seqlock.h:29,
                 from include/linux/time.h:8,
                 from include/linux/timex.h:56,
                 from include/linux/sched.h:54,
                 from arch/m68k/kernel/traps.c:21:
arch/m68k/include/asm/page_mm.h:97:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:50:1: warning: "__pmd" redefined
In file included from arch/m68k/include/asm/page.h:4,
                 from arch/m68k/include/asm/thread_info_mm.h:5,
                 from arch/m68k/include/asm/thread_info.h:4,
                 from include/linux/thread_info.h:55,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/seqlock.h:29,
                 from include/linux/time.h:8,
                 from include/linux/timex.h:56,
                 from include/linux/sched.h:54,
                 from arch/m68k/kernel/traps.c:21:
arch/m68k/include/asm/page_mm.h:102:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:52:1: warning: "pud_page" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:26:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:53:1: warning: "pud_page_vaddr" redefined
In file included from arch/m68k/include/asm/pgtable_mm.h:4,
                 from arch/m68k/include/asm/pgtable.h:4,
                 from include/linux/mm.h:40,
                 from arch/m68k/kernel/traps.c:24:
include/asm-generic/4level-fixup.h:27:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
arch/m68k/include/asm/sun3_pgalloc.h:22:1: warning: "pmd_alloc_one" redefined
In file included from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopmd.h:65:1: warning: this is the location of the previous definition
In file included from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
arch/m68k/include/asm/sun3_pgalloc.h:93:1: warning: "pgd_populate" redefined
In file included from include/asm-generic/pgtable-nopmd.h:6,
                 from arch/m68k/include/asm/sun3_pgalloc.h:14,
                 from arch/m68k/include/asm/pgalloc_mm.h:12,
                 from arch/m68k/include/asm/pgalloc.h:4,
                 from arch/m68k/kernel/traps.c:38:
include/asm-generic/pgtable-nopud.h:31:1: warning: this is the location of the previous definition
In file included from include/asm-generic/pgtable-nopmd.h:7,
                 from arch/m68k/include/asm/sun3_pgalloc.h:15,
                 from arch/m68k/include/asm/pgalloc_mm.h:13,
                 from arch/m68k/include/asm/pgalloc.h:5,
                 from arch/m68k/kernel/traps.c:39:
include/asm-generic/pgtable-nopud.h:13: error: conflicting types for 'pgd_t'
arch/m68k/include/asm/page_mm.h:92: error: previous declaration of 'pgd_t' was here
include/asm-generic/pgtable-nopud.h:25: error: conflicting types for 'pgd_none'
arch/m68k/include/asm/sun3_pgtable.h:149: error: previous definition of 'pgd_none' was here
include/asm-generic/pgtable-nopud.h:26: error: conflicting types for 'pgd_bad'
arch/m68k/include/asm/sun3_pgtable.h:150: error: previous definition of 'pgd_bad' was here
include/asm-generic/pgtable-nopud.h:27: error: conflicting types for 'pgd_present'
arch/m68k/include/asm/sun3_pgtable.h:151: error: previous definition of 'pgd_present' was here
include/asm-generic/pgtable-nopud.h:28: error: conflicting types for 'pgd_clear'
arch/m68k/include/asm/sun3_pgtable.h:152: error: previous definition of 'pgd_clear' was here
include/asm-generic/pgtable-nopud.h:38: error: expected ')' before '*' token
In file included from arch/m68k/include/asm/sun3_pgalloc.h:15,
                 from arch/m68k/include/asm/pgalloc_mm.h:13,
                 from arch/m68k/include/asm/pgalloc.h:5,
                 from arch/m68k/kernel/traps.c:39:
include/asm-generic/pgtable-nopmd.h:18: error: conflicting types for 'pmd_t'
arch/m68k/include/asm/page_mm.h:91: error: previous declaration of 'pmd_t' was here
include/asm-generic/pgtable-nopmd.h:30: error: expected identifier or '(' before numeric constant
include/asm-generic/pgtable-nopmd.h:31: error: expected identifier or '(' before numeric constant
include/asm-generic/pgtable-nopmd.h:32: error: expected identifier or '(' before numeric constant
include/asm-generic/pgtable-nopmd.h:33: error: redefinition of 'pgd_clear'
include/asm-generic/pgtable-nopud.h:28: error: previous definition of 'pgd_clear' was here
include/asm-generic/pgtable-nopmd.h:45: error: conflicting types for 'pmd_offset'
arch/m68k/include/asm/sun3_pgtable.h:201: error: previous definition of 'pmd_offset' was here
make[3]: *** [arch/m68k/kernel/traps.o] Error 1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
