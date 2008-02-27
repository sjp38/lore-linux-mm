Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1R9689S020921
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 20:06:08 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R92kgW4333656
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 20:02:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1R92kRY019080
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 20:02:46 +1100
Message-ID: <47C526F8.8010807@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 14:31:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] page reclaim throttle take2
References: <47C4EF2D.90508@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com> <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com> <47C4F9C0.5010607@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com> <47C51856.7060408@linux.vnet.ibm.com> <alpine.DEB.1.00.0802270045400.31372@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0802270045400.31372@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Wed, 27 Feb 2008, Balbir Singh wrote:
> 
>> Let's forget node hotplug for the moment, but what if someone
>>
>> 1. Changes the machine configuration and adds more nodes, do we expect the
>> kernel to be recompiled? Or is it easier to update /etc/sysctl.conf?
>> 2. Uses fake NUMA nodes and increases/decreases the number of nodes across
>> reboots. Should the kernel be recompiled?
>>
> 
> That is why the proposal was made to make this a static configuration 
> option, such as CONFIG_NUM_RECLAIM_THREADS_PER_NODE, that will handle both 
> situations.
> 

You mentioned CONFIG_NUM_RECLAIM_THREADS_PER_CPU and not
CONFIG_NUM_RECLAIM_THREADS_PER_NODE. The advantage with syscalls is that even if
we get the thing wrong, the system administrator has an alternative. Please look
through the existing sysctl's and you'll see what I mean. What is wrong with
providing the flexibility that comes with sysctl? We cannot possibly think of
all situations and come up with the right answer for a heuristic. Why not come
up with a default and let everyone use what works for them?


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
