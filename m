Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id DE35E6B005A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:32 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 01/11] zcache2: s/int/bool/ on the various options.
Date: Mon,  5 Nov 2012 09:37:24 -0500
Message-Id: <1352126254-28933-2-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
References: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

There are so many, but this allows us to at least have them
right in as bool.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |   46 ++++++++++++++++----------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 42a9d81..5c0c7db 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -30,11 +30,11 @@
 #include "zbud.h"
 #include "ramster.h"
 #ifdef CONFIG_RAMSTER
-static int ramster_enabled;
-static int disable_frontswap_selfshrink;
+static bool ramster_enabled __read_mostly;
+static bool disable_frontswap_selfshrink __read_mostly;
 #else
-#define ramster_enabled 0
-#define disable_frontswap_selfshrink 0
+#define ramster_enabled false
+#define disable_frontswap_selfshrink false
 #endif
 
 #ifndef __PG_WAS_ACTIVE
@@ -57,11 +57,11 @@ static inline void frontswap_tmem_exclusive_gets(bool b)
 }
 #endif
 
-static int zcache_enabled __read_mostly;
-static int disable_cleancache __read_mostly;
-static int disable_frontswap __read_mostly;
-static int disable_frontswap_ignore_nonactive __read_mostly;
-static int disable_cleancache_ignore_nonactive __read_mostly;
+static bool zcache_enabled __read_mostly;
+static bool disable_cleancache __read_mostly;
+static bool disable_frontswap __read_mostly;
+static bool disable_frontswap_ignore_nonactive __read_mostly;
+static bool disable_cleancache_ignore_nonactive __read_mostly;
 static char *namestr __read_mostly = "zcache";
 
 #define ZCACHE_GFP_MASK \
@@ -1649,16 +1649,16 @@ struct frontswap_ops zcache_frontswap_register_ops(void)
 #ifndef CONFIG_ZCACHE2_MODULE
 static int __init enable_zcache(char *s)
 {
-	zcache_enabled = 1;
+	zcache_enabled = true;
 	return 1;
 }
 __setup("zcache", enable_zcache);
 
 static int __init enable_ramster(char *s)
 {
-	zcache_enabled = 1;
+	zcache_enabled = true;
 #ifdef CONFIG_RAMSTER
-	ramster_enabled = 1;
+	ramster_enabled = true;
 #endif
 	return 1;
 }
@@ -1668,7 +1668,7 @@ __setup("ramster", enable_ramster);
 
 static int __init no_cleancache(char *s)
 {
-	disable_cleancache = 1;
+	disable_cleancache = true;
 	return 1;
 }
 
@@ -1676,7 +1676,7 @@ __setup("nocleancache", no_cleancache);
 
 static int __init no_frontswap(char *s)
 {
-	disable_frontswap = 1;
+	disable_frontswap = true;
 	return 1;
 }
 
@@ -1692,7 +1692,7 @@ __setup("nofrontswapexclusivegets", no_frontswap_exclusive_gets);
 
 static int __init no_frontswap_ignore_nonactive(char *s)
 {
-	disable_frontswap_ignore_nonactive = 1;
+	disable_frontswap_ignore_nonactive = true;
 	return 1;
 }
 
@@ -1700,7 +1700,7 @@ __setup("nofrontswapignorenonactive", no_frontswap_ignore_nonactive);
 
 static int __init no_cleancache_ignore_nonactive(char *s)
 {
-	disable_cleancache_ignore_nonactive = 1;
+	disable_cleancache_ignore_nonactive = true;
 	return 1;
 }
 
@@ -1709,7 +1709,7 @@ __setup("nocleancacheignorenonactive", no_cleancache_ignore_nonactive);
 static int __init enable_zcache_compressor(char *s)
 {
 	strncpy(zcache_comp_name, s, ZCACHE_COMP_NAME_SZ);
-	zcache_enabled = 1;
+	zcache_enabled = true;
 	return 1;
 }
 __setup("zcache=", enable_zcache_compressor);
@@ -1759,7 +1759,7 @@ static int zcache_init(void)
 	int ret = 0;
 
 #ifdef CONFIG_ZCACHE2_MODULE
-	zcache_enabled = 1;
+	zcache_enabled = true;
 #endif
 	if (ramster_enabled) {
 		namestr = "ramster";
@@ -1840,15 +1840,15 @@ out:
 
 #ifdef CONFIG_ZCACHE2_MODULE
 #ifdef CONFIG_RAMSTER
-module_param(ramster_enabled, int, S_IRUGO);
-module_param(disable_frontswap_selfshrink, int, S_IRUGO);
+module_param(ramster_enabled, bool, S_IRUGO);
+module_param(disable_frontswap_selfshrink, bool, S_IRUGO);
 #endif
-module_param(disable_cleancache, int, S_IRUGO);
-module_param(disable_frontswap, int, S_IRUGO);
+module_param(disable_cleancache, bool, S_IRUGO);
+module_param(disable_frontswap, bool, S_IRUGO);
 #ifdef FRONTSWAP_HAS_EXCLUSIVE_GETS
 module_param(frontswap_has_exclusive_gets, bool, S_IRUGO);
 #endif
-module_param(disable_frontswap_ignore_nonactive, int, S_IRUGO);
+module_param(disable_frontswap_ignore_nonactive, bool, S_IRUGO);
 module_param(zcache_comp_name, charp, S_IRUGO);
 module_init(zcache_init);
 MODULE_LICENSE("GPL");
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
