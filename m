Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA1386B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 13:12:29 -0400 (EDT)
Date: Wed, 3 Aug 2011 10:12:26 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -mmotm] media: video/adp1653.c needs module.h
Message-Id: <20110803101226.0d17b23e.rdunlap@xenotime.net>
In-Reply-To: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
References: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-media@vger.kernel.org, mchehab@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

adp1653.c uses interfaces that are provided by <linux/module.h>
and needs to include that header file to fix build errors.

drivers/media/video/adp1653.c:453: warning: data definition has no type or storage class
drivers/media/video/adp1653.c:453: warning: parameter names (without types) in function declaration
drivers/media/video/adp1653.c:474: error: 'THIS_MODULE' undeclared (first use in this function)
and more.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/media/video/adp1653.c |    1 +
 1 file changed, 1 insertion(+)

--- mmotm-2011-0802-1619.orig/drivers/media/video/adp1653.c
+++ mmotm-2011-0802-1619/drivers/media/video/adp1653.c
@@ -32,6 +32,7 @@
 
 #include <linux/delay.h>
 #include <linux/i2c.h>
+#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/version.h>
 #include <media/adp1653.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
