Message-ID: <492AB616.8010100@redhat.com>
Date: Mon, 24 Nov 2008 09:11:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 9/8] mm: optimize get_scan_ratio for no swap
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site> <Pine.LNX.4.64.0811232205180.4142@blonde.site> <4929DF54.8050104@redhat.com> <Pine.LNX.4.64.0811241340140.17541@blonde.site> <Pine.LNX.4.64.0811241349570.17541@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811241349570.17541@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Rik suggests a simplified get_scan_ratio() for !CONFIG_SWAP.  Yes,
> the gcc optimizer gives us that, when nr_swap_pages is #defined as 0L.
> Move usual declaration to swapfile.c: it never belonged in page_alloc.c.
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
