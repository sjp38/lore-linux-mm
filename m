Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B45116B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:05:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so21316141pgj.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 07:05:50 -0800 (PST)
Received: from smtpbgsg2.qq.com (smtpbgsg2.qq.com. [54.254.200.128])
        by mx.google.com with ESMTPS id 3si11992151pgi.256.2017.01.25.07.05.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 07:05:49 -0800 (PST)
From: ysxie@foxmail.com
Subject: [PATCH v4 1/2] mm/migration: make isolate_movable_page always defined
Date: Wed, 25 Jan 2017 23:05:37 +0800
Message-Id: <1485356738-4831-2-git-send-email-ysxie@foxmail.com>
In-Reply-To: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

Define isolate_movable_page as a static inline function when
CONFIG_MIGRATION is not enable. It should return false
here which means failed to isolate movable pages.

This patch do not have any functional change but prepare for
later patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/migrate.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..631a8c8 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
 		int reason)
 	{ return -ENOSYS; }
+static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+	{ return false; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
