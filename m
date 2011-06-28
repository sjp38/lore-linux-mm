Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8A0F36B00E8
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 12:53:05 -0400 (EDT)
Message-Id: <20110628164750.281686775@goodmis.org>
Date: Tue, 28 Jun 2011 12:47:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 0/2] mm: Clean up and document fault and RETRY mmap_sem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On IRC, Russell King noticed that the code in arch/x86/mm/fault.c
looked buggy with the retry loop and retaking the mmap_sem. But
with further investigation it seems to be correct, but now
handle_mm_fault() has subtle locking with the mmap_sem depending
on what flags are set.

Unfortunately, there's no good comments about what is going on in the
code. Doing various git blame, git show, I dug up the history
and cleaned up the RETRY_NOWAIT and added documentation to the
handle_mm_fault().


Steven Rostedt (2):
      mm: Remove use of ALLOW_RETRY when RETRY_NOWAIT is set
      mm: Document handle_mm_fault()

----
 include/linux/mm.h |    4 ++--
 mm/filemap.c       |   14 +++++++-------
 mm/memory.c        |   24 +++++++++++++++++++++---
 3 files changed, 30 insertions(+), 12 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
