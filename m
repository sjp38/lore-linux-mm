Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AF6996B005A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:27:22 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH 1/4] dma-buf: Constify ops argument to dma_buf_export()
Date: Thu, 26 Jan 2012 12:27:22 +0100
Message-Id: <1327577245-20354-2-git-send-email-laurent.pinchart@ideasonboard.com>
In-Reply-To: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

This allows drivers to make the dma buf operations structure constant.

Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
---
 drivers/base/dma-buf.c  |    2 +-
 include/linux/dma-buf.h |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
index e38ad24..965833ac 100644
--- a/drivers/base/dma-buf.c
+++ b/drivers/base/dma-buf.c
@@ -71,7 +71,7 @@ static inline int is_dma_buf_file(struct file *file)
  * ops, or error in allocating struct dma_buf, will return negative error.
  *
  */
-struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
+struct dma_buf *dma_buf_export(void *priv, const struct dma_buf_ops *ops,
 				size_t size, int flags)
 {
 	struct dma_buf *dmabuf;
diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
index f8ac076..86f6241 100644
--- a/include/linux/dma-buf.h
+++ b/include/linux/dma-buf.h
@@ -114,8 +114,8 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 							struct device *dev);
 void dma_buf_detach(struct dma_buf *dmabuf,
 				struct dma_buf_attachment *dmabuf_attach);
-struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
-			size_t size, int flags);
+struct dma_buf *dma_buf_export(void *priv, const struct dma_buf_ops *ops,
+			       size_t size, int flags);
 int dma_buf_fd(struct dma_buf *dmabuf);
 struct dma_buf *dma_buf_get(int fd);
 void dma_buf_put(struct dma_buf *dmabuf);
@@ -138,8 +138,8 @@ static inline void dma_buf_detach(struct dma_buf *dmabuf,
 }
 
 static inline struct dma_buf *dma_buf_export(void *priv,
-						struct dma_buf_ops *ops,
-						size_t size, int flags)
+					     const struct dma_buf_ops *ops,
+					     size_t size, int flags)
 {
 	return ERR_PTR(-ENODEV);
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
