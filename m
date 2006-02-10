From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
Date: Fri, 10 Feb 2006 16:37:57 +1100
References: <200602101355.41421.kernel@kolivas.org> <200602101626.12824.kernel@kolivas.org> <43EC2572.7010100@yahoo.com.au>
In-Reply-To: <43EC2572.7010100@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602101637.57821.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 10 February 2006 16:32, Nick Piggin wrote:
> Con Kolivas wrote:
> > Just so it's clear I understand, is this what you (both) had in mind?
> > Inline so it's not built for !CONFIG_SWAP_PREFETCH
>
> Close...

> > +inline void lru_cache_add_tail(struct page *page)
>
> Is this inline going to do what you intend?

I don't care if it's actually inlined, but the subtleties of compilers is way 
beyond me. All it positively achieves is silencing the unused function 
warning so I had hoped it meant that function was not built. I tend to be 
wrong though...

>      spin_lock_irq(&zone->lru_lock);
>
> > +	add_page_to_inactive_list_tail(zone, page);
>
>      spin_unlock_irq(&zone->lru_lock);

Thanks!

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
