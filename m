Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6311A6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 03:53:25 -0400 (EDT)
Received: by labgv11 with SMTP id gv11so25013832lab.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 00:53:24 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id ba5si15387877lbc.148.2015.08.25.00.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 00:53:23 -0700 (PDT)
Received: by labia3 with SMTP id ia3so28329838lab.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 00:53:22 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/cma_debug: Check return value of the debugfs_create_dir()
Date: Tue, 25 Aug 2015 13:52:34 +0600
Message-Id: <1440489154-3470-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, Dmitry Safonov <d.safonov@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The debugfs_create_dir() function may fail and return error. If the
root directory not created, we can't create anything inside it. This
patch adds check for this case.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/cma_debug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index f8e4b60..bfb46e2 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -171,6 +171,9 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 	tmp = debugfs_create_dir(name, cma_debugfs_root);
 
+	if (!tmp)
+		return;
+
 	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
 				&cma_alloc_fops);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
