Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7D6JirP3608658
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 16:19:44 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7D6LCAa093698
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 16:21:13 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7D6Hcse004374
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 16:17:38 +1000
Message-ID: <46BFF75F.9000900@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2007 11:47:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 8/9] Memory controller add switch to control what
 type of pages to limit (v4)
References: <46BFEE72.9080209@linux.vnet.ibm.com> <20070813060427.0334E1BF9D8@siro.lan>
In-Reply-To: <20070813060427.0334E1BF9D8@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>>> Choose if we want cached pages to be accounted or not. By default both
>>>> are accounted for. A new set of tunables are added.
>>>>
>>>> echo -n 1 > mem_control_type
>>>>
>>>> switches the accounting to account for only mapped pages
>>>>
>>>> echo -n 2 > mem_control_type
>>>>
>>>> switches the behaviour back
>>> MEM_CONTAINER_TYPE_ALL is 3, not 2.
>>>
>> Thanks, I'll fix the comment on the top.
>>
>>> YAMAMOTO Takashi
>>>
>>>> +enum {
>>>> +	MEM_CONTAINER_TYPE_UNSPEC = 0,
>>>> +	MEM_CONTAINER_TYPE_MAPPED,
>>>> +	MEM_CONTAINER_TYPE_CACHED,
> 
> what's MEM_CONTAINER_TYPE_CACHED, btw?
> it seems that nothing distinguishes it from MEM_CONTAINER_TYPE_MAPPED.
> 

The important types are currently MEM_CONTAINER_TYPE_MAPPED and MEM_CONTAINER_TYPE_ALL.
I added the types for future use (may be for finer accounting of types, later).

> YAMAMOTO Takashi


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
