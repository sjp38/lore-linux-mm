Date: Wed, 25 Apr 2007 09:27:11 +0100
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 3/12] get_unmapped_area handles MAP_FIXED on arm
Message-ID: <20070425082711.GA26988@flint.arm.linux.org.uk>
References: <1177392813.924664.32930750763.qpush@grosgo> <20070424053337.C5FEBDDF09@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070424053337.C5FEBDDF09@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 24, 2007 at 03:33:35PM +1000, Benjamin Herrenschmidt wrote:
> ARM already had a case for MAP_FIXED in arch_get_unmapped_area() though
> it was not called before. Fix the comment to reflect that it will now
> be called.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

> 
>  arch/arm/mm/mmap.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: linux-cell/arch/arm/mm/mmap.c
> ===================================================================
> --- linux-cell.orig/arch/arm/mm/mmap.c	2007-03-22 14:59:51.000000000 +1100
> +++ linux-cell/arch/arm/mm/mmap.c	2007-03-22 15:00:01.000000000 +1100
> @@ -49,8 +49,7 @@ arch_get_unmapped_area(struct file *filp
>  #endif
>  
>  	/*
> -	 * We should enforce the MAP_FIXED case.  However, currently
> -	 * the generic kernel code doesn't allow us to handle this.
> +	 * We enforce the MAP_FIXED case.
>  	 */
>  	if (flags & MAP_FIXED) {
>  		if (aliasing && flags & MAP_SHARED && addr & (SHMLBA - 1))
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
