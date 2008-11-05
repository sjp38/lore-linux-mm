Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA5DpXgW004997
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:51:33 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5DpTmD2826334
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:51:29 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5DpPpE001037
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 00:51:26 +1100
Message-ID: <4911A4D8.4010402@linux.vnet.ibm.com>
Date: Wed, 05 Nov 2008 19:21:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm][PATCH 0/4] Memory cgroup hierarchy introduction
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081104091510.01cf3a1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081104091510.01cf3a1e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 02 Nov 2008 00:18:12 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patch follows several iterations of the memory controller hierarchy
>> patches. The hardwall approach by Kamezawa-San[1]. Version 1 of this patchset
>> at [2].
>>
>> The current approach is based on [2] and has the following properties
>>
>> 1. Hierarchies are very natural in a filesystem like the cgroup filesystem.
>>    A multi-tree hierarchy has been supported for a long time in filesystems.
>>    When the feature is turned on, we honor hierarchies such that the root
>>    accounts for resource usage of all children and limits can be set at
>>    any point in the hierarchy. Any memory cgroup is limited by limits
>>    along the hierarchy. The total usage of all children of a node cannot
>>    exceed the limit of the node.
>> 2. The hierarchy feature is selectable and off by default
>> 3. Hierarchies are expensive and the trade off is depth versus performance.
>>    Hierarchies can also be completely turned off.
>>
>> The patches are against 2.6.28-rc2-mm1 and were tested in a KVM instance
>> with SMP and swap turned on.
>>
> 
> As first impression, I think hierarchical LRU management is not good...means
> not fair from viewpoint of memory management.

Could you elaborate on this further? Is scanning of children during reclaim the
issue? Do you want weighted reclaim for each of the children?

> I'd like to show some other possible implementation of
> try_to_free_mem_cgroup_pages() if I can.
> 

Elaborate please!

> Anyway, I have to merge this with mem+swap controller. 

Cool! I'll send you an updated version.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
