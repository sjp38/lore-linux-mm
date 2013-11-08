Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF066B0201
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:19 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so2788847pbc.26
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id pl8si8067862pbb.224.2013.11.08.15.43.16
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:17 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 06/24] mm/staging: remove unnecessary inclusion of bootmem.h
Date: Fri, 8 Nov 2013 18:41:42 -0500
Message-ID: <1383954120-24368-7-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Hubbs <w.d.hubbs@gmail.com>, Chris Brannon <chris@the-brannons.com>, Kirk Reiser <kirk@reisers.ca>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Clean-up to remove depedency with bootmem headers.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: William Hubbs <w.d.hubbs@gmail.com>
Cc: Chris Brannon <chris@the-brannons.com>
Cc: Kirk Reiser <kirk@reisers.ca>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 drivers/staging/speakup/main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/speakup/main.c b/drivers/staging/speakup/main.c
index 14079c4..041f01e 100644
--- a/drivers/staging/speakup/main.c
+++ b/drivers/staging/speakup/main.c
@@ -37,8 +37,6 @@
 #include <linux/input.h>
 #include <linux/kmod.h>
 
-#include <linux/bootmem.h>	/* for alloc_bootmem */
-
 /* speakup_*_selection */
 #include <linux/module.h>
 #include <linux/sched.h>
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
