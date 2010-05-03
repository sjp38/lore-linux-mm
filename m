Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B9A62600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:05:15 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 03 May 2010 11:05:11 -0400
Message-Id: <20100503150511.15039.95965.sendpatchset@localhost.localdomain>
In-Reply-To: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/7] numa-add-generic-percpu-var-numa_node_id-implementation-fix2
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Incremental patch 2 to
numa-add-generic-percpu-var-numa_node_id-implementation.patch
in 28apr10 mmotm.

Define generic macro to set 'numa_node' for a specified cpu as
suggested by Christoph Lameter and seconded by Tejun Heo.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/topology.h |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/include/linux/topology.h
+++ linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
@@ -232,6 +232,13 @@ static inline void set_numa_node(int nod
 }
 #endif
 
+#ifndef set_cpu_numa_node
+static inline void set_cpu_numa_node(int cpu, int node)
+{
+	per_cpu(numa_node, cpu) = node;
+}
+#endif
+
 #else	/* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
 
 /* Returns the number of the current Node. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
