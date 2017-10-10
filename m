Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02BDE6B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:51:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so62467154pfj.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:51:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s1sor1822314plk.38.2017.10.10.08.51.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 08:51:38 -0700 (PDT)
From: Pintu Agarwal <pintu.ping@gmail.com>
Subject: [PATCH 1/1] [mm]: cma: change pr_info to pr_err for cma_alloc fail log
Date: Tue, 10 Oct 2017 11:50:33 -0400
Message-Id: <1507650633-4430-1-git-send-email-pintu.ping@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, labbott@redhat.com, gregkh@linuxfoundation.org, jaewon31.kim@samsung.com, opendmb@gmail.com, pintu.ping@gmail.com

It was observed that under cma_alloc fail log, pr_info was
used instead of pr_err.
This will lead to problem if printk debug level is set to
below 7. In this case the cma_alloc failure log will not
be captured in the log and it will be difficult to debug.

Simply replace the pr_info with pr_err to capture failure log.

Signed-off-by: Pintu Agarwal <pintu.ping@gmail.com>
---
 mm/cma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index c0da318..e0d1393 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -461,7 +461,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	trace_cma_alloc(pfn, page, count, align);
 
 	if (ret) {
-		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
+		pr_err("%s: alloc failed, req-size: %zu pages, ret: %d\n",
 			__func__, count, ret);
 		cma_debug_show_areas(cma);
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
