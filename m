Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id BA7306B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 05:23:01 -0500 (EST)
Received: by obbww6 with SMTP id ww6so83152790obb.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:23:01 -0800 (PST)
Received: from n9-28.mail.139.com (n9-28.mail.139.com. [221.176.9.28])
        by mx.google.com with ESMTP id ku5si9236557obb.18.2015.11.20.02.22.59
        for <linux-mm@kvack.org>;
        Fri, 20 Nov 2015 02:23:00 -0800 (PST)
From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Subject: [PATCH] writeback: fix build warning about may be used uninitialized params
Date: Fri, 20 Nov 2015 18:22:22 +0800
Message-Id: <1448014942-10245-1-git-send-email-lixiubo@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: lixiubo <lixiubo@cmss.chinamobile.com>

From: lixiubo <lixiubo@cmss.chinamobile.com>

warning: a??m_thresha?? may be used uninitialized in this function
[-Wmaybe-uninitialized]
 warning: a??m_dirtya?? may be used uninitialized in this function
[-Wmaybe-uninitialized]

This may introduce some rask.

Signed-off-by: lixiubo <lixiubo@cmss.chinamobile.com>
---
 mm/page-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2c90357..01ad30f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	for (;;) {
 		unsigned long now = jiffies;
 		unsigned long dirty, thresh, bg_thresh;
-		unsigned long m_dirty, m_thresh, m_bg_thresh;
+		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh;
 
 		/*
 		 * Unstable writes are a feature of certain networked
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
