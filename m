Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA899vv7005753
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:09:57 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA89AL1G145320
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:10:21 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA89AKgK009704
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:10:21 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sat, 08 Nov 2008 14:40:09 +0530
Message-Id: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
Subject: [RFC][mm][PATCH 0/4] Memory cgroup hierarchy introduction (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch follows several iterations of the memory controller hierarchy
patches. The hardwall approach by Kamezawa-San[1]. Version 1 of this patchset
at [2].

The current approach is based on [2] and has the following properties

1. Hierarchies are very natural in a filesystem like the cgroup filesystem.
   A multi-tree hierarchy has been supported for a long time in filesystems.
   When the feature is turned on, we honor hierarchies such that the root
   accounts for resource usage of all children and limits can be set at
   any point in the hierarchy. Any memory cgroup is limited by limits
   along the hierarchy. The total usage of all children of a node cannot
   exceed the limit of the node.
2. The hierarchy feature is selectable and off by default
3. Hierarchies are expensive and the trade off is depth versus performance.
   Hierarchies can also be completely turned off.

The patches are against 2.6.28-rc2-mm1 and were tested in a KVM instance
with SMP and swap turned on.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

v2..v1
======
1. The hierarchy is now selectable per-subtree
2. The features file has been renamed to use_hierarchy
3. Reclaim now holds cgroup lock and the reclaim does recursive walk and reclaim

Series
------

memcg-hierarchy-documentation.patch
resource-counters-hierarchy-support.patch
memcg-hierarchical-reclaim.patch
memcg-add-hierarchy-selector.patch

Reviews? Comments?

References

1. http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-06/msg05417.html
2. http://kerneltrap.org/mailarchive/linux-kernel/2008/4/19/1513644/thread

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
