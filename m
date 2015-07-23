Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id DC2706B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:18:18 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so143980173wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 04:18:18 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id b14si7816935wjz.87.2015.07.23.04.18.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 04:18:17 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so143979239wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 04:18:16 -0700 (PDT)
From: Valentin Rothberg <valentinrothberg@gmail.com>
Subject: [PATCH] mm/Kconfig: NEED_BOUNCE_POOL: clean-up condition
Date: Thu, 23 Jul 2015 13:18:06 +0200
Message-Id: <1437650286-117629-1-git-send-email-valentinrothberg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: pebolle@tiscali.nl, stefan.hengelein@fau.de, Valentin Rothberg <valentinrothberg@gmail.com>

commit 106542e7987c ("fs: Remove ext3 filesystem driver") removed ext3
and JBD, hence remove the superfluous condition.

Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
---
I detected the issue with undertaker-checkpatch
(https://undertaker.cs.fau.de)

 mm/Kconfig | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2bd12cd..d4e6495a720f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -299,15 +299,9 @@ config BOUNCE
 # On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
 # have more than 4GB of memory, but we don't currently use the IOTLB to present
 # a 32-bit address to OHCI.  So we need to use a bounce pool instead.
-#
-# We also use the bounce pool to provide stable page writes for jbd.  jbd
-# initiates buffer writeback without locking the page or setting PG_writeback,
-# and fixing that behavior (a second time; jbd2 doesn't have this problem) is
-# a major rework effort.  Instead, use the bounce buffer to snapshot pages
-# (until jbd goes away).  The only jbd user is ext3.
 config NEED_BOUNCE_POOL
 	bool
-	default y if (TILE && USB_OHCI_HCD) || (BLK_DEV_INTEGRITY && JBD)
+	default y if TILE && USB_OHCI_HCD
 
 config NR_QUICK
 	int
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
