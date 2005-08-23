Message-ID: <430A6EB5.2000408@yahoo.com.au>
Date: Tue, 23 Aug 2005 10:32:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

> The patch generally drops the first acquisition of the page 
> table lock from handle_mm_fault that is used to protect the read 
> operations on the page table. I doubt that this works with i386 PAE since 
> the page table read operations are not protected by the ptl. These are 64 
> bit which cannot be reliably retrieved in an 32 bit operation on i386 as 
> you pointed out last fall. There may be concurrent writes so that one 
> gets two pieces that do not fit. PAE mode either needs to fall back to 
> take the page_table_lock for reads or use some tricks to guarantee 64bit 
> atomicity.
> 

Oh yes, you need 64-bit atomic reads and writes for that.

We actually did see that load in handle_pte_fault being cut
in half by a store.

I wouldn't be too worried about that though, as it's only
for PAE.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
