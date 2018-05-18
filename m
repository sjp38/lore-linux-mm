Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCD966B060A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:49:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q15-v6so5030260pff.17
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:49:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 61-v6si7512444plc.173.2018.05.18.09.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:49:03 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/34] iomap: fix the comment describing IOMAP_NOWAIT
Date: Fri, 18 May 2018 18:48:06 +0200
Message-Id: <20180518164830.1552-11-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

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
