Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 02CDC6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 05:11:50 -0400 (EDT)
Date: Thu, 22 Mar 2012 10:11:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg-devel updated for v3.3
Message-ID: <20120322091147.GB18665@tiehlicka.suse.cz>
References: <20120321094545.GA10450@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120321094545.GA10450@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Glauber Costa <glommer@parallels.com>

On Wed 21-03-12 10:45:45, Michal Hocko wrote:
[...]
> Hugh Dickins (15):
>       memcg-clear-pc-mem_cgorup-if-necessary-fix-2
>       memcg-clear-pc-mem_cgorup-if-necessary fix 3
>       memcg: fix page migration to reset_owner
>       memcg: replace MEM_CONT by MEM_RES_CTLR
>       memcg: replace mem and mem_cont stragglers
>       memcg: lru_size instead of MEM_CGROUP_ZSTAT
>       memcg: enum lru_list lru
>       memcg: remove redundant returns
>       idr: make idr_get_next() good for rcu_read_lock()
>       cgroup: revert ss_id_lock to spinlock
>       memcg: let css_get_next() rely upon rcu_read_lock()
>       memcg: remove PCG_CACHE page_cgroup flag fix
>       memcg: remove PCG_CACHE page_cgroup flag fix2
>       memcg: remove PCG_FILE_MAPPED fix cosmetic fix
>       memcg: fix GPF when cgroup removal races with last exit

I have just noticed I forgot about one fix.
Hugh Dickins (1):
      memcg: fix deadlock by avoiding stat lock when anon

pushed and sorry

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
