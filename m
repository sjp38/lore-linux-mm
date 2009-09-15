Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3797B6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:39:59 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Sep 2009 16:43:27 -0400
Message-Id: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/11] hugetlb: V7 constrain allocation/free based on task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/11 hugetlb: numa control of persistent huge pages alloc/free

Against:  2.6.31-mmotm-090914-0157

This is V7 of a series of patches to provide control over the location
of the allocation and freeing of persistent huge pages on a NUMA
platform.   Please consider [at least patches 1-8] for merging into mmotm.

This series uses two mechanisms to constrain the nodes from which
persistent huge pages are allocated:  1) the task NUMA mempolicy of
the task modifying  a new sysctl "nr_hugepages_mempolicy" [patch 8],
based on a suggestion by Mel Gorman; and 2) a subset of the hugepages
hstate sysfs attributes have been added [in V4] to each node system
device under:

	/sys/devices/node/node[0-9]*/hugepages.

The per node attibutes allow direct assignment of a huge page
count on a specific node, regardless of the task's mempolicy or
cpuset constraints.

V5 addressed review comments -- changes described in patch descriptions.

V6 addressed more review comments, described in the patches.

V6 also included a 3 patch series that implements an enhancement suggested
by David Rientjes:   the default huge page nodes allowed mask will be the
nodes with memory rather than all on-line nodes and we will allocate per
node hstate attributes only for nodes with memory.  This requires that we
register a memory on/off-line notifier and [un]register the attributes on
transitions to/from memoryless state.

V7 addresses review comments,, described in the patches, and includes a
new patch, originally from Mel Gorman, to define a new vm sysctl and
sysfs global hugepages attribute "nr_hugepages_mempolicy" rather than
apply mempolicy contraints to pool adujstments via the pre-existing
"nr_hugepages".  The 3 patches to restrict hugetlb to visiting only
nodes with memory and to add/remove per node hstate attributes on
memory hotplug complete V7.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
