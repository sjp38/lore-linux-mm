Date: Fri, 17 Dec 2004 18:17:55 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] kill off ARCH_HAS_ATOMIC_UNSIGNED (take 2)
In-Reply-To: <E1CfLrg-0007VC-00@kernel.beaverton.ibm.com>
Message-ID: <Pine.LNX.4.44.0412171814050.10470-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2004, Dave Hansen wrote:
> --- apw2/mm/page_alloc.c~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-17 09:19:30.000000000 -0800
> +++ apw2-dave/mm/page_alloc.c	2004-12-17 09:19:48.000000000 -0800
> @@ -85,7 +85,7 @@ static void bad_page(const char *functio
>  	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
>  		function, current->comm, page);
>  	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
> -		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
> +		(int)(2*sizeof(unsigned long)), (unsigned long)page->flags,
   		                                ^^^^^^^^^^^^^^^
>  		page->mapping, page_mapcount(page), page_count(page));
>  	printk(KERN_EMERG "Backtrace:\n");
>  	dump_stack();

Teensy nit: better not to cast to unsigned long when it's unsigned long.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
