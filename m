Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0049E6B000A
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:12:03 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id h33so11466398plh.19
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:12:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f10si2257717pgn.762.2018.02.14.12.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:12:01 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 4/8] Convert dax device to kvzalloc_struct
Date: Wed, 14 Feb 2018 12:11:50 -0800
Message-Id: <20180214201154.10186-5-willy@infradead.org>
In-Reply-To: <20180214201154.10186-1-willy@infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Joe Perches <joe@perches.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/dax/device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 2137dbc29877..5821cde340f6 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -586,7 +586,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	if (!count)
 		return ERR_PTR(-EINVAL);
 
-	dev_dax = kzalloc(sizeof(*dev_dax) + sizeof(*res) * count, GFP_KERNEL);
+	dev_dax = kvzalloc_struct(dev_dax, res, count, GFP_KERNEL);
 	if (!dev_dax)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
