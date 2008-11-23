Message-ID: <4929D175.2000200@redhat.com>
Date: Sun, 23 Nov 2008 16:56:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/7] mm: further cleanup page_add_new_anon_rmap
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site> <Pine.LNX.4.64.0811200120160.19216@blonde.site> <Pine.LNX.4.64.0811232148430.3617@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811232148430.3617@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Moving lru_cache_add_active_or_unevictable() into page_add_new_anon_rmap()
> was good but done stupidly: we should SetPageSwapBacked() there too; and
> we know for sure that this anonymous, swap-backed page is not file cache.

True, but ...

>  	if (page_evictable(page, vma))
> -		lru_cache_add_lru(page, LRU_ACTIVE + page_is_file_cache(page));
> +		lru_cache_add_lru(page, LRU_ACTIVE);

Then you will want to s/LRU_ACTIVE/LRU_ACTIVE_ANON/ here.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
