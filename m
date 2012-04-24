Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 3650D6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 21:34:24 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 23 Apr 2012 19:34:23 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9DD7A19D8048
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 19:34:11 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3O1YLk8191846
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 19:34:21 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3O1YKZB023898
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 19:34:20 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] drivers: staging: zcache: fix Kconfig crypto dependency
Date: Mon, 23 Apr 2012 20:33:50 -0500
Message-Id: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Autif Khan <autif.mlist@gmail.com>

ZCACHE is a boolean in the Kconfig.  When selected, it
should require that CRYPTO be builtin (=y).

Currently, ZCACHE=y and CRYPTO=m is a valid configuration
when it should not be.

This patch changes the zcache Kconfig to enforce this
dependency.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 3ed2c8f..7048e01 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -2,7 +2,7 @@ config ZCACHE
 	bool "Dynamic compression of swap pages and clean pagecache pages"
 	# X86 dependency is because zsmalloc uses non-portable pte/tlb
 	# functions
-	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO && X86
+	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
 	select ZSMALLOC
 	select CRYPTO_LZO
 	default n
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
