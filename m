Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6F8DD6B0092
	for <linux-mm@kvack.org>; Tue, 15 May 2012 22:05:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/3] remove dependency with x86
Date: Wed, 16 May 2012 11:05:18 +0900
Message-Id: <1337133919-4182-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1337133919-4182-1-git-send-email-minchan@kernel.org>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Exactly saying, [zram|zcache] should has a dependency with
zsmalloc, not x86. So replace x86 dependeny with ZSMALLOC.

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zcache/Kconfig |    3 +--
 drivers/staging/zram/Kconfig   |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 7048e01..ceb7f28 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -2,8 +2,7 @@ config ZCACHE
 	bool "Dynamic compression of swap pages and clean pagecache pages"
 	# X86 dependency is because zsmalloc uses non-portable pte/tlb
 	# functions
-	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
-	select ZSMALLOC
+	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && ZSMALLOC
 	select CRYPTO_LZO
 	default n
 	help
diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
index 9d11a4c..e3ac62d 100644
--- a/drivers/staging/zram/Kconfig
+++ b/drivers/staging/zram/Kconfig
@@ -2,8 +2,7 @@ config ZRAM
 	tristate "Compressed RAM block device support"
 	# X86 dependency is because zsmalloc uses non-portable pte/tlb
 	# functions
-	depends on BLOCK && SYSFS && X86
-	select ZSMALLOC
+	depends on BLOCK && SYSFS && ZSMALLOC
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
