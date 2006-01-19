From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060119192131.11913.27564.sendpatchset@linux.site>
Subject: [patch 0/6] mm: optimisations and page ref simplifications
Date: Thu, 19 Jan 2006 20:22:42 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In the following patchset (against 2.6.16-rc1-git2), patches 1-4 reduce
the number of locks and atomic operations required in some critical page
manipulation paths.

Patches 5 and 6 help simplify some tricky race avoidance code at the
cost of possibly a very minor performance hit in page reclaim on some
architectures. If they need any more justification they will be needed
for lockless pagecache.

Do these look OK?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
