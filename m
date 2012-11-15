Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4A8A36B0083
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:45:08 -0500 (EST)
Message-ID: <50A45729.4000203@parallels.com>
Date: Thu, 15 Nov 2012 06:44:57 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] rework mem_cgroup iterator
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz> <50A3C42F.9020901@parallels.com> <20121114184110.GD21185@mtj.dyndns.org>
In-Reply-To: <20121114184110.GD21185@mtj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>

On 11/14/2012 10:41 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Nov 14, 2012 at 05:17:51PM +0100, Glauber Costa wrote:
>> Why can't we reuse the scheduler iterator and move it to kernel/cgroup.c
>> ? It already exists, provide sane ordering, and only relies on parent
>> information - which cgroup core already have - to do the walk.
> 
> Hmmm... we can but I personally much prefer for_each_*() iterators
> over callback based ones.  It's just much easier to share states
> across an iteration and follow the logic.  walk_tg_tree_from() does
> have the benefit of being able to combine pre and post visits in the
> same walk, which doesn't seem to have any user at the moment.
> 
> Thanks.
> 

Is there any particular reason why we can't do the other way around
then, and use a for_each_*() for sched walks? Without even consider what
I personally prefer, what I really don't like is to have two different
cgroup walkers when it seems like we could very well have just one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
