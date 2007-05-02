Date: Wed, 2 May 2007 14:17:45 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: mm-more-rmap-checking
In-Reply-To: <4637EC95.2010501@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705021355390.16517@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011458060.16979@blonde.wat.veritas.com>
 <4637EC95.2010501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Nick Piggin wrote:
> 
> Yes, but IIRC I put that in because there was another check in
> SLES9 that I actually couldn't put in, but used this one instead
> because it also caught the bug we saw.
>... 
> This was actually a rare corruption that is also in 2.6.21, and
> as few rmap callsites as we have, it was never noticed until the
> SLES9 bug check was triggered.

You are being very mysterious.  Please describe this bug (privately
if you think it's exploitable), and let's work on the patch to fix it,
rather than this "debug" patch.

> Hmm, I didn't notice the do_swap_page change, rather just derived
> its safety by looking at the current state of the code (which I
> guess must have been post-do_swap_page change)...

Your addition of page_add_new_anon_rmap clarified the situation too.

> Do you have a pointer to the patch, for my interest?

The patch which changed do_swap_page?

commit c475a8ab625d567eacf5e30ec35d6d8704558062
Author: Hugh Dickins <hugh@veritas.com>
Date:   Tue Jun 21 17:15:12 2005 -0700
[PATCH] can_share_swap_page: use page_mapcount

Or my intended PG_swapcache to PAGE_MAPPING_SWAP patch,
which does assume PageLocked in page_add_anon_rmap?
Yes, I can send you its current unsplit state if you like
(but have higher priorities before splitting and commenting
it for posting).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
