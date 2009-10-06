Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD8186B0062
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 23:14:08 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 05 Oct 2009 23:18:08 -0400
Message-Id: <20091006031808.22576.91721.sendpatchset@localhost.localdomain>
In-Reply-To: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/11] hugetlb:  accomodate reworked NODEMASK_ALLOC
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 5/11] hugetlb:  accomodate reworked NODEMASK_ALLOC
From:	David Rientjes <rientjes@google.com>

Against:  2.6.31-mmotm-090925-1435

Depends on:  David Rientjes' "nodemask: make NODEMASK_ALLOC more general"
patch.

Fix hugetlb usage of NODEMASK_ALLOC after aforementioned patch is merged.

Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-10-05 10:45:12.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-05 10:49:42.000000000 -0400
@@ -1347,7 +1347,7 @@ static ssize_t nr_hugepages_store_common
 	int err;
 	unsigned long count;
 	struct hstate *h = kobj_to_hstate(kobj);
-	NODEMASK_ALLOC(nodemask, nodes_allowed);
+	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
 
 	err = strict_strtoul(buf, 10, &count);
 	if (err)
@@ -1638,7 +1638,7 @@ static int hugetlb_sysctl_handler_common
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write) {
-		NODEMASK_ALLOC(nodemask, nodes_allowed);
+		NODEMASK_ALLOC(nodemask_t, nodes_allowed);
 		if (!(obey_mempolicy &&
 			       init_nodemask_of_mempolicy(nodes_allowed))) {
 			NODEMASK_FREE(nodes_allowed);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
