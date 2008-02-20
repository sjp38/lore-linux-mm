Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1KGJVIc019331
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 21:49:31 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KGJVMc340112
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 21:49:31 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1KGJUpY031717
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:19:31 GMT
Message-ID: <47BC5211.6030102@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 21:45:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com> <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr> <18364.20755.798295.881259@stoffel.org>
In-Reply-To: <18364.20755.798295.881259@stoffel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Jan Engelhardt <jengelh@computergmbh.de>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Stoffel wrote:
>>>>>> "Jan" == Jan Engelhardt <jengelh@computergmbh.de> writes:
> 
> Jan> On Feb 20 2008 20:50, Balbir Singh wrote:
>>> John Stoffel wrote:
>>>> I know this is a pedantic comment, but why the heck is it called such
>>>> a generic term as "Memory Controller" which doesn't give any
>>>> indication of what it does.
>>>>
>>>> Shouldn't it be something like "Memory Quota Controller", or "Memory
>>>> Limits Controller"?
>>> It's called the memory controller since it controls the amount of
>>> memory that a user can allocate (via limits). The generic term for
>>> any resource manager plugged into cgroups is a controller.
> 
> Jan> For ordinary desktop people, memory controller is what developers
> Jan> know as MMU or sometimes even some other mysterious piece of
> Jan> silicon inside the heavy box.
> 
> That's what was confusing me at first.  I was wondering why we needed
> a memory controller when we already had one in Linux!  
> 
> Also, controlling a resource is more a matter of limits or quotas, not
> controls.  Well, I'll actually back off on that, since controls does
> have a history in other industries.  
> 
> But for computers, limits is an expected and understood term, and for
> filesystems it's quotas.  So in this case, I *still* think you should
> be using the term "Memory Quota Controller" instead.  It just makes it
> clearer to a larger audience what you mean.
> 

Memory Quota sounds very confusing to me. Usually a quota implies limits, but in
a true framework, one can also implement guarantees and shares.

>>> If you look through some of the references in the document, we've
>>> listed our plans to support other categories of memory as well.
>>> Hence it's called a memory controller
>>>
>>>> Also, the Kconfig name "CGROUP_MEM_CONT" is just wrong, it should
>>>> be "CGROUP_MEM_CONTROLLER", just spell it out so it's clear what's
>>>> up.
> 
>>> This has some history as well. Control groups was called containers
>>> earlier. That way a name like CGROUP_MEM_CONT could stand for
>>> cgroup memory container or cgroup memory controller.
> 
> Jan> CONT is shorthand for "continue" ;-) (SIGCONT, f.ex.), ctrl or
> Jan> ctrlr it is for controllers (comes from Solaris iirc.)
> 
> Right, CTLR would be more regular shorthand for CONTROLLER.  
> 
> Basically, I think you're overloading a commonly used term for your
> own uses and when it's exposed to regular users, it will cause
> confusion.
> 

OK, I'll queue a patch and try to explain various terms used by resource management.

> Thanks,
> John


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
