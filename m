Date: Sat, 8 Apr 2006 20:26:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2006, Christoph Lameter wrote:
> 
> Hmmm..,. There are still two other checks for !PageSwapCache after 
> obtaining a page lock in shmem_getpage() and in try_to_unuse(). 
> However, both are getting to the page via the swap maps. So we need to 
> keep those.

Sure, those are long standing checks, necessary long before migration
came on the scene; whereas the check in do_swap_page was recently added
just for a page migration case, and now turns out to be redundant.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
