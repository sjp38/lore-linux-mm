Date: Sat, 22 Mar 2008 21:10:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [04/14] vcompound: Core piece
In-Reply-To: <20080321061724.956843984@sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061724.956843984@sgi.com>
Message-Id: <20080322205729.B317.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

in general, I like this patch and I found no bug :)

> Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-20 23:03:14.600588151 -0700
> +++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-20 23:03:14.612588010 -0700
> @@ -86,6 +86,20 @@ extern struct vm_struct *alloc_vm_area(s
>  extern void free_vm_area(struct vm_struct *area);
>  
>  /*
> + * Support for virtual compound pages.
> + *
> + * Calls to vcompound alloc will result in the allocation of normal compound
> + * pages unless memory is fragmented.  If insufficient physical linear memory
> + * is available then a virtually contiguous area of memory will be created
> + * using the vmalloc functionality.
> + */
> +struct page *alloc_vcompound_alloc(gfp_t flags, int order);

where exist alloc_vcompound_alloc?


> +/*
> + * Virtual Compound Page support.
> + *
> + * Virtual Compound Pages are used to fall back to order 0 allocations if large
> + * linear mappings are not available. They are formatted according to compound
> + * page conventions. I.e. following page->first_page if PageTail(page) is set
> + * can be used to determine the head page.
> + */
> +

Hmm,
IMHO we need vcompound documentation more for the beginner in the Documentation/ directory.
if not, nobody understand mean of vcompound flag at /proc/vmallocinfo.


> +void __free_vcompound(void *addr)
> +void free_vcompound(struct page *page)
> +struct page *alloc_vcompound(gfp_t flags, int order)
> +void *__alloc_vcompound(gfp_t flags, int order)

may be, we need DocBook style comment at the head of these 4 functions.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
