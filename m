Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7B6900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 03:21:14 -0400 (EDT)
Date: Fri, 13 May 2011 09:20:57 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
Message-ID: <20110513072043.GE18610@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:
> On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Hi!
> >
> > Here is a patch series that is a result of the memcg discussions on
> > LSF (memcg-aware global reclaim, global lru removal, struct
> > page_cgroup reduction, soft limit implementation) and the recent
> > feature discussions on linux-mm.
> >
> > The long-term idea is to have memcgs no longer bolted to the side of
> > the mm code, but integrate it as much as possible such that there is a
> > native understanding of containers, and that the traditional !memcg
> > setup is just a singular group.  This series is an approach in that
> > direction.
> >
> > It is a rather early snapshot, WIP, barely tested etc., but I wanted
> > to get your opinions before further pursuing it.  It is also part of
> > my counter-argument to the proposals of adding memcg-reclaim-related
> > user interfaces at this point in time, so I wanted to push this out
> > the door before things are merged into .40.
> >
> 
> The memcg-reclaim-related user interface I assume was the watermark
> configurable tunable we were talking about in the per-memcg
> background reclaim patch. I think we got some agreement to remove
> the watermark tunable at the first step. But the newly added
> memory.soft_limit_async_reclaim as you proposed seems to be a usable
> interface.

Actually, I meant the soft limit reclaim statistics.  There is a
comment about that in the 6/6 changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
