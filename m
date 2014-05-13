Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5A46B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 04:24:27 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id un15so734361pbc.34
        for <linux-mm@kvack.org>; Tue, 13 May 2014 01:24:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zm10si7599646pbc.189.2014.05.13.01.24.26
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 01:24:26 -0700 (PDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] mm: exclude duplicate header
Date: Tue, 13 May 2014 11:24:22 +0300
Message-Id: <1399969462-15768-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

The mmdebug.h is included twice. Let's remove one entry.
There is no functinal changes.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 include/linux/gfp.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index d382db7..6a96514 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -6,7 +6,6 @@
 #include <linux/stddef.h>
 #include <linux/linkage.h>
 #include <linux/topology.h>
-#include <linux/mmdebug.h>
 
 struct vm_area_struct;
 
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
