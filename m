Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2II00cU011674
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:00:00 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2II0R6V3420396
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:00:27 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2II0Qg9002870
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 05:00:26 +1100
Message-ID: <47E002CB.4090900@linux.vnet.ibm.com>
Date: Tue, 18 Mar 2008 23:28:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <20080316173005.8812.88290.sendpatchset@localhost.localdomain> <1205772790.18916.17.camel@nimitz.home.sr71.net> <47DF1760.9030908@linux.vnet.ibm.com> <1205860276.8872.20.camel@nimitz.home.sr71.net>
In-Reply-To: <1205860276.8872.20.camel@nimitz.home.sr71.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2008-03-18 at 06:44 +0530, Balbir Singh wrote: 
>>> If you're going to do this, I think you need a couple of phases.  
>>>
>>> 1. update the vm_(un)acct_memory() functions to take an mm
>> There are other problems
>>
>> 1. vm_(un)acct_memory is conditionally dependent on VM_ACCOUNT. Look at
>> shmem_(un)acct_size for example
> 
> Yeah, but if VM_ACCOUNT isn't set, do you really want the controller
> accounting for them?  It's there for a reason. :)
> 

We are trying to account for virtual memory usage. Please see
http://lwn.net/Articles/5016/ to see what VM_ACCOUNT does or
Documentation/vm/overcommit-accounting. We want to account and control virtual
memory usage and not necessarily implement overcommit accounting

> The shmem_acct_size() helpers look good.  I wonder if we should be using
> that kind of things more generically.
> 

Yes, it is well written. I wish there were more such abstractions, but it does
not help us.

>> 2. These routines are not called from all contexts that we care about (look at
>> insert_special_mapping())
> 
> Could you explain why "we" care about it and why it isn't accounted for
> now?

It is accounted for in total_vm and that's why we care about :)

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
