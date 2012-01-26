Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 963826B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:27:25 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH 3/4] dma-buf: Return error instead of using a goto statement when possible
Date: Thu, 26 Jan 2012 12:27:24 +0100
Message-Id: <1327577245-20354-4-git-send-email-laurent.pinchart@ideasonboard.com>
In-Reply-To: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

Remove an error label in dma_buf_attach() that just returns an error
code.

Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
---
 drivers/base/dma-buf.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
index 198edd8..97450a5 100644
--- a/drivers/base/dma-buf.c
+++ b/drivers/base/dma-buf.c
@@ -190,7 +190,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 
 	attach = kzalloc(sizeof(struct dma_buf_attachment), GFP_KERNEL);
 	if (attach == NULL)
-		goto err_alloc;
+		return ERR_PTR(-ENOMEM);
 
 	mutex_lock(&dmabuf->lock);
 
@@ -206,8 +206,6 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 	mutex_unlock(&dmabuf->lock);
 	return attach;
 
-err_alloc:
-	return ERR_PTR(-ENOMEM);
 err_attach:
 	kfree(attach);
 	mutex_unlock(&dmabuf->lock);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
