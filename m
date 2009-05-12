Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 607046B0062
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:10:07 -0400 (EDT)
Received: by pzk5 with SMTP id 5so134826pzk.12
        for <linux-mm@kvack.org>; Tue, 12 May 2009 06:10:15 -0700 (PDT)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Tue, 12 May 2009 22:07:19 +0900
Message-Id: <20090512130719.7857.85985.sendpatchset@rx1.opensource.se>
Subject: [PATCH] videobuf-dma-contig: zero copy USERPTR V3 comments
Sender: owner-linux-mm@kvack.org
To: linux-media@vger.kernel.org
Cc: mchehab@infradead.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org, hannes@cmpxchg.org, Magnus Damm <magnus.damm@gmail.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@igel.co.jp>

This patch adds function descriptions to V3 of the V4L2
videobuf-dma-contig USERPTR zero copy patch.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/media/video/videobuf-dma-contig.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

--- 0005/drivers/media/video/videobuf-dma-contig.c
+++ work/drivers/media/video/videobuf-dma-contig.c	2009-05-12 21:14:40.000000000 +0900
@@ -110,6 +110,12 @@ static struct vm_operations_struct video
 	.close    = videobuf_vm_close,
 };
 
+/**
+ * videobuf_dma_contig_user_put() - reset pointer to user space buffer
+ * @mem: per-buffer private videobuf-dma-contig data
+ *
+ * This function resets the user space pointer 
+ */
 static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 {
 	mem->is_userptr = 0;
@@ -117,6 +123,16 @@ static void videobuf_dma_contig_user_put
 	mem->size = 0;
 }
 
+/**
+ * videobuf_dma_contig_user_get() - setup user space memory pointer
+ * @mem: per-buffer private videobuf-dma-contig data
+ * @vb: video buffer to map
+ *
+ * This function validates and sets up a pointer to user space memory.
+ * Only physically contiguous pfn-mapped memory is accepted.
+ *
+ * Returns 0 if successful.
+ */
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
