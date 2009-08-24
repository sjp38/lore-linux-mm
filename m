From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Subject: [PATCH 0/5] hugetlb: numa control of persistent huge pages alloc/free
Date: Mon, 24 Aug 2009 15:24:37 -0400
Message-ID: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
Return-path: <linux-numa-owner@vger.kernel.org>
Sender: linux-numa-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-Id: linux-mm.kvack.org

PATCH 0/5 hugetlb: numa control of persistent huge pages alloc/free

Against:  2.6.31-rc6-mmotm-090820-1918

This is V4 of a series of patches to provide control over the location
of the allocation and freeing of persistent huge pages on a NUMA
platform.    This series uses the task NUMA mempolicy of the task
modifying "nr_hugepages" to constrain the affected nodes.  This
method is based on Mel Gorman's suggestion to use task mempolicy.
One of the benefits of this method is that it does not *require*
modification to hugeadm(8) to use this feature.  One of the possible
downsides is that task mempolicy is limited by cpuset constraints.

V4 add a subset of the hugepages sysfs attributes to each per
node system device directory under:

	/sys/devices/node/node[0-9]*/hugepages.

The per node attibutes allow direct assignment of a huge page
count on a specific node, regardless of the task's mempolicy or
cpuset constraints.

Note, I haven't implemented a boot time parameter to constrain the
boot time allocation of huge pages.  This can be added if anyone feels
strongly that it is required.
