Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 869686B0068
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 04:47:18 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/3] zram: select ZSMALLOC when ZRAM is configured
Date: Wed, 26 Sep 2012 17:50:19 +0900
Message-Id: <1348649419-16494-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1348649419-16494-1-git-send-email-minchan@kernel.org>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

At the monent, we can configure zram in driver/block once zsmalloc
in /lib menu is configured firstly. It's not convenient.

User can configure zram in driver/block regardless of zsmalloc enabling
by this patch.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index be5abe8..ee23a86 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -1,6 +1,7 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	depends on BLOCK && SYSFS && ZSMALLOC
+	depends on BLOCK && SYSFS
+	select ZSMALLOC
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
