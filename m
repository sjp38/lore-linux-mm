Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0FB9F6B007D
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:14:58 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so3738633obb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:14:57 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 07/10] mm: frontswap: remove unnecessary check during initialization
Date: Fri,  8 Jun 2012 21:15:16 +0200
Message-Id: <1339182919-11432-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

The check whether frontswap is enabled or not is done in the API functions in
the frontswap header, before they are passed to the internal
double-underscored frontswap functions.

Remove the check from __frontswap_init for consistency.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index ee1763d..0319fc5 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -110,8 +110,7 @@ void __frontswap_init(unsigned type)
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
