Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7D5i7l1232138
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 15:44:07 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7D5dT773407890
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 15:39:29 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7D5dSVT016684
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 15:39:29 +1000
Message-ID: <46BFEE72.9080209@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2007 11:08:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 8/9] Memory controller add switch to control what
 type of pages to limit (v4)
References: <20070727201103.31565.3104.sendpatchset@balbir-laptop> <20070813003348.91E3E1BF943@siro.lan>
In-Reply-To: <20070813003348.91E3E1BF943@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> Choose if we want cached pages to be accounted or not. By default both
>> are accounted for. A new set of tunables are added.
>>
>> echo -n 1 > mem_control_type
>>
>> switches the accounting to account for only mapped pages
>>
>> echo -n 2 > mem_control_type
>>
>> switches the behaviour back
> 
> MEM_CONTAINER_TYPE_ALL is 3, not 2.
> 

Thanks, I'll fix the comment on the top.

> YAMAMOTO Takashi
> 
>> +enum {
>> +	MEM_CONTAINER_TYPE_UNSPEC = 0,
>> +	MEM_CONTAINER_TYPE_MAPPED,
>> +	MEM_CONTAINER_TYPE_CACHED,
>> +	MEM_CONTAINER_TYPE_ALL,
>> +	MEM_CONTAINER_TYPE_MAX,
>> +} mem_control_type;
>> +
>> +static struct mem_container init_mem_container;
> 
>> +	mem = rcu_dereference(mm->mem_container);
>> +	if (mem->control_type == MEM_CONTAINER_TYPE_ALL)
>> +		return mem_container_charge(page, mm);
>> +	else
>> +		return 0;


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
