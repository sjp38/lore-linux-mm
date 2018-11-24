Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E21386B35B9
	for <linux-mm@kvack.org>; Sat, 24 Nov 2018 04:05:12 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d11so11465615wrw.4
        for <linux-mm@kvack.org>; Sat, 24 Nov 2018 01:05:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1sor13102598wro.44.2018.11.24.01.05.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Nov 2018 01:05:11 -0800 (PST)
Date: Sat, 24 Nov 2018 12:05:08 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] mm: make "migrate_reason_names[]" const char *
Message-ID: <20181124090508.GB10877@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, vbabka@suse.cz

Those strings are immutable as well.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/migrate.h |    2 +-
 mm/debug.c              |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -29,7 +29,7 @@ enum migrate_reason {
 };
 
 /* In mm/debug.c; also keep sync with include/trace/events/migrate.h */
-extern char *migrate_reason_names[MR_TYPES];
+extern const char *migrate_reason_names[MR_TYPES];
 
 static inline struct page *new_page_nodemask(struct page *page,
 				int preferred_nid, nodemask_t *nodemask)
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -17,7 +17,7 @@
 
 #include "internal.h"
 
-char *migrate_reason_names[MR_TYPES] = {
+const char *migrate_reason_names[MR_TYPES] = {
 	"compaction",
 	"memory_failure",
 	"memory_hotplug",
