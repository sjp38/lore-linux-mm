Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 2BE886B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:17:16 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1208774pbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 23:17:15 -0700 (PDT)
Date: Thu, 31 May 2012 06:17:07 +0800
From: baozich <baozich@gmail.com>
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
Message-ID: <20120530221707.GA25095@centos-guest>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils>
 <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,
On Sun, May 13, 2012 at 10:02:28PM -0700, Hugh Dickins wrote:
> Take lruvec further: pass it instead of zone to add_page_to_lru_list()
> and del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec
> down to its target functions.
> 
> This cleanup eliminates a swathe of cruft in memcontrol.c,
> including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
> mem_cgroup_lru_move_lists() - which never actually touched the lists.
> 
> In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> previously a side-effect of add, and mem_cgroup_update_lru_size()
> to maintain the lru_size stats.
I have a stupid question. I'm not sure whether there is reduplication
to put both "page" and "zone" parameter in mem_cgroup_page_lruvec(),
for I noticed that the "struct zone *zone" parameter are usually from 
page_zone(page) in most cases. I think that the semantics of this function
is to grab the lruvec the page belongs to. So will it be ok if we pass
only "page" as the parameter, which I think would be cleaner? Please
fix me if I missed something.

Thanks

Baozi
> 
> Whilst these are simplifications in their own right, the goal is to
> bring the evaluation of lruvec next to the spin_locking of the lrus,
> in preparation for a future patch.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
