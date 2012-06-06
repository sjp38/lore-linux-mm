Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4A2DE6B009B
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:47 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so13312502obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:46 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 11/11] mm: frontswap: remove unneeded headers
Date: Wed,  6 Jun 2012 12:55:15 +0200
Message-Id: <1338980115-2394-11-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 92e2e7b..2a5d421 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -12,15 +12,11 @@
  */
 
 #define CREATE_TRACE_POINTS
-#include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
-#include <linux/proc_fs.h>
 #include <linux/security.h>
-#include <linux/capability.h>
 #include <linux/module.h>
-#include <linux/uaccess.h>
 #include <linux/debugfs.h>
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
