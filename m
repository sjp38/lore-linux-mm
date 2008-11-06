Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mA67LhH7021900
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 12:51:52 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA671KT83928276
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 12:31:20 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id mA671Rbf010946
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 18:01:27 +1100
Message-ID: <49129644.8090805@linux.vnet.ibm.com>
Date: Thu, 06 Nov 2008 12:31:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184902.2575.11443.sendpatchset@balbir-laptop> <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com> <490D42C7.4000301@linux.vnet.ibm.com> <20081102152412.2af29a1b.kamezawa.hiroyu@jp.fujitsu.com> <490DCCC9.5000508@linux.vnet.ibm.com> <6599ad830811032237q14c065efx4316fee8f8daa515@mail.gmail.com> <49129601.4040008@linux.vnet.ibm.com>
In-Reply-To: <49129601.4040008@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Paul Menage wrote:
>> On Sun, Nov 2, 2008 at 7:52 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> That should not be hard, but having it per-subtree sounds a little complex in
>>> terms of exploiting from the end-user perspective and from symmetry perspective
>>> (the CPU cgroup controller provides hierarchy control for the full hierarchy).
>>>
>> The difference is that the CPU controller works in terms of shares,
>> whereas memory works in terms of absolute memory size. So it pretty
>> much has to limit the hierarchy to a single tree. Also, I didn't think
>> that you could modify the shares for the root cgroup - what would that
>> mean if so?
>>
> 
> The shares are proportional for the CPU controller. I am confused as to which
> shares (CPU you are talking about?
> 
>> With this patch set as it is now, the root cgroup's lock becomes a
>> global memory allocation/deallocation lock, which seems a bit painful.
> 
> Yes, true, but then that is the cost associated with using a hierarchy.
> 
>> Having a bunch of top-level cgroups each with their own independent
>> memory limits, and allowing sub cgroups of them to be constrained by
>> the parent's memory limit, seems more useful than a single hierarchy
>> connected at the root.
> 
> That is certainly do-able, but can be confusing to users, given how other
> controllers work. We can document that
> 
>> In what realistic circumstances do you actually want to limit the root
>> cgroup's memory usage?
>>
> 
> Good point, I would expect that people would mostly use the hierarchy with
> soft-limits or shares. I am now beginning to like Kamezawa and your suggestion
> of limiting usage to subtrees.

Oh! I am not sure if I mentioned, but you don't need to limit usage at the root.
Any parent along the hierarchy can be limited and it will act as if the entire
subtree is limited by that limit.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
