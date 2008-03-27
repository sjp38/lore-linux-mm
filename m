Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2R9oEX4009946
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 15:20:14 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2R9oE6k573632
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 15:20:14 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2R9oKi7017539
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 09:50:21 GMT
Message-ID: <47EB6D00.5070306@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 15:16:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][1/3] Add user interface for virtual address space control
 (v2)
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>	<20080326185006.9465.4720.sendpatchset@localhost.localdomain> <20080327181404.1e95a725.kamezawa.hiroyu@jp.fujitsu.com> <47EB6B4D.2030305@openvz.org>
In-Reply-To: <47EB6B4D.2030305@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Thu, 27 Mar 2008 00:20:06 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>> Add as_usage_in_bytes and as_limit_in_bytes interfaces. These provide
>>> control over the total address space that the processes combined together
>>> in the cgroup can grow upto. This functionality is analogous to
>>> the RLIMIT_AS function of the getrlimit(2) and setrlimit(2) calls.
>>> A as_res resource counter is added to the mem_cgroup structure. The
>>> as_res counter handles all the accounting associated with the virtual
>>> address space accounting and control of cgroups.
>>>
>>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> I wonder that it's better to create "rlimit cgroup" rather than enhancing
>> memory controller. (But I have no strong opinion.)
>> How do you think ?
> 
> I believe that all memory management is better to have in one controller...
> 

Paul wants to see it in a different controller. He has been reasoning it out in
another email thread.

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
