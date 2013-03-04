Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 090416B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 02:24:49 -0500 (EST)
Message-ID: <51344C57.7030807@parallels.com>
Date: Mon, 4 Mar 2013 11:25:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: per-cpu statistics
References: <512F0E76.2020707@parallels.com> <CAFj3OHXJckvDPWSnq9R8nZ00Sb0Juxq9oCrGCBeO0UZmgH6OzQ@mail.gmail.com>
In-Reply-To: <CAFj3OHXJckvDPWSnq9R8nZ00Sb0Juxq9oCrGCBeO0UZmgH6OzQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On 03/01/2013 05:48 PM, Sha Zhengju wrote:
> Hi Glauber,
> 
> Forgive me, I'm replying not because I know the reason of current
> per-cpu implementation but that I notice you're mentioning something
> I'm also interested in. Below is the detail.
> 
> 
> I'm not sure I fully understand your points, root memcg now don't
> charge page already and only do some page stat
> accounting(CACHE/RSS/SWAP).

Can you point me to the final commits of this in the tree? I am using
the latest git mm from mhocko and it is not entirely clear for me what
are you talking about.

>  Now I'm also trying to do some
> optimization specific to the overhead of root memcg stat accounting,
> and the first attempt is posted here:
> https://lkml.org/lkml/2013/1/2/71 . But it only covered
> FILE_MAPPED/DIRTY/WRITEBACK(I've add the last two accounting in that
> patchset) and Michal Hock accepted the approach (so did Kame) and
> suggested I should handle all the stats in the same way including
> CACHE/RSS. But I do not handle things related to memcg LRU where I
> notice you have done some work.
> 
Yes, LRU is a bit tricky and it is what is keeping me from posting the
patchset I have. I haven't fully done it, but I am on my way.


> It's possible that we may take different ways to bypass root memcg
> stat accounting. The next round of the part will be sent out in
> following few days(doing some tests now), and for myself any comments
> and collaboration are welcome. (Glad to cc to you of course if you're
> also interest in it. :) )
> 

I am interested, of course. As you know, I started to work on this a
while ago and had to interrupt it for a while. I resumed it last week,
but if you managed to merge something already, I'd happy to rebase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
