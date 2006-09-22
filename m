From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060922172042.22370.62513.sendpatchset@linux.site>
Subject: [patch 0/4] lockless pagecache for 2.6.18-rc7-mm1
Date: Fri, 22 Sep 2006 21:22:10 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I have rewritten the lockless pagecache patches to a point that they
are much closer to how they looked before my adapting them to radix
tree direct.

Among problems solved since patchset was last posted (thanks Hugh,
Lee, and others) are:

- gang lookups now can no longer skip over indexes if a pages moves
  between being looked up and a reference taken.

- the verification of the "speculative get" now checks the radix tree
  rather than page->mapping and index. So there is no chance a non
  pagecache user might put unlucky values in there and break it.

- no need for a specific find_get_swap_page

There shouldn't be any known problems with it now, I hope.

There is a bit of overlap with the readahead code in -mm, which may
cause (simple) rejects if you drop it... but otherwise it is close
to 2.6.18.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
