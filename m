Message-ID: <41C94361.6070909@yahoo.com.au>
Date: Wed, 22 Dec 2004 20:50:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 0/11] alternate 4-level page tables patches (take 2)
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, it turned out that the fallback header I sent out earlier seemed
to do the right thing on both ia64 and x86_64 (3-level) without really
any changes. So combined with i386 !PAE, that covers 2-level and 3-level
implementations... so with any luck it will work on all arches.

So in the following series, there is:

a minor shuffling of hunks between patches
slight improvement to the clear_page_range patch
one off-by-one bug in clear_pud_range
dropped the inlining patch
inclusion of the fallback header.

Theoretically, all architectures should continue to work as before.

Comments? Any consensus as to which way we want to go? I don't want to
inflame tempers by continuing this line of work, just provoke discussion.

Thanks,
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
