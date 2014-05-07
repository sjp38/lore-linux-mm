Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4566B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:43:20 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so647412pdj.38
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:43:19 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0240.outbound.protection.outlook.com. [207.46.163.240])
        by mx.google.com with ESMTPS id qf5si13235894pac.334.2014.05.06.23.43.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 May 2014 23:43:18 -0700 (PDT)
From: Xiubo Li <Li.Xiubo@freescale.com>
Subject: [PATCH] mm, highmem: clean up the comment
Date: Wed, 7 May 2014 13:57:45 +0800
Message-ID: <1399442265-22421-1-git-send-email-Li.Xiubo@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Xiubo Li <Li.Xiubo@freescale.com>

Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
---
 mm/highmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index b32b70c..d062c89 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -421,4 +421,4 @@ void __init page_address_init(void)
 	}
 }
 
-#endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
+#endif	/* defined(CONFIG_HIGHMEM) */
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
