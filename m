From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [ck] Re: [PATCH] mm: Implement Swap Prefetching v24
Date: Sat, 11 Feb 2006 22:16:37 +1100
References: <200602110347.43121.kernel@kolivas.org> <200602111248.16067.kernel@kolivas.org>
In-Reply-To: <200602111248.16067.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602112216.37792.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ck@vds.kolivas.org
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, pj@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 11 February 2006 12:48, Con Kolivas wrote:
> On Saturday 11 February 2006 03:47, Con Kolivas wrote:
> > Try again. Tackled everything I could think of mentioned and more.
>
> Hrm BUG..
>
> This version appears to work fine with the pages being added to the tail of
> the LRU, however there's a problem with the custom lru_cache_add_tail
> function. I end up hitting a bug at:
> 	if (!TestClearPageLRU(page))
> 		BUG();
>
> in isolate_lru_pages called from shrink_zone, find_busiest_group,
> shrink_slab... ultimately from kswapd.

I've been unable to get this one working without reliably BUGging there. As 
soon as anything is prefetched, the next time ram is full it will BUG. So 
I've hacked a lru_cache_add_tail using a variation of the current 
lru_cache_add that uses pagevecs and it has been working flawlessly. I'll 
thrash this implementation around a bit more to see if it breaks and unless 
someone can suggest what I've done wrong with v24 I'll be posting v25 with 
the pagevecs version.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
