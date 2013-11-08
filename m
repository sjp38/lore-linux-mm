Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id F02BA6B0203
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:20 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so2821814pbc.14
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id ll9si8426080pab.240.2013.11.08.15.43.17
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:18 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 07/24] mm/char: remove unnecessary inclusion of bootmem.h
Date: Fri, 8 Nov 2013 18:41:43 -0500
Message-ID: <1383954120-24368-8-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Clean-up to remove depedency with bootmem headers.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 drivers/char/mem.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index f895a8c..92c5937 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -22,7 +22,6 @@
 #include <linux/device.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
-#include <linux/bootmem.h>
 #include <linux/splice.h>
 #include <linux/pfn.h>
 #include <linux/export.h>
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
