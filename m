Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CDA316B013B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:33:22 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 26 Mar 2013 13:33:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7E23D6E8020
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:33:15 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2QHXE2W285358
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:33:15 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2QHXDeM027980
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:33:13 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] trivial: mmzone: correct "pags" to "pages" in comment.
Date: Tue, 26 Mar 2013 10:30:44 -0700
Message-Id: <1364319045-29973-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c74092e..5c76737 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -450,7 +450,7 @@ struct zone {
 	 *
 	 * present_pages is physical pages existing within the zone, which
 	 * is calculated as:
-	 *	present_pages = spanned_pages - absent_pages(pags in holes);
+	 *	present_pages = spanned_pages - absent_pages(pages in holes);
 	 *
 	 * managed_pages is present pages managed by the buddy system, which
 	 * is calculated as (reserved_pages includes pages allocated by the
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
