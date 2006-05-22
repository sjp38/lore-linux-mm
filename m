Date: Mon, 22 May 2006 10:53:11 +0100
Subject: [PATCH 1/2] zone allow unaligned zone boundaries add configuration
Message-ID: <20060522095311.GA6869@shadowen.org>
References: <exportbomb.1148291574@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

zone allow unaligned zone boundaries add configuration

Add a configuration definition for UNALIGNED_ZONE_BOUNDARIES.  Default
to on unless the architecture indicates that it ensures that the boundaries
are correctly aligned.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 Kconfig |   13 +++++++++++++
 1 files changed, 13 insertions(+)
diff -upN reference/mm/Kconfig current/mm/Kconfig
--- reference/mm/Kconfig
+++ current/mm/Kconfig
@@ -145,3 +145,16 @@ config MIGRATION
 	  while the virtual addresses are not changed. This is useful for
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
+
+#
+# Support for buddy zone boundaries within a MAX_ORDER sized area.
+#
+config UNALIGNED_ZONE_BOUNDARIES
+	bool "Unaligned zone boundaries"
+	default n if ARCH_ALIGNED_ZONE_BOUNDARIES
+	default y
+	help
+	  Adds checks to the buddy allocator to ensure we do not
+	  coalesce buddies across zone boundaries.  The default
+	  should be correct for your architecture.  Enable this if
+	  you are having trouble and you are requested to in dmesg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
