Message-ID: <4929DEEC.4080700@redhat.com>
Date: Sun, 23 Nov 2008 17:53:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] mm: remove try_to_munlock from vmscan
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site> <Pine.LNX.4.64.0811232202040.4142@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811232202040.4142@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> Now try_to_free_swap() has replaced remove_exclusive_swap_page(), that's
> not an issue any more: remove try_to_munlock() call from shrink_page_list(),
> leaving it to try_to_munmap() to discover if the page is one to be culled
> to the unevictable list - in which case then try_to_free_swap().

Nice simplification.

> Update unevictable-lru.txt to remove comments on the try_to_munlock()
> in shrink_page_list(), and shorten some lines over 80 columns.
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
