From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:35 -0500
Message-Id: <20071206212135.6279.84607.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 8/8] Mem Policy: Fix up MPOL_BIND documentation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, clameter@sgi.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH/RFC 08/08 - Mem Policy: Fix up MPOL_BIND documentation

Against:  2.6.24-rc4-mm1

With Mel Gorman's "twozonelist" patch series, the MPOL_BIND mode will
search the bind nodemask in order of distance from the node on which
the allocation is performed.  Update the mempolicy document to reflect
this [desirable] change.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:39.000000000 -0500
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:27:07.000000000 -0500
@@ -162,11 +162,10 @@ Components of Memory Policies
 	set of nodes specified by the policy.
 
 	    The memory policy APIs do not specify an order in which the nodes
-	    will be searched.  However, unlike "local allocation" discussed
-	    below, the Bind policy does not consider the distance between the
-	    nodes.  Rather, allocations will fallback to the nodes specified
-	    by the policy in order of numeric node id.  Like everything in
-	    Linux, this is subject to change.
+	    will be searched.  However, the Bind policy will allocate a page
+	    from the node in the specified set of nodes that is closest to the
+	    node on which the task performing the allocation is executing and
+	    that contains a free page that satisfies the request.
 
 	MPOL_PREFERRED:  This mode specifies that the allocation should be
 	attempted from the single node specified in the policy.  If that

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
