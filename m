Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 029776B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:57:28 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so5544941plv.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:57:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a29-v6si11260712pgn.423.2018.06.07.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 07:57:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 4/6] Convert vhost to struct_size
Date: Thu,  7 Jun 2018 07:57:18 -0700
Message-Id: <20180607145720.22590-5-willy@infradead.org>
In-Reply-To: <20180607145720.22590-1-willy@infradead.org>
References: <20180607145720.22590-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/vhost/vhost.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 895eaa25807c..f9bce818da11 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1286,7 +1286,8 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EOPNOTSUPP;
 	if (mem.nregions > max_mem_regions)
 		return -E2BIG;
-	newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
+	newmem = kvzalloc(struct_size(newmem, regions, mem.nregions),
+			GFP_KERNEL);
 	if (!newmem)
 		return -ENOMEM;
 
-- 
2.17.0
