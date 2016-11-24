Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85D366B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 11:32:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so16026781wmf.3
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 08:32:05 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id h17si37802759wjq.274.2016.11.24.08.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 08:32:04 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] z3fold: use %z modifier for format string
Date: Thu, 24 Nov 2016 17:31:33 +0100
Message-Id: <20161124163158.3939337-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Vitaly Wool <vitalywool@gmail.com>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Printing a size_t requires the %zd format rather than %d:

mm/z3fold.c: In function a??init_z3folda??:
include/linux/kern_levels.h:4:18: error: format a??%da?? expects argument of type a??inta??, but argument 2 has type a??long unsigned inta?? [-Werror=format=]

Fixes: 50a50d2676c4 ("z3fold: don't fail kernel build if z3fold_header is too big")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/z3fold.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e282ba073e77..66ac7a7dc934 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -884,7 +884,7 @@ static int __init init_z3fold(void)
 {
 	/* Fail the initialization if z3fold header won't fit in one chunk */
 	if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
-		pr_err("z3fold: z3fold_header size (%d) is bigger than "
+		pr_err("z3fold: z3fold_header size (%zd) is bigger than "
 			"the chunk size (%d), can't proceed\n",
 			sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
 		return -E2BIG;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
