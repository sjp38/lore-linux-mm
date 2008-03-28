Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2SAGPGd023002
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:16:25 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SAFXuI4309004
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:15:33 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2SAFW8J024665
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:15:33 +1100
Message-ID: <47ECC45F.3020005@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 15:41:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <47ECBD4A.8080908@gmail.com> <47ECBDAF.9070007@gmail.com>
In-Reply-To: <47ECBDAF.9070007@gmail.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Jiri Slaby wrote:
> On 03/28/2008 10:41 AM, Jiri Slaby wrote:
>>> linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner   
>>> 2008-03-28 09:30:47.000000000 +0530
>>> +++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h    2008-03-28
>>> 12:26:59.000000000 +0530
>>> @@ -227,8 +227,10 @@ struct mm_struct {
>>>      /* aio bits */
>>>      rwlock_t        ioctx_list_lock;
>>>      struct kioctx        *ioctx_list;
>>> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>> -    struct mem_cgroup *mem_cgroup;
>>> +#ifdef CONFIG_MM_OWNER
>>> +    spinlock_t owner_lock;
>>> +    struct task_struct *owner;    /* The thread group leader that */
>>
>> Doesn't make sense to switch them (spinlock is unsigned int on x86,
>> what's sizeof between and after?)?
> 
> Hmm, doesn't matter, there is another pointer after it, ignore me.

OK :)

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
