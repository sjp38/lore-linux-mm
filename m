Message-ID: <4924C6A7.6060506@redhat.com>
Date: Wed, 19 Nov 2008 21:08:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: add_active_or_unevictable into rmap
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site> <Pine.LNX.4.64.0811200120160.19216@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811200120160.19216@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> lru_cache_add_active_or_unevictable() and page_add_new_anon_rmap()
> always appear together.  Save some symbol table space and some jumping
> around by removing lru_cache_add_active_or_unevictable(), folding its
> code into page_add_new_anon_rmap(): like how we add file pages to lru
> just after adding them to page cache.
> 
> Remove the nearby "TODO: is this safe?" comments (yes, it is safe),
> and change page_add_new_anon_rmap()'s address BUG_ON to VM_BUG_ON
> as originally intended.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
