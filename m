Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8665C6B025E
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 08:18:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so509068672pfa.3
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 05:18:08 -0800 (PST)
Received: from smtpbg337.qq.com (smtpbg337.qq.com. [14.17.44.32])
        by mx.google.com with ESMTPS id v128si11214124pgv.72.2017.01.31.05.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 05:18:07 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v5 2/4] mm/migration: make isolate_movable_page always defined
Date: Tue, 31 Jan 2017 21:06:19 +0800
Message-Id: <1485867981-16037-3-git-send-email-ysxie@foxmail.com>
In-Reply-To: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
References: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

Define isolate_movable_page as a static inline function when
CONFIG_MIGRATION is not enable. It should return -EBUSY
here which means failed to isolate movable pages.

This patch do not have any functional change but prepare for
later patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/migrate.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 43d5deb..fa76b51 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
 		int reason)
 	{ return -ENOSYS; }
+static inline int isolate_movable_page(struct page *page, isolate_mode_t mode)
+	{ return -EBUSY; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
