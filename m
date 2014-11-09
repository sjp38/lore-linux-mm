Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3B65282BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 07:24:11 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kx10so6436085pab.34
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 04:24:10 -0800 (PST)
Received: from mail-pd0-x241.google.com (mail-pd0-x241.google.com. [2607:f8b0:400e:c02::241])
        by mx.google.com with ESMTPS id g12si13817436pat.237.2014.11.09.04.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 04:24:10 -0800 (PST)
Received: by mail-pd0-f193.google.com with SMTP id fp1so2464607pdb.4
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 04:24:09 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zswap: add __init to some functions in zswap
Date: Sun,  9 Nov 2014 20:23:52 +0800
Message-Id: <1415535832-4822-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net, minchan@kernel.org
Cc: ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

zswap_cpu_init/zswap_comp_exit/zswap_entry_cache_create is only
called by __init init_zswap()

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zswap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 51a2c45..2e621fa 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -149,7 +149,7 @@ static int __init zswap_comp_init(void)
 	return 0;
 }
 
-static void zswap_comp_exit(void)
+static void __init zswap_comp_exit(void)
 {
 	/* free percpu transforms */
 	if (zswap_comp_pcpu_tfms)
@@ -206,7 +206,7 @@ static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
 **********************************/
 static struct kmem_cache *zswap_entry_cache;
 
-static int zswap_entry_cache_create(void)
+static int __init zswap_entry_cache_create(void)
 {
 	zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
 	return zswap_entry_cache == NULL;
@@ -389,7 +389,7 @@ static struct notifier_block zswap_cpu_notifier_block = {
 	.notifier_call = zswap_cpu_notifier
 };
 
-static int zswap_cpu_init(void)
+static int __init zswap_cpu_init(void)
 {
 	unsigned long cpu;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
