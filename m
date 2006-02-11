From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v24
Date: Sat, 11 Feb 2006 12:48:15 +1100
References: <200602110347.43121.kernel@kolivas.org>
In-Reply-To: <200602110347.43121.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602111248.16067.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 11 February 2006 03:47, Con Kolivas wrote:
> Try again. Tackled everything I could think of mentioned and more.

Hrm BUG..

This version appears to work fine with the pages being added to the tail of 
the LRU, however there's a problem with the custom lru_cache_add_tail 
function. I end up hitting a bug at:
	if (!TestClearPageLRU(page))
		BUG();

in isolate_lru_pages called from shrink_zone, find_busiest_group, 
shrink_slab... ultimately from kswapd.

Just looking at the lru_cache_add function I note that my lru_cache_add_tail 
function is missing a page_cache_get on the page before adding it to the LRU. 
I'm guessing this is wrong.

Cheers,
Con

P.S. Sorry if this thread is getting long winded; there's a record amount of 
noise on lkml already :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
