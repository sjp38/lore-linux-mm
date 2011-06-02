Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5E776B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 05:06:55 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1199191bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 02:06:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602073335.GA20630@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<20110602073335.GA20630@cmpxchg.org>
Date: Thu, 2 Jun 2011 18:06:51 +0900
Message-ID: <BANLkTikztP6RoyBgMqUHgrzJFLZrHMCs=Q@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/2 Johannes Weiner <hannes@cmpxchg.org>:
> On Thu, Jun 02, 2011 at 08:52:47AM +0900, Hiroyuki Kamezawa wrote:
>> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> Hmm, I welcome and will review this patches but.....some points I want t=
o say.
>>
>> 1. No more conflict with Ying's work ?
>> =A0 =A0 Could you explain what she has and what you don't in this v2 ?
>> =A0 =A0 If Ying's one has something good to be merged to your set, pleas=
e
>> include it.
>
> The problem is that the solution we came up with at LSF, i.e. the
> one-dimensional linked list of soft limit-exceeding memcgs, is not
> adequate to represent the hierarchy structure of memcgs.
>
> My solution is fundamentally different, so I don't really see possible
> synergy between the patch series right now.
>
> This was the conclusion last time:
> http://marc.info/?l=3Dlinux-mm&m=3D130564056215365&w=3D2
>

Hmm, will look.

IIUC, current design of per-zone tree is for supoorting current policy
in efficient way as "pick up the largest usage excess memcg"

If we change policy, it's natural to make changes in implementation.


>> 2. it's required to see performance score in commit log.
>
> The patch series is not a performance optimization. =A0But I can include
> it to prove there are no regressions.
>
yes, it's helpful.


>> 4. This work can be splitted into some small works.
>> =A0 =A0 =A0a) fix for current code and clean ups
>> =A0 =A0 =A0a') statistics
>> =A0 =A0 =A0b) soft limit rework
>> =A0 =A0 =A0c) change global reclaim
>>
>> =A0 I like (a)->(b)->(c) order. and while (b) you can merge your work
>> with Ying's one.
>> =A0 And for a') , I'd like to add a new file memory.reclaim_stat as I've
>> already shown.
>> =A0 and allow resetting.
>
> Resetting reclaim statistics is a nice idea, let me have a look.
> Sorry, I am a bit behind on reviewing other patches...
>
I think I'll cut-out the patch and merge it before my full work.


>> =A0 Hmm, how about splitting patch 2/8 into small patches and see what h=
appens in
>> =A0 3.2 or 3.3 ? While that, we can make softlimit works better.
>> =A0 (and once we do 2/8, our direction will be fixed to the direction to
>> remove global LRU.)
>
> Do you have specific parts in mind that could go stand-alone?
>
> One thing I can think of is splitting up those parts:
>
> =A01. move /target/ reclaim to generic code
>
> =A02. convert /global/ reclaim from global lru to hierarchy reclaim
> =A0 =A0 including root_mem_cgroup
>

Hmm, at brief look
patch 2/8
 - hierarchy walk rewrite code should be stand alone and can be merged
1st, as clean-up
 - root cgroup LRU handling was required for performance. I think we
removed tons of
  atomic ops and can remove that special handling personally. But this chan=
ge of
  root cgroup handling should be in separate patch. with performance report=
.
....

I'll do close look later, sorry.
-Kame



>> 5. please write documentation to explain what new LRU do.
>
> Ok.
>
>> BTW, after this work, lists of ROOT cgroup comes again. I may need to ch=
eck
>> codes which see memcg is ROOT or not. Because we removed many atomic
>> ops in memcg, I wonder ROOT cgroup can be accounted again..
>
> Oh, please do if you can find the time. =A0The memcg lru rules are
> scary!
>

IIRC, It was requested by Red*at ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
