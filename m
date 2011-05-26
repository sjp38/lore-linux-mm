Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0336B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 05:06:23 -0400 (EDT)
Date: Thu, 26 May 2011 11:05:38 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
Message-ID: <20110526090538.GA19082@cmpxchg.org>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
 <20110516231512.GW16531@cmpxchg.org>
 <BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
 <20110516171820.124a8fbc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110516171820.124a8fbc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon, May 16, 2011 at 05:18:20PM -0700, Andrew Morton wrote:
> On Mon, 16 May 2011 17:05:02 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
> > > > This fixes the typo in the memory.stat including the following two
> > > > stats:
> > > >
> > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > total_soft_steal 0
> > > > total_soft_scan 0
> > > >
> > > > And change it to:
> > > >
> > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > total_soft_kswapd_steal 0
> > > > total_soft_kswapd_scan 0
> > > >
> > > > Signed-off-by: Ying Han <yinghan@google.com>
> > >
> > > I am currently proposing and working on a scheme that makes the soft
> > > limit not only a factor for global memory pressure, but for
> > > hierarchical reclaim in general, to prefer child memcgs during reclaim
> > > that are in excess of their soft limit.
> > >
> > > Because this means prioritizing memcgs over one another, rather than
> > > having explicit soft limit reclaim runs, there is no natural counter
> > > for pages reclaimed due to the soft limit anymore.
> > >
> > > Thus, for the patch that introduces this counter:
> > >
> > > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
> > >
> > 
> > This patch is fixing a typo of the stats being integrated into mmotm. Does
> > it make sense to fix the
> > existing stats first while we are discussing other approaches?
> > 
> 
> It would be quite bad to add new userspace-visible stats and to then
> take them away again.
> 
> But given that memcg-add-stats-to-monitor-soft_limit-reclaim.patch is
> queued for 2.6.39-rc1, we could proceed with that plan and then make
> sure that Johannes's changes are merged either prior to 2.6.40 or
> they are never merged at all.

I am on it, but I don't think I can get them into shape and
rudimentally benchmarked until the merge window is closed.

So far I found nothing that would invalidate the design or have
measurable impact on non-memcg systems.  Then again, I suck at
constructing tests, and have only limited machinery available.

If people are interested and would like to help out verifying the
changes, I can send an updated and documented version of the series
that should be easier to understand.

> Or we could just leave out the stats until we're sure.  Not having them
> for a while is not as bad as adding them and then removing them.

I am a bit unsure as to why there is a sudden rush with those
statistics now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
