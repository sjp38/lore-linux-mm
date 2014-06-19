Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AB15A6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 18:32:19 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so2337689pab.8
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 15:32:19 -0700 (PDT)
Received: from mail-pa0-x24a.google.com (mail-pa0-x24a.google.com [2607:f8b0:400e:c03::24a])
        by mx.google.com with ESMTPS id qz9si7371720pab.152.2014.06.19.15.32.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 15:32:18 -0700 (PDT)
Received: by mail-pa0-f74.google.com with SMTP id lj1so361302pab.3
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 15:32:18 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: remove lookup_cgroup_page() prototype
Date: Thu, 19 Jun 2014 15:32:16 -0700
Message-Id: <1403217136-4863-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

6b208e3f6e35 ("mm: memcg: remove unused node/section info from
pc->flags") deleted the lookup_cgroup_page() function but left a
prototype for it.

Kill the vestigial prototype.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/page_cgroup.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 777a524716db..0ff470de3c12 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -42,7 +42,6 @@ static inline void __init page_cgroup_init(void)
 #endif
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
-struct page *lookup_cgroup_page(struct page_cgroup *pc);
 
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
