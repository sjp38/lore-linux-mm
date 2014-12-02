Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id F1D786B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 17:38:45 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so29653143wiw.14
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 14:38:45 -0800 (PST)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id jh3si38198961wid.46.2014.12.02.14.38.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 14:38:45 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so22595684wid.0
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 14:38:45 -0800 (PST)
From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] mm: memcontrol.c:  Cleaning up function that are not used anywhere
Date: Tue,  2 Dec 2014 23:41:23 +0100
Message-Id: <1417560083-27157-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 mm/memcontrol.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d6ac0e3..5edd1fe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4379,11 +4379,6 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 }
 #endif /* CONFIG_NUMA */
 
-static inline void mem_cgroup_lru_names_not_uptodate(void)
-{
-	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
-}
-
 static int memcg_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
