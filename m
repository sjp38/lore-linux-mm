Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08AF2280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 04:25:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44so10960699wry.5
        for <linux-mm@kvack.org>; Sun, 21 May 2017 01:25:08 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id w133si8948906wmd.124.2017.05.21.01.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 01:25:07 -0700 (PDT)
Subject: [PATCH 1/3] zswap: Delete an error message for a failed memory
 allocation in zswap_pool_create()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Message-ID: <2345aabc-ae98-1d31-afba-40a02c5baf3d@users.sourceforge.net>
Date: Sun, 21 May 2017 10:25:03 +0200
MIME-Version: 1.0
In-Reply-To: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 May 2017 22:33:21 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zswap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index eedc27894b10..18d8e87119a6 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -518,7 +518,5 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
-	if (!pool) {
-		pr_err("pool alloc failed\n");
+	if (!pool)
 		return NULL;
-	}
 
 	/* unique name for each pool specifically required by zsmalloc */
 	snprintf(name, 38, "zswap%x", atomic_inc_return(&zswap_pools_count));
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
