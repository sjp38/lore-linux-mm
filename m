Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 981826B0039
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:01:00 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so5579522pbb.2
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:01:00 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id zq7si9131395pac.130.2013.12.16.07.00.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:58 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 2/5] VFS: Convert sysctl_drop_caches to string
Date: Mon, 16 Dec 2013 07:00:06 -0800
Message-Id: <3640f727452d7a64671408b35875161a791ca24d.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 include/linux/mm.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..5e3cc5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -17,6 +17,7 @@
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
+#include <linux/fs.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1920,7 +1921,7 @@ int in_gate_area_no_mm(unsigned long addr);
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
 #ifdef CONFIG_SYSCTL
-extern int sysctl_drop_caches;
+extern char sysctl_drop_caches[PATH_MAX];
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
