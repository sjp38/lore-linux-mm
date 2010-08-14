Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 147C16B01F1
	for <linux-mm@kvack.org>; Sat, 14 Aug 2010 16:05:31 -0400 (EDT)
Date: Sat, 14 Aug 2010 13:05:17 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mm/page-writeback: fix non-kernel-doc function comments
Message-Id: <20100814130517.daf2ebf4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: torvalds <torvalds@linux-foundation.org>, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Remove leading /** from non-kernel-doc function comments to prevent
kernel-doc warnings.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.35-git15.orig/mm/page-writeback.c
+++ linux-2.6.35-git15/mm/page-writeback.c
@@ -397,7 +397,7 @@ unsigned long determine_dirtyable_memory
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-/**
+/*
  * global_dirty_limits - background-writeback and dirty-throttling thresholds
  *
  * Calculate the dirty thresholds based on sysctl parameters
@@ -440,7 +440,7 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-/**
+/*
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
  *
  * Allocate high/low dirty limits to fast/slow devices, in order to prevent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
