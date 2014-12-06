Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id AC9C36B0032
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 11:43:17 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so1327380wid.9
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 08:43:17 -0800 (PST)
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id p16si2569722wiw.104.2014.12.06.08.43.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 08:43:16 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id l2so3172194wgh.13
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 08:43:16 -0800 (PST)
From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] mm: memcontrol.c:  Cleaning up function that are not used anywhere
Date: Sat,  6 Dec 2014 17:45:56 +0100
Message-Id: <1417884356-3086-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.
And move BUILD_BUG_ON() to the beginning of memcg_stat_show() instead.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 mm/memcontrol.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d6ac0e3..5e2f0f3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4379,17 +4379,14 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
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
 	struct mem_cgroup *mi;
 	unsigned int i;
 
+	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
+
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
