Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4370E6B007E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:49:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 21 Mar 2012 10:18:53 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2L4mnZi4325388
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:18:50 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2LAJHJF021597
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 21:19:17 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
In-Reply-To: <4F671AE6.5020204@parallels.com>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F669C2E.1010502@jp.fujitsu.com> <874ntlkrp6.fsf@linux.vnet.ibm.com> <4F66D993.2080100@jp.fujitsu.com> <4F671AE6.5020204@parallels.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 21 Mar 2012 10:18:43 +0530
Message-ID: <87obrqsgno.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Glauber Costa <glommer@parallels.com> writes:

> On 03/19/2012 11:00 AM, KAMEZAWA Hiroyuki wrote:
>> (2012/03/19 15:52), Aneesh Kumar K.V wrote:
>>
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
> This one has bitten me as well when I was trying to experiment with the 
> res_counter performance...

Do we really need memcg.res.usage to be accurate in that while loop ? If
we miss a zero update because we encountered a partial update; in the
next loop we will find it zero right ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
