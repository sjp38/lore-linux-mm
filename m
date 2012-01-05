Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 35F316B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 07:18:00 -0500 (EST)
Date: Thu, 5 Jan 2012 13:17:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: memcg-devel git tree updated to 3.2
Message-ID: <20120105121755.GA4628@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hi,
JFYI I have just created since-3.2 branch and rebased all pending
patches on top of 3.2 for the next development cycle. Let me know if I
missed some changes (Hugh - I will push your late patches soonish)

The shortlog since v3.2 says:
Andrew Morton (6):
      mm-vmscan-distinguish-between-memcg-triggering-reclaim-and-memcg-being-scanned-checkpatch-fixes
      memcg-make-mem_cgroup_split_huge_fixup-more-efficient-fix
      memcg-clear-pc-mem_cgorup-if-necessary-fix
      memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
      memcg-simplify-lru-handling-by-new-rule-fix
      memcg-simplify-lru-handling-by-new-rule-memcg-return-eintr-at-bypassing-try_charge-fix

Bob Liu (5):
      page_cgroup: add helper function to get swap_cgroup
      page_cgroup: cleanup lookup_swap_cgroup()
      memcg: cleanup for_each_node_state()
      page_alloc: break early in check_for_regular_memory()
      page_cgroup: drop multi CONFIG_MEMORY_HOTPLUG

David Rientjes (1):
      oom, memcg: fix exclusion of memcg threads after they have detached their mm

Hugh Dickins (4):
      mm: memcg: remove unused node/section info from pc->flags fix
      memcg-clear-pc-mem_cgorup-if-necessary-fix-2
      memcg-clear-pc-mem_cgorup-if-necessary fix 3
      mm-memcg-lookup_page_cgroup-almost-never-returns-null fix

Johannes Weiner (19):
      mm: memcg: consolidate hierarchy iteration primitives
      mm: vmscan: distinguish global reclaim from global LRU scanning
      mm: vmscan: distinguish between memcg triggering reclaim and memcg being scanned
      mm: memcg: per-priority per-zone hierarchy scan generations
      mm: move memcg hierarchy reclaim to generic reclaim code
      mm: memcg: remove optimization of keeping the root_mem_cgroup LRU lists empty
      mm: vmscan: convert global reclaim to per-memcg LRU lists
      mm: collect LRU list heads into struct lruvec
      mm: make per-memcg LRU lists exclusive
      mm: memcg: remove unused node/section info from pc->flags
      mm: memcg: shorten preempt-disabled section around event checks
      mm: oom_kill: remove memcg argument from oom_kill_task()
      mm: unify remaining mem_cont, mem, etc. variable names to memcg
      mm: memcg: clean up fault accounting
      mm: memcg: lookup_page_cgroup (almost) never returns NULL
      mm: page_cgroup: check page_cgroup arrays in lookup_page_cgroup() only when necessary
      mm: memcg: remove unneeded checks from newpage_charge()
      mm: memcg: remove unneeded checks from uncharge_page()
      memcg-clear-pc-mem_cgorup-if-necessary-comments

KAMEZAWA Hiroyuki (7):
      memcg: make mem_cgroup_split_huge_fixup() more efficient
      memcg: add mem_cgroup_replace_page_cache() to fix LRU issue
      memcg: simplify page cache charging
      memcg: simplify corner case handling of LRU.
      memcg: clear pc->mem_cgorup if necessary.
      memcg: simplify LRU handling by new rule
      memcg: return -EINTR at bypassing try_charge()

Michal Hocko (1):
      memcg: free entries in soft_limit_tree if allocation fails

Happy development.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
