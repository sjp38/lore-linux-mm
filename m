Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF73A8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:00:48 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so8953604pgb.7
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:00:48 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id e13si17975332pfi.271.2019.01.11.11.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 11:00:47 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: swap: use mem_cgroup_is_root() instead of deferencing css->parent
Date: Sat, 12 Jan 2019 02:55:13 +0800
Message-Id: <1547232913-118148-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com, tim.c.chen@intel.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_is_root() is preferred API to check if memcg is root or not.
Use it instead of deferencing css->parent.

Cc: Huang Ying <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/swap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a8f6d5d..8739063 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -623,7 +623,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 		return vm_swappiness;
 
 	/* root ? */
-	if (mem_cgroup_disabled() || !memcg->css.parent)
+	if (mem_cgroup_disabled() || mem_cgroup_is_root(memcg))
 		return vm_swappiness;
 
 	return memcg->swappiness;
-- 
1.8.3.1
