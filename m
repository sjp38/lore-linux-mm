Received: from localhost (localhost [127.0.0.1])
	by baldur.austin.ibm.com (8.12.9/8.12.9/Debian-3) with ESMTP id h4SFRqFA012371
	for <linux-mm@kvack.org>; Wed, 28 May 2003 10:27:53 -0500
Date: Wed, 28 May 2003 10:27:52 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Question about locking in mmap.c
Message-ID: <33460000.1054135672@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

It's been my understanding that most vma manipulation is protected by
mm->mmap_sem, and the page table is protected by mm->page_table_lock.  I've
been rummaging through mmap.c and see a number of places that take
page_table_lock when the code is about to make changes to the vma chains.
These places are already holding mmap_sem for write.

My question is what is page_table_lock supposed to be protecting against?
Am I wrong that mmap_sem is sufficient to protect against concurrent
changes to the vmas?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
