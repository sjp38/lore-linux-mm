Date: Wed, 30 Aug 2006 05:05:18 -0500
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC][PATCH 10/10] convert the "easy" architectures to generic PAGE_SIZE
Message-ID: <20060830100518.GA10629@localhost.internal.ocgnet.org>
References: <20060829201934.47E63D1F@localhost.localdomain> <20060829201941.38D6254C@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060829201941.38D6254C@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net
List-ID: <linux-mm.kvack.org>

On Tue, Aug 29, 2006 at 01:19:41PM -0700, Dave Hansen wrote:
> diff -puN include/asm-sh/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT include/asm-sh/page.h
> --- threadalloc/include/asm-sh/page.h~arch-generic-PAGE_SIZE-give-every-arch-PAGE_SHIFT	2006-08-29 13:14:48.000000000 -0700
> +++ threadalloc-dave/include/asm-sh/page.h	2006-08-29 13:14:58.000000000 -0700
> @@ -13,12 +13,7 @@
>     [ P4 control   ]		0xE0000000
>   */
>  
> -
> -/* PAGE_SHIFT determines the page size */
> -#define PAGE_SHIFT	12
> -#define PAGE_SIZE	(1UL << PAGE_SHIFT)
> -#define PAGE_MASK	(~(PAGE_SIZE-1))
> -#define PTE_MASK	PAGE_MASK
> +#include <asm-generic/page.h>
>  
Overzealous deletion? Please leave PTE_MASK there, we use it for
_PAGE_CHG_MASK in pgtable.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
