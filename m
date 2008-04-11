Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m3B4SZFa005566
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 14:28:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3B4Sstx1544442
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 14:28:54 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3B4T4hd025342
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 14:29:04 +1000
Message-ID: <47FEE89A.1010102@linux.vnet.ibm.com>
Date: Fri, 11 Apr 2008 09:57:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v9)
References: <20080410091602.4472.32172.sendpatchset@localhost.localdomain> <20080411123339.89aea319.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080411123339.89aea319.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> maybe I don't undestand correctlly...
> 
> On Thu, 10 Apr 2008 14:46:02 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>  
>> +config MM_OWNER
>> +	bool
>> +
> no default is ok here  ? what value will this have if not selected ?
> I'm sorry if I misunderstand Kconfig.
> 

The way this works is

If I select memory resource controller, CONFIG_MM_OWNER is set to y, else it
does not even show up in the .config

> 
>> +	/*
>> +	 * Search through everything else. We should not get
>> +	 * here often
>> +	 */
>> +	do_each_thread(g, c) {
>> +		if (c->mm == mm)
>> +			goto assign_new_owner;
>> +	} while_each_thread(g, c);
>> +
> 
> Again, do_each_thread() is suitable here ?
> for_each_process() ?
> 

do_each_thread(), while_each_thread() walks all processes and threads of those
processes in the system. It is a common pattern used in the kernel (see
try_to_freeze_tasks() or oom_kill_task() for example).

> Thanks,
> -Kame
> 


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
