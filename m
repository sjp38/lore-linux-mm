Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2267B6B00E7
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:09:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3C6DF3EE0C1
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:08:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2287845DE54
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:08:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE91945DE4D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:08:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D93F91DB803E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:08:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93F151DB803A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 21:08:58 +0900 (JST)
Message-ID: <4F672165.4050506@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 21:07:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F669C2E.1010502@jp.fujitsu.com> <874ntlkrp6.fsf@linux.vnet.ibm.com> <4F66D993.2080100@jp.fujitsu.com> <4F671AE6.5020204@parallels.com>
In-Reply-To: <4F671AE6.5020204@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/03/19 20:39), Glauber Costa wrote:

> On 03/19/2012 11:00 AM, KAMEZAWA Hiroyuki wrote:
>> (2012/03/19 15:52), Aneesh Kumar K.V wrote:
>>
>>> On Mon, 19 Mar 2012 11:38:38 +0900, KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>>>> (2012/03/17 2:39), Aneesh Kumar K.V wrote:
>>>>
>>>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>>>
>>>>> This patch implements a memcg extension that allows us to control
>>>>> HugeTLB allocations via memory controller.
>>>>>
>>>>
>>>>
>>>> If you write some details here, it will be helpful for review and
>>>> seeing log after merge.
>>>
>>> Will add more info.
>>>
>>>>
>>>>
>>>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>>>> ---
>>>>>   include/linux/hugetlb.h    |    1 +
>>>>>   include/linux/memcontrol.h |   42 +++++++++++++
>>>>>   init/Kconfig               |    8 +++
>>>>>   mm/hugetlb.c               |    2 +-
>>>>>   mm/memcontrol.c            |  138 ++++++++++++++++++++++++++++++++++++++++++++
>>>>>   5 files changed, 190 insertions(+), 1 deletions(-)
>>>
>>> ....
>>>
>>>>> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
>>>>> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
>>>>> +{
>>>>> +	int idx;
>>>>> +	for (idx = 0; idx<  hugetlb_max_hstate; idx++) {
>>>>> +		if (memcg->hugepage[idx].usage>  0)
>>>>> +			return 1;
>>>>> +	}
>>>>> +	return 0;
>>>>> +}
>>>>
>>>>
>>>> Please use res_counter_read_u64() rather than reading the value directly.
>>>>
>>>
>>> The open-coded variant is mostly derived from mem_cgroup_force_empty. I
>>> have updated the patch to use res_counter_read_u64.
>>>
>>
>> Ah, ok. it's(maybe) my bad. I'll schedule a fix.
>>
> Kame,
> 
> I actually have it ready here. I can submit it if you want.
> 


That's good :) please post.
(But I'm sorry I'll be absent tomorrow.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
