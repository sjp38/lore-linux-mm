Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3776B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 06:00:36 -0400 (EDT)
Date: Thu, 2 Jun 2011 12:00:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110602100007.GB20725@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
 <20110602073335.GA20630@cmpxchg.org>
 <BANLkTikztP6RoyBgMqUHgrzJFLZrHMCs=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikztP6RoyBgMqUHgrzJFLZrHMCs=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 06:06:51PM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/2 Johannes Weiner <hannes@cmpxchg.org>:
> > On Thu, Jun 02, 2011 at 08:52:47AM +0900, Hiroyuki Kamezawa wrote:
> >> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> >
> > The patch series is not a performance optimization.  But I can include
> > it to prove there are no regressions.
> >
> yes, it's helpful.

Okay.

> >>   Hmm, how about splitting patch 2/8 into small patches and see what happens in
> >>   3.2 or 3.3 ? While that, we can make softlimit works better.
> >>   (and once we do 2/8, our direction will be fixed to the direction to
> >> remove global LRU.)
> >
> > Do you have specific parts in mind that could go stand-alone?
> >
> > One thing I can think of is splitting up those parts:
> >
> >  1. move /target/ reclaim to generic code
> >
> >  2. convert /global/ reclaim from global lru to hierarchy reclaim
> >     including root_mem_cgroup
> 
> Hmm, at brief look
> patch 2/8
>  - hierarchy walk rewrite code should be stand alone and can be merged
> 1st, as clean-up

You mean introducing mem_cgroup_hierarchy_walk() and make use of it in
mem_cgroup_hierarchical_reclaim() as a first step?

>  - root cgroup LRU handling was required for performance. I think we
> removed tons of
>   atomic ops and can remove that special handling personally. But this change of
>   root cgroup handling should be in separate patch. with performance report.

I disagree.

With view on the whole patch series, linking ungrouped process pages
to the root_mem_cgroup is traded against

   1. linking ungrouped process pages to the global LRU

   2. linking grouped process pages to both the global LRU and the
      memcg LRU

The comparison you propose is neither fair nor relevant because it
would never make sense to merge that patch without the others.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
