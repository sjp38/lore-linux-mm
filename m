Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 014676B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 16:59:47 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so5906467wes.12
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 13:59:47 -0700 (PDT)
Received: from mailrelay005.isp.belgacom.be (mailrelay005.isp.belgacom.be. [195.238.6.171])
        by mx.google.com with ESMTP id bj1si192746wib.51.2014.06.27.13.59.45
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 13:59:46 -0700 (PDT)
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] mm/hwpoison-inject.c: remove unnecessary null test before debugfs_remove_recursive
Date: Fri, 27 Jun 2014 22:58:16 +0200
Message-Id: <1403902696-12162-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

Fix checkpatch warning:
"WARNING: debugfs_remove_recursive(NULL) is safe this check is probably not required"

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 mm/hwpoison-inject.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 95487c7..329caf5 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -72,8 +72,7 @@ DEFINE_SIMPLE_ATTRIBUTE(unpoison_fops, NULL, hwpoison_unpoison, "%lli\n");
 
 static void pfn_inject_exit(void)
 {
-	if (hwpoison_dir)
-		debugfs_remove_recursive(hwpoison_dir);
+	debugfs_remove_recursive(hwpoison_dir);
 }
 
 static int pfn_inject_init(void)
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
