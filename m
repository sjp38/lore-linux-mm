Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76CD06B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:15:37 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o8so4872733wrg.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:15:37 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id c22si3667895wmd.129.2017.08.14.04.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 04:15:36 -0700 (PDT)
Subject: [PATCH 1/2] zpool: Delete an error message for a failed memory
 allocation in zpool_create_pool()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net>
Message-ID: <81cdf225-ebaa-19dc-30d8-80ec6cfab6cd@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:15:34 +0200
MIME-Version: 1.0
In-Reply-To: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Aug 2017 12:57:16 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zpool.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index fd3ff719c32c..fe1943f7d844 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -172,7 +172,6 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 
 	zpool = kmalloc(sizeof(*zpool), gfp);
 	if (!zpool) {
-		pr_err("couldn't create zpool - out of memory\n");
 		zpool_put_driver(driver);
 		return NULL;
 	}
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
