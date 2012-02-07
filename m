Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C1A226B13F6
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:22:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ECD2E3EE0AE
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:22:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D51BC45DE61
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:22:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B435645DD74
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:22:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A74AE1DB803A
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:22:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 538BC1DB802C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 09:22:41 +0900 (JST)
Date: Tue, 7 Feb 2012 09:21:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
Message-Id: <20120207092120.c79d8b73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4izp7tV5t5k5e3RwaXHi_-z8NQ2G-0RwFy0cYrRtq1ry+w@mail.gmail.com>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203161140.GC13461@tiehlicka.suse.cz>
	<CALWz4iz48O2TcGOFaGw1_FyhzJ_7njgZ_p8cELcpDJuuKa=Gxg@mail.gmail.com>
	<20120206104649.01a89d66.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4izp7tV5t5k5e3RwaXHi_-z8NQ2G-0RwFy0cYrRtq1ry+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Mon, 6 Feb 2012 12:00:49 -0800
Ying Han <yinghan@google.com> wrote:

> On Sun, Feb 5, 2012 at 5:46 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 3 Feb 2012 12:15:59 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Fri, Feb 3, 2012 at 8:11 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > On Thu 02-02-12 17:37:13, Ying Han wrote:
> >> >> In v3.3-rc1, the global LRU has been removed with commit
> >> >> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.
> >> >>
> >> >> Signed-off-by: Ying Han <yinghan@google.com>
> >> >
> >> > For the global LRU removal
> >> > Acked-by: Michal Hocko <mhocko@suse.cz>
> >> >
> >> > see the comment about the swap extension bellow.
> >> >
> >> > Thanks
> >> >
> >> >> ---
> >> >> A Documentation/cgroups/memory.txt | A  25 ++++++++++++-------------
> >> >> A 1 files changed, 12 insertions(+), 13 deletions(-)
> >> >>
> >> >> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >> >> index 4c95c00..847a2a4 100644
> >> >> --- a/Documentation/cgroups/memory.txt
> >> >> +++ b/Documentation/cgroups/memory.txt
> >> > [...]
> >> >> @@ -209,19 +208,19 @@ In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
> >> >> A By using memsw limit, you can avoid system OOM which can be caused by swap
> >> >> A shortage.
> >> >>
> >> >> -* why 'memory+swap' rather than swap.
> >> >> -The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
> >> >> -to move account from memory to swap...there is no change in usage of
> >> >> -memory+swap. In other words, when we want to limit the usage of swap without
> >> >> -affecting global LRU, memory+swap limit is better than just limiting swap from
> >> >> -OS point of view.
> >> >> -
> >> >> A * What happens when a cgroup hits memory.memsw.limit_in_bytes
> >> >> A When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do swap-out
> >> >> A in this cgroup. Then, swap-out will not be done by cgroup routine and file
> >> >> -caches are dropped. But as mentioned above, global LRU can do swapout memory
> >> >> -from it for sanity of the system's memory management state. You can't forbid
> >> >> -it by cgroup.
> >> >> +caches are dropped.
> >> >> +
> >> >> +TODO:
> >> >> +* use 'memory+swap' rather than swap was due to existence of global LRU.
> >>
> >> I wasn't sure about the initial comment while making the patch. Since
> >> it mentions something about global LRU, which i figured we need to
> >> revisit it anyway.
> >>
> >
> > The "global LRU" here means 'the health of the whole memory management".
> > memory+swap guarantees memcg will never be obstacles for routines which
> > works for system memory management.
> >
> > soft-limit _is_ a hint for global lru. but memory+swap will never be.
> 
> 
> Thank you for the clarification. So the "global LRU" should be
> interpreted as global pressure, i guess? 

You're right.

> I can imagine some extra complexities on two limit (in memory & swap) vs one limit
> (memory+swap).
> 
> I will go ahead post the first patch and leave the swap change behind.
> Apparently I don't know the initial design much, and feel free to post
> the second half.
> 

Ok, I'll check.

Thanks,
-Kame 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
