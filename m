From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SL*B: drop kmem cache argument from constructor
Date: Mon, 14 Jul 2008 14:48:21 +1000
References: <20080710011132.GA8327@martell.zuzino.mipt.ru> <20080711122228.eb40247f.akpm@linux-foundation.org> <4877D35E.8080209@linux.vnet.ibm.com>
In-Reply-To: <4877D35E.8080209@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807141448.22233.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Saturday 12 July 2008 07:40, Jon Tollefson wrote:
> Andrew Morton wrote:

> > btw, Nick, what's with that dopey
> >
> > 	huge_pgtable_cache(psize) = kmem_cache_create(...
> >
> > trick?  The result of a function call is not an lvalue, and writing a
> > macro which pretends to be a function and then using it in some manner
> > in which a function cannot be used is seven ways silly :(

I agree it isn't nice.


> That silliness came from me.
> It came from my simplistic translation of the existing code to handle
> multiple huge page sizes.  I would agree it would be easier to read and
> more straight forward to just have the indexed array directly on the
> left side instead of a macro.  I can send out a patch that makes that
> change if desired.
> Something such as
>
> +#define HUGE_PGTABLE_INDEX(psize) (HUGEPTE_CACHE_NUM + psize - 1)
>
> -huge_pgtable_cache(psize) = kmem_cache_create(...
> +pgtable_cache[HUGE_PGTABLE_INDEX(psize)] = kmem_cache_create(...
>
>
> or if there is a more accepted way of handling this situation I can
> amend it differently.

If it is a once off initialization (which it is), that's probably fine
like that. Otherwise, the convention is to have a set_huge_pgtable_cache
function as well. But whatever you prefer. Yes if you can send a patch,
that would be good, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
