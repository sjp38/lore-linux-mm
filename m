Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 48CF66B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:14:17 -0400 (EDT)
Date: Tue, 17 May 2011 02:13:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
Message-ID: <20110517001318.GX16531@cmpxchg.org>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
 <20110516231512.GW16531@cmpxchg.org>
 <BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon, May 16, 2011 at 05:05:02PM -0700, Ying Han wrote:
> On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
> > > This fixes the typo in the memory.stat including the following two
> > > stats:
> > >
> > > $ cat /dev/cgroup/memory/A/memory.stat
> > > total_soft_steal 0
> > > total_soft_scan 0
> > >
> > > And change it to:
> > >
> > > $ cat /dev/cgroup/memory/A/memory.stat
> > > total_soft_kswapd_steal 0
> > > total_soft_kswapd_scan 0
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > I am currently proposing and working on a scheme that makes the soft
> > limit not only a factor for global memory pressure, but for
> > hierarchical reclaim in general, to prefer child memcgs during reclaim
> > that are in excess of their soft limit.
> >
> > Because this means prioritizing memcgs over one another, rather than
> > having explicit soft limit reclaim runs, there is no natural counter
> > for pages reclaimed due to the soft limit anymore.
> >
> > Thus, for the patch that introduces this counter:
> >
> > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
> >
> 
> This patch is fixing a typo of the stats being integrated into mmotm. Does
> it make sense to fix the
> existing stats first while we are discussing other approaches?

I think it would make sense to not introduce user-facing stats while
we are discussing approaches that would not be able to maintain them.

I am fine with them being in -mmotm (and receiving fixes), but would
prefer not having them merged into .40.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
