Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 686DC6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 04:47:10 -0500 (EST)
Date: Mon, 16 Jan 2012 10:47:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/5] memcg: trivial cleanups
Message-ID: <20120116094707.GB1639@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
 <20120109130259.GD3588@cmpxchg.org>
 <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

On Sat 14-01-12 16:07:42, Hugh Dickins wrote:
> On Mon, 9 Jan 2012, Johannes Weiner wrote:
> > On Sat, Dec 31, 2011 at 11:26:42PM -0800, Hugh Dickins wrote:
> > > Obviously I've missed the boat for per-memcg per-zone LRU locking in 3.3,
> > > but I've split out a shameless bunch of trivial cleanups from that work,
> > > and hoping these might still sneak in unless they're controversial.
> > > 
> > > Following on from my earlier mmotm/next patches, here's five
> > > to memcontrol.c and .h, followed by six to the rest of mm.
> > > 
> > > [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
> > > [PATCH 2/5] memcg: replace mem and mem_cont stragglers
> > > [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
> > > [PATCH 4/5] memcg: enum lru_list lru
> > > [PATCH 5/5] memcg: remove redundant returns
> > 
> > No objections from my side wrt putting them into 3.3.
> > 
> > Thanks!
> 
> I was hoping that these five memcg trivia (and my two SHM_UNLOCK fixes)
> were on their way into 3.3, but they've not yet shown up in mm-commits.
> 
> I'll resend them all again now: I've not rediffed, since they apply
> (if at different offsets) to Linus's current git tree; but I have added
> in the (somewhat disproportionate for trivia!) Acked-bys and Reviewed-bys.
> 
> Michal was not happy with 3/5: I've summarized below the --- on that one,
> do with it as you wish - I think neither Michal nor I shall slam the door
> and burst into tears if you decide against one of us.

Yes, please go on with the patch. I will not lose any sleep over
MEM_CGROUP_ZSTAT ;)
As both Kame and Johannes acked that, there is no need to discuss that
more.

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
