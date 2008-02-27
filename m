Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R5sR1h030049
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 11:24:27 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R5sRTu925792
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 11:24:27 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R5sWbq029790
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 05:54:32 GMT
Message-ID: <47C4F9C0.5010607@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 11:18:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] page reclaim throttle take2
References: <47C4EF2D.90508@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com> <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Wed, 27 Feb 2008, KOSAKI Motohiro wrote:
> 
>>> I disagree, the config option is indeed static but so is the NUMA topology 
>>> of the machine.  It represents the maximum number of page reclaim threads 
>>> that should be allowed for that specific topology; a maximum should not 
>>> need to be redefined with yet another sysctl and should remain independent 
>>> of various workloads.
>> ok.
>>
>>> However, I would recommend adding the word "MAX" to the config option.
>> MAX_PARALLEL_RECLAIM_TASK is good word?
>>
> 
> I'd use _THREAD instead of _TASK, but I'd also wait for Balbir's input 
> because perhaps I missed something in my original analysis that this 
> config option represents only the maximum number of concurrent reclaim 
> threads and other heuristics are used in addition to this that determine 
> the exact number of threads depending on VM strain.
> 


Things are changing, with memory hot-add remove, CPU hotplug , the topology can
change and is no longer static. One can create fake NUMA nodes on the fly using
a boot option as well.

Since we're talking of parallel reclaims, I think it's a function of CPUs and
Nodes. I'd rather keep it as a sysctl with a good default value based on the
topology. If we end up getting it wrong, the system administrator has a choice.
That is better than expecting him/her to recompile the kernel and boot that. A
sysctl does not create problems either w.r.t changing the number of threads, no
hard to solve race-conditions - it is fairly straight forward




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
