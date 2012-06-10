Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 224E36B007B
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:27 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841564bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:26 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 10/10] mm: frontswap: remove unneeded headers
Date: Sun, 10 Jun 2012 12:51:08 +0200
Message-Id: <1339325468-30614-11-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index c056f6e..9b667a4 100644
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
