From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20060505173727.9030.40142.sendpatchset@skynet>
In-Reply-To: <20060505173446.9030.42837.sendpatchset@skynet>
References: <20060505173446.9030.42837.sendpatchset@skynet>
Subject: [PATCH 8/8] Add documentation for extra boot parameters
Date: Fri,  5 May 2006 18:37:27 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Once all patches are applied, two new command-line parameters exist -
kernelcore and noeasyrclm. This patch adds the necessary documentation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.17-rc3-mm1-zonesizing-107_hugetlb_use_easyrclm/Documentation/kernel-parameters.txt linux-2.6.17-rc3-mm1-zonesizing-108_docs/Documentation/kernel-parameters.txt
--- linux-2.6.17-rc3-mm1-zonesizing-107_hugetlb_use_easyrclm/Documentation/kernel-parameters.txt	2006-05-03 09:41:30.000000000 +0100
+++ linux-2.6.17-rc3-mm1-zonesizing-108_docs/Documentation/kernel-parameters.txt	2006-05-03 09:51:12.000000000 +0100
@@ -724,6 +724,22 @@ running once the system is up.
 	js=		[HW,JOY] Analog joystick
 			See Documentation/input/joystick.txt.
 
+	kernelcore=nn[KMG]	[KNL,IA-32,IA-64,PPC,X86-64] This parameter
+			specifies the amount of memory usable by the kernel.
+			The requested amount is spread evenly throughout
+			all nodes in the system. The remaining memory
+			in each node is used for EasyRclm pages. In the
+			event, a node is too small to have both kernelcore
+			and EasyRclm pages, kernelcore pages will take
+			priority and other nodes will have a larger
+			number of kernelcore pages.  The EasyRclm zone
+			is used for the allocation of pages on behalf
+			of a process and for HugeTLB pages. On ppc64,
+			it is likely that memory sections on this zone
+			can be offlined. Note that allocations like
+			PTEs-from-HighMem still use the HighMem zone if
+			it exists, and the Normal zone if it does not.
+
 	keepinitrd	[HW,ARM]
 
 	kstack=N	[IA-32,X86-64] Print N words from the kernel stack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
