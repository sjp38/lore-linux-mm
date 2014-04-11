Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 48CCD6B0037
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 04:39:17 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so5107285pbc.7
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 01:39:15 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id tv5si3740979pbc.330.2014.04.11.01.39.14
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 01:39:15 -0700 (PDT)
From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] mm: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Fri, 11 Apr 2014 16:37:03 +0800
Message-ID: <1397205423-24214-1-git-send-email-duanj.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, oleg@redhat.com, riel@redhat.com, walken@google.com, hughd@google.com
Cc: linux-mm@kvack.org, Duan Jiong <duanj.fnst@cn.fujitsu.com>

This patch fixes coccinelle error regarding usage of IS_ERR and
PTR_ERR instead of PTR_ERR_OR_ZERO.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 mm/mmap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf..6cdec3a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2965,9 +2965,7 @@ int install_special_mapping(struct mm_struct *mm,
 	struct vm_area_struct *vma = _install_special_mapping(mm,
 			    addr, len, vm_flags, pages);
 
-	if (IS_ERR(vma))
-		return PTR_ERR(vma);
-	return 0;
+	return PTR_ERR_OR_ZERO(vma);
 }
 
 static DEFINE_MUTEX(mm_all_locks_mutex);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
