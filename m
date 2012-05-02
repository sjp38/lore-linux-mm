Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id DA1656B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 11:16:36 -0400 (EDT)
Message-ID: <4FA14F5D.4040504@parallels.com>
Date: Wed, 2 May 2012 12:14:37 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] slab+slub accounting for memcg
References: <1334958560-18076-1-git-send-email-glommer@parallels.com> <CABCjUKDGw20nojLqvZZbn0orO1aR9dhTZ65X_7ZSZto0eMk1GQ@mail.gmail.com>
In-Reply-To: <CABCjUKDGw20nojLqvZZbn0orO1aR9dhTZ65X_7ZSZto0eMk1GQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>

On 04/30/2012 06:43 PM, Suleiman Souhlal wrote:
>> I am leaving destruction of caches out of the series, although most
>> >  of the infrastructure for that is here, since we did it in earlier
>> >  series. This is basically because right now Kame is reworking it for
>> >  user memcg, and I like the new proposed behavior a lot more. We all seemed
>> >  to have agreed that reclaim is an interesting problem by itself, and
>> >  is not included in this already too complicated series. Please note
>> >  that this is still marked as experimental, so we have so room. A proper
>> >  shrinker implementation is a hard requirement to take the kmem controller
>> >  out of the experimental state.
> We will have to be careful for cache destruction.
> I found several races between allocation and destruction, in my patchset.
>
> I think we should consider doing the uncharging of kmem when
> destroying a memcg in mem_cgroup_destroy() instead of in
> pre_destroy(), because it's still possible that there are threads in
> the cgroup while pre_destroy() is being called (or for threads to be
> moved into the cgroup).

I found some problems here as well.
I am trying to work ontop of what Kamezawa posted for pre_destroy() 
rework. I have one or two incorrect uncharging issues to solve, that's 
actually what is holding me for posting a new version.

expected soon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
