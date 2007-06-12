Message-Id: <20070612204843.491072749@sgi.com>
Date: Tue, 12 Jun 2007 13:48:43 -0700
From: clameter@sgi.com
Subject: [patch 0/3] Fixes for NUMA allocations on memoryless nodes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

This patchset fixes the dysfunctional behavior of for GFP_THISNODE and MPOL_INTERLEAVE
on systems with memoryless nodes. We introduce a new "node_memory_map" to be able to
determine efficiently if a node has memory.

Tested on IA64 NUMA and compile tested on i386 SMP (to verify that the new fallbacks work right)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
