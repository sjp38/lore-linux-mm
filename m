Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F04B06B006E
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 03:06:51 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 3/3] zram: select ZSMALLOC when ZRAM is configured
Date: Fri,  2 Nov 2012 16:12:47 +0900
Message-Id: <1351840367-4152-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1351840367-4152-1-git-send-email-minchan@kernel.org>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, Minchan Kim <minchan@kernel.org>

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
