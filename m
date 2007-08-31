Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7V4eim9030902
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 14:40:44 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7V4efjM4714738
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 14:40:41 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7V5eett007083
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 15:40:40 +1000
Message-ID: <46D79BC3.7050908@linux.vnet.ibm.com>
Date: Fri, 31 Aug 2007 10:10:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org> <46D3C244.7070709@yahoo.com.au> <46D3CE29.3030703@linux.vnet.ibm.com> <46D3EADE.3080001@yahoo.com.au> <46D4097A.7070301@linux.vnet.ibm.com> <46D52030.9080605@yahoo.com.au> <46D52B07.6050809@linux.vnet.ibm.com> <46D67426.606@yahoo.com.au> <46D68833.2030405@linux.vnet.ibm.com> <46D76255.7000008@yahoo.com.au>
In-Reply-To: <46D76255.7000008@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

<snip>
Nick Piggin wrote:
>>
>> My hook really is -- there was a race, there is no rmap lock to prevent
>> several independent processes from mapping the same page into their
>> page tables. I want to increment the reference count just once (apart
>> from
>> it being accounted in the page cache), since we account the page once.
>>
>> I'll revisit this hook to see if it can be made cleaner
> 
> If you just have a different hook for mapping a page into the page
> tables, your controller can take care of any races, no?
> 

We increment the reference count in the mem_container_charge() routine.
Not all pages into page tables, so it makes sense to do the reference
counting there. The charge routine, also does reclaim, so we cannot call
it at mapping time, since the mapping happens under pte lock.

I'll see if I can refactor the way we reference count, I agree that
it would simplify code maintenance.

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
