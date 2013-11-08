Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 200BD6B0141
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:13 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id rd3so892pab.22
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id cx4si8092083pbc.119.2013.11.08.15.43.11
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:11 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 05/24] mm/memory_hotplug: remove unnecessary inclusion of bootmem.h
Date: Fri, 8 Nov 2013 18:41:41 -0500
Message-ID: <1383954120-24368-6-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Clean-up to remove depedency with bootmem headers.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/memory_hotplug.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ed85fe3..f7bda5e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -9,7 +9,6 @@
 #include <linux/swap.h>
 #include <linux/interrupt.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
 #include <linux/compiler.h>
 #include <linux/export.h>
 #include <linux/pagevec.h>
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
