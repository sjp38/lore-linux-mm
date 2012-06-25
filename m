Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id F36A16B0369
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:23:06 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 12:23:04 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 704CD6E806D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:49 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PGEnfJ179224
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PGEkf3002547
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:14:48 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 1/3] zram/zcache: swtich Kconfig dependency from X86 to ZSMALLOC
Date: Mon, 25 Jun 2012 11:14:36 -0500
Message-Id: <1340640878-27536-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch switches zcache and zram dependency to ZSMALLOC
rather than X86.  There is no net change since ZSMALLOC
depends on X86, however, this prevent further changes to
these files as zsmalloc dependencies change.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Kconfig |    5 +----
 drivers/staging/zram/Kconfig   |    5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 7048e01..4881839 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -1,9 +1,6 @@
 config ZCACHE
 	bool "Dynamic compression of swap pages and clean pagecache pages"
-	# X86 dependency is because zsmalloc uses non-portable pte/tlb
-	# functions
-	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
-	select ZSMALLOC
+	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && ZSMALLOC=y
 	select CRYPTO_LZO
 	default n
 	help
diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
index 9d11a4c..be5abe8 100644
--- a/drivers/staging/zram/Kconfig
+++ b/drivers/staging/zram/Kconfig
@@ -1,9 +1,6 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	# X86 dependency is because zsmalloc uses non-portable pte/tlb
-	# functions
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
