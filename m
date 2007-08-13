Subject: Question:  cpuset_update_task_memory_state() and mmap_sem ???
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Mon, 13 Aug 2007 15:38:22 -0400
Message-Id: <1187033902.5592.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In the comment block for the subject function in cpuset.c, it notes that
"This routine also might acquire callback_mutex and
current->mm->mmap_sem."

Is this is a stale comment?  I can't find any path from this function to
a down_{read|write}() on the caller's mmap_sem [in 23-rc2-mm2].  I
suspect that one would have noticed, as
cpuset_update_task_memory_state() is called from
alloc_page_vma() which, according to its comment block, can only be
called with the mmap_sem held [for read, at least].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
