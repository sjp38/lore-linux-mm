Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 8C66C6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:33:46 -0400 (EDT)
Date: Wed, 21 Mar 2012 03:33:43 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [git pull] munmap/truncate race fixes
Message-ID: <20120321033343.GN6589@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

	Fixes for racy use of unmap_vmas() on truncate-related codepaths.
Please, pull from
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git vm

Shortlog:
Al Viro (6):
      VM: unmap_page_range() can return void
      VM: can't go through the inner loop in unmap_vmas() more than once...
      VM: make zap_page_range() return void
      VM: don't bother with feeding upper limit to tlb_finish_mmu() in exit_mmap()
      VM: make unmap_vmas() return void
      VM: make zap_page_range() callers that act on a single VMA use separate helper

Diffstat:
 include/linux/mm.h |    4 +-
 mm/memory.c        |  133 +++++++++++++++++++++++++++++++---------------------
 mm/mmap.c          |    5 +-
 3 files changed, 84 insertions(+), 58 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
