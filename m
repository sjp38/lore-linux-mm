Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77D3A6B0207
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:44:54 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:44:09 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Frontswap [PATCH 4/4] (was Transcendent Memory): config files
Message-ID: <20100422134409.GA3078@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Frontswap [PATCH 4/4] (was Transcendent Memory): config files

Frontswap config defaults to on as the hooks devolve to
pointer-compare-to-NULL if no frontswap backend is provided.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 Kconfig                                  |   16 ++++++++++++++++
 Makefile                                 |    1 +
 2 files changed, 17 insertions(+)

--- linux-2.6.34-rc5/mm/Makefile	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-frontswap/mm/Makefile	2010-04-21 09:17:37.000000000 -0600
@@ -17,6 +17,7 @@ obj-y += init-mm.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
--- linux-2.6.34-rc5/mm/Kconfig	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-frontswap/mm/Kconfig	2010-04-21 09:17:37.000000000 -0600
@@ -287,3 +287,19 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config FRONTSWAP
+	bool "Enable frontswap pseudo-RAM driver to cache swap pages"
+	default y
+	help
+ 	  Frontswap is so named because it can be thought of as the opposite of
+ 	  a "backing" store for a swap device.  The storage is assumed to be
+ 	  a synchronous concurrency-safe page-oriented pseudo-RAM device (such
+	  as Xen's Transcendent Memory, aka "tmem") which is not directly
+	  accessible or addressable by the kernel and is of unknown (and
+	  possibly time-varying) size.  When a pseudo-RAM device is available,
+	  a signficant swap I/O reduction may be achieved.  When none is
+	  available, all frontswap calls are reduced to a single pointer-
+	  compare-against-NULL resulting in a negligible performance hit.
+
+	  If unsure, say Y to enable frontswap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
