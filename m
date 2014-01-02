Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 511256B0037
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:42 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so14554192pdj.23
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:41 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ey5si39823918pab.306.2014.01.02.13.53.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:40 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 03/11] percpu: use VMALLOC_TOTAL instead of VMALLOC_END - VMALLOC_START
Date: Thu,  2 Jan 2014 13:53:21 -0800
Message-Id: <1388699609-18214-4-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

vmalloc already gives a useful macro to calculate the total vmalloc
size. Use it.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 mm/percpu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 0d10def..afbf352 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1686,10 +1686,10 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	max_distance += ai->unit_size;
 
 	/* warn if maximum distance is further than 75% of vmalloc space */
-	if (max_distance > (VMALLOC_END - VMALLOC_START) * 3 / 4) {
+	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
 		pr_warning("PERCPU: max_distance=0x%zx too large for vmalloc "
 			   "space 0x%lx\n", max_distance,
-			   (unsigned long)(VMALLOC_END - VMALLOC_START));
+			   VMALLOC_TOTAL);
 #ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
 		/* and fail if we have fallback */
 		rc = -EINVAL;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
