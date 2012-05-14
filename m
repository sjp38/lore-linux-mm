Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 17F596B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 12:39:19 -0400 (EDT)
Date: Mon, 14 May 2012 18:39:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
Message-ID: <20120514163916.GD22629@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils>
 <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 13-05-12 22:02:28, Hugh Dickins wrote:
> Take lruvec further: pass it instead of zone to add_page_to_lru_list()
> and del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec
> down to its target functions.
> 
> This cleanup eliminates a swathe of cruft in memcontrol.c,
> including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
> mem_cgroup_lru_move_lists() - which never actually touched the lists.

Yes add_page_to_lru_list vs. mem_cgroup_lru_add_list and del variant
were really confusing.

> In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> previously a side-effect of add, and mem_cgroup_update_lru_size()
> to maintain the lru_size stats.
> 
> Whilst these are simplifications in their own right, the goal is to
> bring the evaluation of lruvec next to the spin_locking of the lrus,
> in preparation for a future patch.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

I like the patch but if Konstantin has a split up version of the same
thing I would rather see that version first.

> ---
> The horror, the horror: I have three lines of 81 columns:
> I do think they look better this way than split up.

Agreed.


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
