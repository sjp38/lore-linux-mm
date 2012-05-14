Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3460E6B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:45:12 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/3] zram: remove comment in Kconfig
Date: Mon, 14 May 2012 17:45:32 +0900
Message-Id: <1336985134-31967-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1336985134-31967-1-git-send-email-minchan@kernel.org>
References: <1336985134-31967-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Exactly speaking, zram should has dependency with
zsmalloc, not x86. So x86 dependeny check is redundant.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/Kconfig |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
index 9d11a4c..ee23a86 100644
--- a/drivers/staging/zram/Kconfig
+++ b/drivers/staging/zram/Kconfig
@@ -1,8 +1,6 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	# X86 dependency is because zsmalloc uses non-portable pte/tlb
-	# functions
-	depends on BLOCK && SYSFS && X86
+	depends on BLOCK && SYSFS
 	select ZSMALLOC
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
