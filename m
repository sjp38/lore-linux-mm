Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 63CE86B004D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 12:34:52 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 10:34:51 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0862A3E40047
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 10:33:58 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25HXnar133984
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:56 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25HXjgx000463
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:45 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 5/5] staging: zsmalloc: remove SPARSEMEM dep from Kconfig
Date: Mon,  5 Mar 2012 11:33:24 -0600
Message-Id: <1330968804-8098-6-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch removes the SPARSEMEM from the zsmalloc
Kconfig

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index 8e2c6a0..a5ab720 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -3,7 +3,7 @@ config ZSMALLOC
 	# X86 dependency is because of the use of __flush_tlb_one and set_pte
 	# in zsmalloc-main.c.
 	# TODO: convert these to portable functions
-	depends on SPARSEMEM && X86
+	depends on X86
 	default n
 	help
 	  zsmalloc is a slab-based memory allocator designed to store
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
