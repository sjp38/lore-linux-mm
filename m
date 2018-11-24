Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FABB6B35B6
	for <linux-mm@kvack.org>; Sat, 24 Nov 2018 04:03:31 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j30so8603525wre.16
        for <linux-mm@kvack.org>; Sat, 24 Nov 2018 01:03:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w8sor22356215wrl.37.2018.11.24.01.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Nov 2018 01:03:30 -0800 (PST)
Date: Sat, 24 Nov 2018 12:03:27 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] mm: make "migratetype_names" const char *
Message-ID: <20181124090327.GA10877@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Those strings are immutable in fact.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/mmzone.h |    2 +-
 mm/page_alloc.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -65,7 +65,7 @@ enum migratetype {
 };
 
 /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
-extern char * const migratetype_names[MIGRATE_TYPES];
+extern const char * const migratetype_names[MIGRATE_TYPES];
 
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -237,7 +237,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
 #endif
 };
 
-char * const migratetype_names[MIGRATE_TYPES] = {
+const char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Movable",
 	"Reclaimable",
