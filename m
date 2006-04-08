Date: Sat, 8 Apr 2006 13:16:19 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Apr 2006, Christoph Lameter wrote:

> It is better to redo the complete fault if do_swap_page() finds
> that the page is not in PageSwapCache() because the page migration
> code may have replaced the swap pte already with a pte pointing
> to valid memory.
> 
> do_swap_page may interpret an invalid swap entry without this patch 
> because we do not reload the pte if we are looping back. The page 
> migration code may already have reused the swap entry referenced by our
> local swp_entry.

Wouldn't you better just remove that !PageSwapCache "Page migration has
occured" block?  Isn't that case already dealt with by the old !pte_same
check below it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
