Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 483476B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:43:39 -0400 (EDT)
Received: by obbda8 with SMTP id da8so81960935obb.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:43:39 -0700 (PDT)
Received: from m12-17.163.com (m12-17.163.com. [220.181.12.17])
        by mx.google.com with ESMTP id w5si12069607obs.44.2015.09.21.06.42.49
        for <linux-mm@kvack.org>;
        Mon, 21 Sep 2015 06:43:38 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 2/2] mm/memcontrol: make mem_cgroup_inactive_anon_is_low return bool
Date: Mon, 21 Sep 2015 21:37:53 +0800
Message-Id: <1442842673-4140-2-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1442842673-4140-1-git-send-email-bywxiaobai@163.com>
References: <1442842673-4140-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, tj@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes mem_cgroup_inactive_anon_is_low return bool due to
this particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/memcontrol.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ad800e6..91a6bf3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -383,7 +383,7 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 	return mz->lru_size[lru];
 }
 
-static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
+static inline bool mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	unsigned long inactive_ratio;
 	unsigned long inactive;
@@ -584,10 +584,10 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
-static inline int
+static inline bool
 mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
-	return 1;
+	return true;
 }
 
 static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
