Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 322586B0055
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:50:53 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 29 Jun 2009 17:52:26 -0400
Message-Id: <20090629215226.20038.42028.sendpatchset@lts-notebook>
Subject: [PATCH 0/3] Balance Freeing of Huge Pages across Nodes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH] 0/3 Balance Freeing of Huge Pages across Nodes

This series contains V3 of the of the "Balance Freeing of Huge
Pages across Nodes" patch--containing a minor cleanup from v2--
and two additional, related patches.  I have added David Rientjes'
ACK from V2, hoping that the change to v3 doesn't invalidate that.

Patch 2/3 reworks the free_pool_huge_page() function so that it
may also be used by return_unused_surplus_page().  This patch
needs careful review [and, testing?].  Perhaps Mel Gorman can 
give it a go with the hugepages regression tests.

Patch 3/3 updates the vm hugetlbpage documentation to clarify 
the usage and to add the description of the balancing of freeing
of huge pages.  Most of the update is from my earlier "huge pages
nodes_allowed" patch series, without mention of the nodes_allowed
mask and associated boot parameter, sysctl and attributes.


Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
