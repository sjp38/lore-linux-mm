Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A26566B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 02:42:00 -0500 (EST)
Date: Tue, 25 Jan 2011 08:41:56 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
Message-ID: <20110125074156.GA29709@merkur.ravnborg.org>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org> <4D3DD366.8000704@mvista.com> <20110124124412.69a7c814.akpm@linux-foundation.org> <20110124210752.GA10819@merkur.ravnborg.org> <AANLkTimdgYVpwbCAL96=1F+EtXyNxz5Swv32GN616mqP@mail.gmail.com> <20110124223347.ad6072f1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110124223347.ad6072f1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Sergei Shtylyov <sshtylyov@mvista.com>, Yoichi Yuasa <yuasa@linux-mips.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> mips:
> 
> In file included from arch/mips/include/asm/tlb.h:21,
>                  from mm/pgtable-generic.c:9:
> include/asm-generic/tlb.h: In function `tlb_flush_mmu':
> include/asm-generic/tlb.h:76: error: implicit declaration of function `release_pages'
> include/asm-generic/tlb.h: In function `tlb_remove_page':
> include/asm-generic/tlb.h:105: error: implicit declaration of function `page_cache_release'
> 
> free_pages_and_swap_cache() and free_page_and_swap_cache() are macros
> which call release_pages() and page_cache_release().  The obvious fix is
> to include pagemap.h in swap.h, where those macros are defined.  But that
> breaks sparc for weird reasons.
> 
> So fix it within mm/pgtable-generic.c instead.
> 
> Reported-by: Yoichi Yuasa <yuasa@linux-mips.org>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: Sergei Shtylyov <sshtylyov@mvista.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I have succesfully build sparc32 allnoconfig + defconfig with this patch.
Can you expand the changelog to specify that this fixes sparc32 allnoconfig
as well?

Consider it:
Acked-by: Sam Ravnborg <sam@ravnborg.org>

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
