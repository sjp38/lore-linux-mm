Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D06576B0044
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:08 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so1947073pad.38
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:08 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id eb3si5307916pbc.236.2014.01.15.17.25.06
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:07 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 09/22] Remove mm/filemap_xip.c
Date: Wed, 15 Jan 2014 20:24:27 -0500
Message-Id: <ba13cd8603d774710a2116b17691c1e1fa82c450.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

It is now empty as all of its contents have been replaced by fs/xip.c

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/Makefile      |  1 -
 mm/filemap_xip.c | 23 -----------------------
 2 files changed, 24 deletions(-)
 delete mode 100644 mm/filemap_xip.c

diff --git a/mm/Makefile b/mm/Makefile
index 305d10a..c019f5e 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -47,7 +47,6 @@ obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
 obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
-obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
deleted file mode 100644
index 6316578..0000000
--- a/mm/filemap_xip.c
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- *	linux/mm/filemap_xip.c
- *
- * Copyright (C) 2005 IBM Corporation
- * Author: Carsten Otte <cotte@de.ibm.com>
- *
- * derived from linux/mm/filemap.c - Copyright (C) Linus Torvalds
- *
- */
-
-#include <linux/fs.h>
-#include <linux/pagemap.h>
-#include <linux/export.h>
-#include <linux/uio.h>
-#include <linux/rmap.h>
-#include <linux/mmu_notifier.h>
-#include <linux/sched.h>
-#include <linux/seqlock.h>
-#include <linux/mutex.h>
-#include <linux/gfp.h>
-#include <asm/tlbflush.h>
-#include <asm/io.h>
-
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
