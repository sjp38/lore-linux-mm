Message-Id: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:37 -0700
From: clameter@sgi.com
Subject: [patch 0/8] SLUB patches vs. 2.6.21-rc7-mm2 + yesterdays accepted patches
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This fixes up the sysfs unique id generation issue and some issues in
kmem_cache_shrink. Also improves the statistics available through slabinfo.

I have split up the printk cleanup patch and put it at the end. If any patch
after the object_err patch does not apply then just toss it.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
