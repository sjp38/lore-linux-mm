Received: from ickis.cs.wm.edu (ickis [128.239.26.50])
	by zimbo.cs.wm.edu (8.12.8/8.12.8) with ESMTP id h5BGDY16011711
	for <linux-mm@kvack.org>; Wed, 11 Jun 2003 12:13:34 -0400
Received: from localhost (sren@localhost)
	by ickis.cs.wm.edu (8.12.8/8.12.8/Submit) with ESMTP id h5BGDYVA001652
	for <linux-mm@kvack.org>; Wed, 11 Jun 2003 12:13:34 -0400
Date: Wed, 11 Jun 2003 12:13:34 -0400 (EDT)
From: Shansi Ren <sren@CS.WM.EDU>
Subject: How to fix the total size of buffer caches in 2.4.5? 
Message-ID: <Pine.LNX.4.44.0306111208200.1570-100000@ickis.cs.wm.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

   I'm trying to implement the pure LRU algorithm and a new page 
replacement algorithm on top of 2.4.5 kernel, and compare their 
performance. Can anybody tell me if there is an easy way to seperate the 
buffer cache management from the virtual memory management? And how to 
preallocate a chunk of memory for buffer cache usage exclusively, say, 
32M exclusively for buffer cache?  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
