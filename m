Message-Id: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:39 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 00/20] VM pageout scalability improvements
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On large memory systems, the VM can spend way too much time scanning
through pages that it cannot (or should not) evict from memory. Not
only does it use up CPU time, but it also provokes lock contention
and can leave large systems under memory presure in a catatonic state.

This patch series improves VM scalability by:

1) making the locking a little more scalable

2) putting filesystem backed, swap backed and non-reclaimable pages
   onto their own LRUs, so the system only scans the pages that it
   can/should evict from memory

3) switching to SEQ replacement for the anonymous LRUs, so the
   number of pages that need to be scanned when the system
   starts swapping is bound to a reasonable number

The noreclaim patches come verbatim from Lee Schermerhorn and
Nick Piggin.  I have not taken a detailed look at them yet and
all I have done is fix the rejects against the latest -mm kernel.

I am posting this series now because I would like to get more
feedback, while I am studying and improving the noreclaim patches
myself.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
