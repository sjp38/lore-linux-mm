Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 318886B004D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 14:43:42 -0500 (EST)
Received: by iacb35 with SMTP id b35so35779525iac.14
        for <linux-mm@kvack.org>; Mon, 02 Jan 2012 11:43:41 -0800 (PST)
Date: Mon, 2 Jan 2012 11:43:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
In-Reply-To: <20120102125913.GG7910@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1201021104160.1854@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <alpine.LSU.2.00.1112312329240.18500@eggly.anvils> <20120102125913.GG7910@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Mon, 2 Jan 2012, Michal Hocko wrote:
> On Sat 31-12-11 23:30:38, Hugh Dickins wrote:
> > I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
> > to obscure the LRU counts.  For easier searching?  So call it
> > lru_size rather than bare count (lru_length sounds better, but
> > would be wrong, since each huge page raises lru_size hugely).
> 
> lru_size is unique at the global scope at the moment but this might
> change in the future. MEM_CGROUP_ZSTAT should be unique and so easier
> to grep or cscope. 
> On the other hand lru_size sounds like a better name so I am all for
> renaming but we should make sure that we somehow get memcg into it
> (either to macro MEM_CGROUP_LRU_SIZE or get rid of macro and have
> memcg_lru_size field name - which is ugly long).

I do disagree.  You're asking to introduce artificial differences,
whereas generally we're trying to minimize the differences between
global and memcg.

I'm happy with the way mem_cgroup_zone_lruvec(), for example, returns
a pointer to the relevant structure, whether it's global or per-memcg,
and we then work with the contents of that structure, whichever it is:
lruvec in each case, not global_lruvec in one case and memcg_lruvec
in the other.

And certainly not GLOBAL_ZLRUVEC or MEM_CGROUP_ZLRUVEC!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
