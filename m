Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id QAA25581
	for <linux-mm@kvack.org>; Wed, 22 Sep 1999 16:59:23 -0400
Date: Wed, 22 Sep 1999 17:02:07 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: mm->mmap_sem
Message-ID: <Pine.LNX.4.10.9909221454320.26444-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I noticed that mm_struct has a semaphore in it. How go is it protecting
the memory region? Say we have teh following case. I have a process
that mmaps a chunk of memory and this memory can be sharded with other 
processes. What if the process does a mlock which does a
down(mm->mmap_sem). Now the process goes to sleep and another process
tries to modify the memory region. Will this semaphore protect this
region? In a SMP machine same thing. What kind of protect does this
semaphore provide? Does it prevent other process from doing anything to
the memory. I meant even writing or read it. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
