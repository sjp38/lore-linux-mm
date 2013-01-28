Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3BD236B000D
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 05:54:55 -0500 (EST)
Message-ID: <510658F6.4010504@oracle.com>
Date: Mon, 28 Jan 2013 18:54:46 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH v2 4/6] memcg: export nr_swap_files
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

Export nr_swap_files which would be used for initializing and destorying
swap cgroup structures in the coming patch.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Sha Zhengju <handai.szj@taobao.com>

---
 include/linux/swap.h |    1 +
 mm/swapfile.c        |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..6de44c9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -348,6 +348,7 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 /* linux/mm/swapfile.c */
 extern long nr_swap_pages;
 extern long total_swap_pages;
+extern unsigned int nr_swapfiles;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index e97a0e5..89cebcf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -46,7 +46,7 @@ static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
 DEFINE_SPINLOCK(swap_lock);
-static unsigned int nr_swapfiles;
+unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
 static int least_priority;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
