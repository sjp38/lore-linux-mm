Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8CC1E6B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 04:39:40 -0400 (EDT)
Message-ID: <4FB3674C.2030604@parallels.com>
Date: Wed, 16 May 2012 12:37:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com> <4FB3431C.3050402@parallels.com> <4FB3518B.3090205@parallels.com> <4FB3652D.2040909@jp.fujitsu.com>
In-Reply-To: <4FB3652D.2040909@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>

On 05/16/2012 12:28 PM, KAMEZAWA Hiroyuki wrote:
> (2012/05/16 16:04), Glauber Costa wrote:
> 
>> On 05/16/2012 10:03 AM, Glauber Costa wrote:
>>>> BTW, what is the relationship between 1/2 and 2/2  ?
>>> Can't do jump label patching inside an interrupt handler. They need to
>>> happen when we free the structure, and I was about to add a worker
>>> myself when I found out we already have one: just we don't always use it.
>>>
>>> Before we merge it, let me just make sure the issue with config Li
>>> pointed out don't exist. I did test it, but since I've reposted this
>>> many times with multiple tiny changes - the type that will usually get
>>> us killed, I'd be more comfortable with an extra round of testing if
>>> someone spotted a possibility.
>>>
>>> Who is merging this fix, btw ?
>>> I find it to be entirely memcg related, even though it touches a file in
>>> net (but a file with only memcg code in it)
>>>
>>
>> For the record, I compiled test it many times, and the problem that Li
>> wondered about seems not to exist.
>>
> 
> Ah...Hmm.....I guess dependency problem will be found in -mm if any rather than
> netdev...
> 
> David, can this bug-fix patch goes via -mm tree ? Or will you pick up ?
> 

Another thing: Patch 2 in this series is of course dependent on patch 1
- which lives 100 % in memcg core. Without that, lockdep will scream
while disabling the static key.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
