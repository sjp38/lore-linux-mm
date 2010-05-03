Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B099C600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:06:16 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 03 May 2010 11:05:18 -0400
Message-Id: <20100503150518.15039.3576.sendpatchset@localhost.localdomain>
In-Reply-To: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/7] numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix1
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Incremental patch 1 to
numa-x86_64-use-generic-percpu-var-numa_node_id-implementation.patch
in 28apr10 mmotm.

Use generic percpu numa_node variable only for x86_64.

x86_32 will require separate support.  Not sure it's worth it.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 arch/x86/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.34-rc5-mmotm-100428-1653/arch/x86/Kconfig
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/arch/x86/Kconfig
+++ linux-2.6.34-rc5-mmotm-100428-1653/arch/x86/Kconfig
@@ -1720,7 +1720,7 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
 	depends on NUMA
 
 config USE_PERCPU_NUMA_NODE_ID
-	def_bool y
+	def_bool X86_64
 	depends on NUMA
 
 menu "Power management and ACPI options"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
