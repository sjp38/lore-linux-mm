Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 00A0D620014
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:33:03 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 12 of 32] config_transparent_hugepage
Message-Id: <eda40e94a9fffea6cfe9.1264969643@v2.random>
In-Reply-To: <patchbomb.1264969631@v2.random>
References: <patchbomb.1264969631@v2.random>
Date: Sun, 31 Jan 2010 21:27:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add config option.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---

diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -283,3 +283,17 @@ config NOMMU_INITIAL_TRIM_EXCESS
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
