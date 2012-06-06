Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D944F6B0096
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:32 -0400 (EDT)
Received: by yenm7 with SMTP id m7so6317178yen.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:32 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 07/11] mm: frontswap: remove unnecessary check during initialization
Date: Wed,  6 Jun 2012 12:55:11 +0200
Message-Id: <1338980115-2394-7-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index f2f4685..bf99c7d 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -89,8 +89,7 @@ void __frontswap_init(unsigned type)
 	BUG_ON(sis == NULL);
 	if (sis->frontswap_map == NULL)
 		return;
-	if (frontswap_enabled)
-		frontswap_ops.init(type);
+	frontswap_ops.init(type);
 }
 EXPORT_SYMBOL(__frontswap_init);
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
