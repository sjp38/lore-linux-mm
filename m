Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id F00466B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 02:22:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5FAD93EE081
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:22:26 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4299945DE56
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:22:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B3345DE5B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:22:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A1761DB803C
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:22:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5F171DB803A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:22:25 +0900 (JST)
Message-ID: <50A5E997.6060002@jp.fujitsu.com>
Date: Fri, 16 Nov 2012 16:21:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: get rid of once-per-second cache shrinking
 for dead memcgs
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-6-git-send-email-glommer@parallels.com> <50A4B8C8.6020202@jp.fujitsu.com> <50A4F289.1090807@parallels.com> <50A5CA16.7070603@jp.fujitsu.com> <50A5E73F.8030201@parallels.com>
In-Reply-To: <50A5E73F.8030201@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

(2012/11/16 16:11), Glauber Costa wrote:
> On 11/16/2012 09:07 AM, Kamezawa Hiroyuki wrote:
>> (2012/11/15 22:47), Glauber Costa wrote:
>>> On 11/15/2012 01:41 PM, Kamezawa Hiroyuki wrote:
>>>> (2012/11/15 11:54), Glauber Costa wrote:
>>>>> The idea is to synchronously do it, leaving it up to the shrinking
>>>>> facilities in vmscan.c and/or others. Not actively retrying shrinking
>>>>> may leave the caches alive for more time, but it will remove the ugly
>>>>> wakeups. One would argue that if the caches have free objects but are
>>>>> not being shrunk, it is because we don't need that memory yet.
>>>>>
>>>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>>>> CC: Michal Hocko <mhocko@suse.cz>
>>>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>
>>>> I agree this patch but can we have a way to see the number of unaccounted
>>>> zombie cache usage for debugging ?
>>>>
>>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>
>>> Any particular interface in mind ?
>>>
>>
>> Hmm, it's debug interface and having cgroup file may be bad.....
>> If it can be seen in bytes or some, /proc/vmstat ?
>>
>> out_of_track_slabs  xxxxxxx. hm ?
>>
> 
> I particularly think that, being this a debug interface, it is also
> useful to have an indication of which caches are still in place. This is
> because the cache itself, is the best indication we have about the
> specific workload that may be keeping it in memory.
> 
> I first thought debugfs could help us probing useful information out of
> it, but given all the abuse people inflicted in debugfs... maybe we
> could have a file in the root memcg with that information for all
> removed memcgs? If we do that, we can go further and list the memcgs
> that are pending due to memsw as well. memory.dangling_memcgs ?
> 

Hm, I'm ok with it... others ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
