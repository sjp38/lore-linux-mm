Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m316foTr111964
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 16:41:50 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m316YODV173242
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 17:34:26 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m316UYKl013713
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 17:30:34 +1100
Message-ID: <47F1D576.608@linux.vnet.ibm.com>
Date: Tue, 01 Apr 2008 11:55:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain> <20080401060330.743815A02@siro.lan>
In-Reply-To: <20080401060330.743815A02@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: menage@google.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> This patch removes the mem_cgroup member from mm_struct and instead adds
>> an owner. This approach was suggested by Paul Menage. The advantage of
>> this approach is that, once the mm->owner is known, using the subsystem
>> id, the cgroup can be determined. It also allows several control groups
>> that are virtually grouped by mm_struct, to exist independent of the memory
>> controller i.e., without adding mem_cgroup's for each controller,
>> to mm_struct.
>>
>> A new config option CONFIG_MM_OWNER is added and the memory resource
>> controller selects this config option.
>>
>> NOTE: This patch was developed on top of 2.6.25-rc5-mm1 and is applied on top
>> of the memory-controller-move-to-own-slab patch (which is already present
>> in the Andrew's patchset).
>>
>> I am indebted to Paul Menage for the several reviews of this patchset
>> and helping me make it lighter and simpler.
>>
>> This patch was tested on a powerpc box, by running a task under the memory
>> resource controller and moving it across groups at a constant interval.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
> 
> changing mm->owner without notifying controllers makes it difficult to use.
> can you provide a notification mechanism?

But mm->owner is just a way to get to the correct cgroup and that does not
change when mm->owner changes. Do we really need this notification? For the
virtual memory controller, move_task() is sufficient, not sure why mm->owner is
required.

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
