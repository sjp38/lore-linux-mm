Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 207886B004F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:00:20 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 28 Aug 2009 12:03:14 -0400
Message-Id: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/6] hugetlb: V5 constrain allocation/free based on task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/6 hugetlb: numa control of persistent huge pages alloc/free

Against:  2.6.31-rc7-mmotm-090827-0057

This is V5 of a series of patches to provide control over the location
of the allocation and freeing of persistent huge pages on a NUMA
platform.

This series uses the task NUMA mempolicy of the task modifying
"nr_hugepages" to constrain the affected nodes.  This method is
based on Mel Gorman's suggestion to use task mempolicy.  One of
the benefits of this method is that it does not *require*
modification to hugeadm(8) to use this feature.  One of the possible
downsides is that task mempolicy is limited by cpuset constraints.

V4 added a subset of the hugepages sysfs attributes to each per
node system device directory under:

	/sys/devices/node/node[0-9]*/hugepages.

The per node attibutes allow direct assignment of a huge page
count on a specific node, regardless of the task's mempolicy or
cpuset constraints.

V5 addresses review comments -- changes described in patch
descriptions.  Should be almost ready for -mm?

Note, I haven't implemented a boot time parameter to constrain the
boot time allocation of huge pages.  This can be added if anyone feels
strongly that it is required.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
