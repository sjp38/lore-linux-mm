Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 548B36B0072
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:14 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841575bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:13 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 07/10] mm: frontswap: remove unnecessary check during initialization
Date: Sun, 10 Jun 2012 12:51:05 +0200
Message-Id: <1339325468-30614-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
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
index d8dc986..7c26e89 100644
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
