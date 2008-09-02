Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m82CaQBg032603
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 22:36:26 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m82CbJKt278076
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 22:37:19 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m82CbJME004883
	for <linux-mm@kvack.org>; Tue, 2 Sep 2008 22:37:19 +1000
Message-ID: <48BD337E.40001@linux.vnet.ibm.com>
Date: Tue, 02 Sep 2008 18:07:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080831174756.GA25790@balbir.in.ibm.com> <200809011656.45190.nickpiggin@yahoo.com.au> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809011743.42658.nickpiggin@yahoo.com.au> <48BD0641.4040705@linux.vnet.ibm.com> <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com> <48BD0E4A.5040502@linux.vnet.ibm.com> <20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com> <48BD119B.8020605@linux.vnet.ibm.com> <20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Sep 2008 15:42:43 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>>>> Kamezawa-San, I would like to integrate the radix tree patches after review and
>>>>>> some more testing then integrate your patchset on top of it. Do you have any
>>>>>> objections/concerns with the suggested approach?
>>>>>>
>>>>> please show performance number first.
>>>> Yes, that is why said some more testing. I am running lmbench and kernbench on
>>>> it and some other tests, I'll get back with numbers.
>>>>
>>> A test which is not suffer much from I/O is better.
>>> And please don't worry about my patches. I'll reschedule if yours goes first.
>>>
>> Thanks, I'll try and find the right set of tests.
> 
> Maybe it's good time to share my concerns.
> 
> IMHO, the memory resource controller is for dividing memory into groups.
> 
> We have following choices to divide memory into groups, now.
>   - cpuset(+ fake NUMA)
>   - VM (kvm, Xen, etc...)
>   - memory resource controller. (memcg)
> 
> Considering 3 aspects peformance, flexibility, isolation(security).
> My expectaion is
> 
> peroformance   : cpuset > memcg >> VMs
> flexibility    : memcg  > VMs >> cpuset.
> isolation      : VMs >> cpuset >= memcg
> 
> The word 'flexibility' sounds sweet *but* it's just one of aspects.
> If the peformance is cpuset > VMs > memcg, I'll advise users to use VMs.
> 
> I think VMs are getting faster and faster. memcg will be slower when we add new
> 'fancy' feature more. (I think we need some more features.)
> So, I want to keep memcg fast as much as possible at this stage.
> 
> But yes, memory usage overhead of page->page_cgroup, struct page_cgroup is big
> on 32bit arch. I'll say users to use VMs, maybe ;)

I understand your concern and I am not trying to reduce memcg's performance - or
add a fancy feature. I am trying to make memcg more friendly for distros. I see
your point about the overhead. I just got back my results - I see a 4% overhead
with the patches. Let me see if I can rework them for better performance.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
