Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2HFHIjR003730
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 20:47:18 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HFHHSW1183964
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 20:47:18 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2HFHH0X011516
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 15:17:17 GMT
Message-ID: <47DE8B1E.4010501@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2008 20:45:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com> <47DDCDA7.4020108@cn.fujitsu.com> <6599ad830803161857r6d01f962vfd0f570e6124ab24@mail.gmail.com> <47DDFCEA.3030207@linux.vnet.ibm.com> <6599ad830803162222t6c32f5a1qd4d0af4887dfa910@mail.gmail.com>
In-Reply-To: <6599ad830803162222t6c32f5a1qd4d0af4887dfa910@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 17, 2008 at 1:08 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  I understand the per-mm pointer overhead back to the cgroup. I don't understand
>>  the part about adding a per-mm pointer back to the "owning" task. We already
>>  have task->mm.
> 
> Yes, but we don't have mm->owner, which is what I was proposing -
> mm->owner would be a pointer typically to the mm's thread group
> leader. It would remove the need to have to have pointers for the
> various different cgroup subsystems that need to act on an mm rather
> than a task_struct, since then you could use
> mm->owner->cgroups[subsys_id].
> 

Aaahh.. Yes.. mm->owner might be a good idea. The only thing we'll need to
handle is when mm->owner dies (I think the thread group is still kept around).
The other disadvantage is the double dereferencing, which should not be all that
bad.

> But this is kind of orthogonal to whether virtual address space limits
> should be a separate cgroup subsystem.
> 

Yes, sure.


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
