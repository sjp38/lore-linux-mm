Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 1794A6B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 06:56:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 19 Oct 2012 20:53:40 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9JAklc231916234
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 21:46:47 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9JAucIV031883
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 21:56:39 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] mm: Simplify for_each_populated_zone()
Date: Fri, 19 Oct 2012 16:25:47 +0530
Message-ID: <20121019105546.9704.93446.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kosaki.motohiro@gmail.com, akpm@linux-foundation.org, hannes@cmpxchg.org, srivatsa.bhat@linux.vnet.ibm.com

Move the check for populated_zone() to the control statement of the
'for' loop and get rid of the odd looking if/else block.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 50aaca8..5bdf02e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -913,11 +913,8 @@ extern struct zone *next_zone(struct zone *zone);
 
 #define for_each_populated_zone(zone)		        \
 	for (zone = (first_online_pgdat())->node_zones; \
-	     zone;					\
-	     zone = next_zone(zone))			\
-		if (!populated_zone(zone))		\
-			; /* do nothing */		\
-		else
+	     zone && populated_zone(zone);		\
+	     zone = next_zone(zone))
 
 static inline struct zone *zonelist_zone(struct zoneref *zoneref)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
