Date: Sun, 25 Jun 2006 18:39:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] 2.6.17: lockless pagecache
Message-ID: <20060625163930.GB3006@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Updated lockless pagecache patchset available here:

ftp://ftp.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.17/lockless.patch.gz

This should hopefully be my last release using the old (2.6.17)
indirect radix-tree, and I'll switch to the direct radix-tree in
future.

Changes since last release:
- lots of radix-tree cleanups and bugs fixed
- radix-tree tag lookups may be lockless
- added some missing memory barriers
- lockless pagevec_lookup_tag

The last item allowed me to remove the last few read-lockers,
which is nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
