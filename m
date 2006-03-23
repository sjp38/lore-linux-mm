Date: Thu, 23 Mar 2006 09:11:00 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Lockless pagecache perhaps for 2.6.18?
Message-ID: <20060323081100.GE26146@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi,

Would there be any objection to having my lockless pagecache patches
merged into -mm, for a possible mainline merge after 2.6.17 (ie. if/
when the mm hackers feel comfortable with it).

There are now just 3 patches: 15 files, 312 insertions, 81 deletions
for the core changes, including RCU radix-tree. (not counting those
last two I just sent you Andrew (VM_BUG_ON, find_trylock_page))

It is fairly well commented, and not overly complex (IMO) compared
with other lockless stuff in the tree now.

My main motivation is to get more testing and more serious reviews,
rather than trying to clear a fast path into mainline.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
