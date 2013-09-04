Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A105B6B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 06:42:57 -0400 (EDT)
Message-ID: <52270E64.20401@huawei.com>
Date: Wed, 4 Sep 2013 18:41:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/driver: use __free_reserved_page() to simplify the
 code
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, james.hogan@imgtec.com, monstr@monstr.eu, benh@kernel.crashing.org, paulus@samba.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, microblaze-uclinux@itee.uq.edu.au, linuxppc-dev@lists.ozlabs.org, linux-fbdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Use __free_reserved_page() to simplify the code in the others.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/video/acornfb.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/video/acornfb.c b/drivers/video/acornfb.c
index 6488a73..4ef302a 100644
--- a/drivers/video/acornfb.c
+++ b/drivers/video/acornfb.c
@@ -1205,9 +1205,7 @@ free_unused_pages(unsigned int virtual_start, unsigned int virtual_end)
 		 * the page.
 		 */
 		page = virt_to_page(virtual_start);
-		ClearPageReserved(page);
-		init_page_count(page);
-		free_page(virtual_start);
+		__free_reserved_page(page);
 
 		virtual_start += PAGE_SIZE;
 		mb_freed += PAGE_SIZE / 1024;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
