Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 40C3C6B004A
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 23:19:22 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1625629iaj.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 20:19:21 -0700 (PDT)
Date: Wed, 4 Apr 2012 20:19:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] memcg swap: use mem_cgroup_uncharge_swap fix
In-Reply-To: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
Message-ID: <alpine.DEB.2.00.1204042017520.8789@chino.kir.corp.google.com>
References: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

linux-next fails with this 

mm/memcontrol.c: In function '__mem_cgroup_commit_charge_swapin':
mm/memcontrol.c:2837: error: implicit declaration of function 'mem_cgroup_uncharge_swap'

if CONFIG_SWAP is disabled.  Fix it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/swap.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -529,6 +529,10 @@ static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
 {
 }
 
+static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
+{
+}
+
 static inline void disable_swap_token(struct mem_cgroup *memcg)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
