Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5FF656B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 05:52:47 -0500 (EST)
Message-ID: <51371FEF.3020507@parallels.com>
Date: Wed, 6 Mar 2013 14:52:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-3-git-send-email-glommer@parallels.com> <51368D80.20701@jp.fujitsu.com> <5136FEC2.2050004@parallels.com> <51371E4A.7090807@jp.fujitsu.com>
In-Reply-To: <51371E4A.7090807@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On 03/06/2013 02:45 PM, Kamezawa Hiroyuki wrote:
> (2013/03/06 17:30), Glauber Costa wrote:
>> On 03/06/2013 04:27 AM, Kamezawa Hiroyuki wrote:
>>> (2013/03/05 22:10), Glauber Costa wrote:
>>>> +	case _MEMSWAP: {
>>>> +		struct sysinfo i;
>>>> +		si_swapinfo(&i);
>>>> +
>>>> +		return ((memcg_read_root_rss() +
>>>> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT) +
>>>> +		i.totalswap - i.freeswap;
>>>
>>> How swapcache is handled ? ...and How kmem works with this calc ?
>>>
>> I am ignoring kmem, because we don't account kmem for the root cgroup
>> anyway.
>>
>> Setting the limit is invalid, and we don't account until the limit is
>> set. Then it will be 0, always.
>>
>> For swapcache, I am hoping that totalswap - freeswap will cover
>> everything swap related. If you think I am wrong, please enlighten me.
>>
> 
> i.totalswap - i.freeswap = # of used swap entries.
> 
> SwapCache can be rss and used swap entry at the same time. 
> 

Well, yes, but the rss entries would be accounted for in get_mm_rss(),
won't they ?

What am I missing ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
