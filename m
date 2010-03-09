Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 301256B009E
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:25 -0500 (EST)
Message-Id: <20100309194313.447573578@redhat.com>
Date: Tue, 09 Mar 2010 20:39:13 +0100
From: aarcange@redhat.com
Subject: [patch 12/35] config_transparent_hugepage
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=config_transparent_hugepage
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add config option.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/Kconfig |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -287,3 +287,17 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config TRANSPARENT_HUGEPAGE
+	bool "Transparent Hugepage support" if EMBEDDED
+	depends on X86_64
+	default y
+	help
+	  Transparent Hugepages allows the kernel to use huge pages and
+	  huge tlb transparently to the applications whenever possible.
+	  This feature can improve computing performance to certain
+	  applications by speeding up page faults during memory
+	  allocation, by reducing the number of tlb misses and by speeding
+	  up the pagetable walking.
+
+	  If memory constrained on embedded, you may want to say N.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
