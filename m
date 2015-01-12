Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 738446B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 13:54:29 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id at20so26932889iec.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 10:54:29 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id f11si5035616igo.12.2015.01.12.10.54.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 10:54:28 -0800 (PST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so26877493iec.10
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 10:54:27 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: add BUILD_BUG_ON() for string tables
Date: Mon, 12 Jan 2015 10:54:23 -0800
Message-Id: <1421088863-14270-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Use BUILD_BUG_ON() to compile assert that memcg string tables are in
sync with corresponding enums.  There aren't currently any issues with
these tables.  This is just defensive.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e856c7e4..8d1ca6c55480 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3699,6 +3699,10 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	struct mem_cgroup *mi;
 	unsigned int i;
 
+	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_stat_names) !=
+		     MEM_CGROUP_STAT_NSTATS);
+	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_events_names) !=
+		     MEM_CGROUP_EVENTS_NSTATS);
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
