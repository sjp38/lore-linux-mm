Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4MAG6Bf000795
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:46:06 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4MAFr6t1380444
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:45:53 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4MAFn0F000895
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:45:50 +0530
Message-ID: <483547B1.6030604@linux.vnet.ibm.com>
Date: Thu, 22 May 2008 15:45:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521153012.15001.96490.sendpatchset@localhost.localdomain> <20080521212408.6f535259.akpm@linux-foundation.org>
In-Reply-To: <20080521212408.6f535259.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 21 May 2008 21:00:12 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patch adds support for accounting and control of virtual address space
>> limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
>> The core of the accounting takes place during fork time in copy_process(),
>> may_expand_vm(), remove_vma_list() and exit_mmap(). 
>>
>> Changelog v5->v4
>>
>> Move specific hooks in code to insert_vm_struct
>> Use mmap_sem to protect mm->owner from changing and mm->owner from
>> changing cgroups.
>>
>> ...
>>
>> + * brk(), sbrk()), stack expansion, mremap(), etc - called with
>> + * mmap_sem held.
>> + * decreasing - called with mmap_sem held.
>> + * This callback is called with mmap_sem held
> 
> It's good to document the locking prerequisites but for rwsems, one
> should specify whether it must be held for reading or for writing.
> 
> Of course, down_write() is a superset of down_read(), so if it's "held
> for reading" then either mode-of-holding is OK.  But it's best to spell
> all that out.
> 

Sure, will do


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
