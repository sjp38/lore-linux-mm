Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03A936810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 13:42:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t193so11882081pgc.4
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 10:42:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y38sor3505202plh.3.2017.08.26.10.42.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 Aug 2017 10:42:04 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] mm/zswap: constify struct kernel_param_ops uses
Date: Sat, 26 Aug 2017 23:11:48 +0530
Message-Id: <2e26a2cef6e2148a7aadb77e9e64835fab6b4dc2.1503769223.git.arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@redhat.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

kernel_param_ops are not supposed to change at runtime. All functions
working with kernel_param_ops provided by <linux/moduleparam.h> work
with const kernel_param_ops. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/zswap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index d39581a..030fbf9 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -82,7 +82,7 @@ static u64 zswap_duplicate_entry;
 static bool zswap_enabled;
 static int zswap_enabled_param_set(const char *,
 				   const struct kernel_param *);
-static struct kernel_param_ops zswap_enabled_param_ops = {
+static const struct kernel_param_ops zswap_enabled_param_ops = {
 	.set =		zswap_enabled_param_set,
 	.get =		param_get_bool,
 };
@@ -93,7 +93,7 @@ module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
 static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
 static int zswap_compressor_param_set(const char *,
 				      const struct kernel_param *);
-static struct kernel_param_ops zswap_compressor_param_ops = {
+static const struct kernel_param_ops zswap_compressor_param_ops = {
 	.set =		zswap_compressor_param_set,
 	.get =		param_get_charp,
 	.free =		param_free_charp,
@@ -105,7 +105,7 @@ module_param_cb(compressor, &zswap_compressor_param_ops,
 #define ZSWAP_ZPOOL_DEFAULT "zbud"
 static char *zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
 static int zswap_zpool_param_set(const char *, const struct kernel_param *);
-static struct kernel_param_ops zswap_zpool_param_ops = {
+static const struct kernel_param_ops zswap_zpool_param_ops = {
 	.set =		zswap_zpool_param_set,
 	.get =		param_get_charp,
 	.free =		param_free_charp,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
