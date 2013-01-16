Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 7BF776B0078
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:08 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:26:07 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 343E938C8051
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:50 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0Pn8W298458
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PngG006910
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:49 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 11/17] mm/kmemleak: use node_{start,end}_pfn()
Date: Tue, 15 Jan 2013 16:24:48 -0800
Message-Id: <1358295894-24167-12-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Instead of open coding, use the exsisting node_start_pfn() and
node_end_pfn() helpers.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/kmemleak.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 752a705..83dd5fb 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1300,9 +1300,8 @@ static void kmemleak_scan(void)
 	 */
 	lock_memory_hotplug();
 	for_each_online_node(i) {
-		pg_data_t *pgdat = NODE_DATA(i);
-		unsigned long start_pfn = pgdat->node_start_pfn;
-		unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
+		unsigned long start_pfn = node_start_pfn(i);
+		unsigned long end_pfn = node_end_pfn(i);
 		unsigned long pfn;
 
 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
