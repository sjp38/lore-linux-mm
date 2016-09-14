Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8943E6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 18:02:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so25345355lfb.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:02:41 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id e69si447085wmc.143.2016.09.14.15.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 15:02:39 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id k186so33517945wmd.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:02:39 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm/shmem.c: constify anon_ops
Date: Thu, 15 Sep 2016 00:02:07 +0200
Message-Id: <1473890528-7009-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Every other dentry_operations instance is const, and this one might as
well be.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index fd8b2b5741b1..693ffdc5899a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4077,7 +4077,7 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
 /* common code */
 
-static struct dentry_operations anon_ops = {
+static const struct dentry_operations anon_ops = {
 	.d_dname = simple_dname
 };
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
