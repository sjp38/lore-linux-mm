Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 63BA16B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:11:13 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so20124515pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:11:13 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id b2si15663208pat.102.2016.01.28.01.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 01:11:12 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id cy9so20233075pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:11:12 -0800 (PST)
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] mm: provide reference to READ_IMPLIES_EXEC
Date: Thu, 28 Jan 2016 14:41:03 +0530
Message-Id: <1453972263-25907-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>

blackfin defconfig fails with the error:
mm/internal.h: In function 'is_stack_mapping':
arch/blackfin/include/asm/page.h:15:27: error: 'READ_IMPLIES_EXEC' undeclared

Commit 07dff8ae2bc5 has added is_stack_mapping in mm/internal.h but it
also needs personality.h.

Fixes: 07dff8ae2bc5 ("mm: warn about VmData over RLIMIT_DATA")
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

build log at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/105335848

 mm/internal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/internal.h b/mm/internal.h
index cac6eb4..59c496f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,7 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/personality.h>
 #include <linux/tracepoint-defs.h>
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
