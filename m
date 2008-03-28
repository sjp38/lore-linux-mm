Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2SAscQa005299
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:54:38 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SAsxAj3735680
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:54:59 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2SAt5sT009076
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:55:06 +1100
Message-ID: <47ECCDA4.3050909@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 16:21:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <20080328194839.fe6ffa52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080328194839.fe6ffa52.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 28 Mar 2008 13:53:16 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>
>> This patch removes the mem_cgroup member from mm_struct and instead adds
>> an owner. This approach was suggested by Paul Menage. The advantage of
>> this approach is that, once the mm->owner is known, using the subsystem
>> id, the cgroup can be determined. It also allows several control groups
>> that are virtually grouped by mm_struct, to exist independent of the memory
>> controller i.e., without adding mem_cgroup's for each controller,
>> to mm_struct.
>>
>> The code initially assigns mm->owner to the task and then after the
>> thread group leader is identified. The mm->owner is changed to the thread
>> group leader of the task later at the end of copy_process.
>>
> Hmm, I like this approach. 
> 

Thanks,

> -a bit off topic-
> BTW, could you move mem_cgroup_from_task() to include/linux/memcontrol.h ?
> 

Yes, that can be done

> Then, I'll add an interface like
> mem_cgroup_charge_xxx(struct page *page, struct mem_cgroup *mem, gfp_mask mask)
> 
> This can be called in following way:
> mem_cgroup_charge_xxx(page, mem_cgroup_from_task(current), GFP_XXX);
> and I don't have to access mm_struct's member in this case.
> 

OK. Will do. Can that wait until Andrew picks up these patches. Then I'll put
that as an add-on?

Thanks for the review

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
