Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 074186B026D
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:44:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a6-v6so6775373pgt.15
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:44:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f69-v6si19212359plb.503.2018.05.23.07.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:32 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/34] iomap: fix the comment describing IOMAP_NOWAIT
Date: Wed, 23 May 2018 16:43:33 +0200
Message-Id: <20180523144357.18985-11-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/iomap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 8f7095fc514e..13d19b4c29a9 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -59,7 +59,7 @@ struct iomap {
 #define IOMAP_REPORT		(1 << 2) /* report extent status, e.g. FIEMAP */
 #define IOMAP_FAULT		(1 << 3) /* mapping for page fault */
 #define IOMAP_DIRECT		(1 << 4) /* direct I/O */
-#define IOMAP_NOWAIT		(1 << 5) /* Don't wait for writeback */
+#define IOMAP_NOWAIT		(1 << 5) /* do not block */
 
 struct iomap_ops {
 	/*
-- 
2.17.0
