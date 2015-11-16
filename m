Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E6C5E6B0258
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:46 -0500 (EST)
Received: by padhx2 with SMTP id hx2so165579389pad.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:46 -0800 (PST)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id fy6si17666349pbd.163.2015.11.15.22.52.45
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:46 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 6/7] mm/gfp: make gfp_zonelist return directly and bool
Date: Mon, 16 Nov 2015 14:51:25 +0800
Message-Id: <1447656686-4851-7-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes gfp_zonelist return bool due to this
particular function only using either one or zero as its return
value.

This patch also makes gfp_zonelist return directly by removing if.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/gfp.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6523109..1da03f5 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -375,12 +375,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
  * virtual kernel addresses to the allocated page(s).
  */
 
-static inline int gfp_zonelist(gfp_t flags)
+static inline bool gfp_zonelist(gfp_t flags)
 {
-	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
-		return 1;
-
-	return 0;
+	return IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE);
 }
 
 /*
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
