Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D2B476B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 19:07:56 -0500 (EST)
Received: by iafj26 with SMTP id j26so8429609iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 16:07:56 -0800 (PST)
Date: Sat, 14 Jan 2012 16:07:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/5] memcg: trivial cleanups
In-Reply-To: <20120109130259.GD3588@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <20120109130259.GD3588@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

On Mon, 9 Jan 2012, Johannes Weiner wrote:
> On Sat, Dec 31, 2011 at 11:26:42PM -0800, Hugh Dickins wrote:
> > Obviously I've missed the boat for per-memcg per-zone LRU locking in 3.3,
> > but I've split out a shameless bunch of trivial cleanups from that work,
> > and hoping these might still sneak in unless they're controversial.
> > 
> > Following on from my earlier mmotm/next patches, here's five
> > to memcontrol.c and .h, followed by six to the rest of mm.
> > 
> > [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
> > [PATCH 2/5] memcg: replace mem and mem_cont stragglers
> > [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
> > [PATCH 4/5] memcg: enum lru_list lru
> > [PATCH 5/5] memcg: remove redundant returns
> 
> No objections from my side wrt putting them into 3.3.
> 
> Thanks!

I was hoping that these five memcg trivia (and my two SHM_UNLOCK fixes)
were on their way into 3.3, but they've not yet shown up in mm-commits.

I'll resend them all again now: I've not rediffed, since they apply
(if at different offsets) to Linus's current git tree; but I have added
in the (somewhat disproportionate for trivia!) Acked-bys and Reviewed-bys.

Michal was not happy with 3/5: I've summarized below the --- on that one,
do with it as you wish - I think neither Michal nor I shall slam the door
and burst into tears if you decide against one of us.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
