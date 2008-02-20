Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1KFPAie013410
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 20:55:10 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KFPA8d897052
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 20:55:10 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1KFP9PY031743
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 15:25:09 GMT
Message-ID: <47BC4554.10304@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 20:50:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org>
In-Reply-To: <18364.16552.455371.242369@stoffel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Stoffel wrote:
> I know this is a pedantic comment, but why the heck is it called such
> a generic term as "Memory Controller" which doesn't give any
> indication of what it does.
> 
> Shouldn't it be something like "Memory Quota Controller", or "Memory
> Limits Controller"?
> 

It's called the memory controller since it controls the amount of memory that a
user can allocate (via limits). The generic term for any resource manager
plugged into cgroups is a controller. If you look through some of the references
in the document, we've listed our plans to support other categories of memory as
well. Hence it's called a memory controller

> Also, the Kconfig name "CGROUP_MEM_CONT" is just wrong, it should be
> "CGROUP_MEM_CONTROLLER", just spell it out so it's clear what's up.
> 

This has some history as well. Control groups was called containers earlier.
That way a name like CGROUP_MEM_CONT could stand for cgroup memory container or
cgroup memory controller.

> It took me a bunch of reading of Documentation/controllers/memory.txt
> to even start to understand what the purpose of this was.  The
> document could also use a re-writing to include a clear introduction
> at the top to explain "what" a memory controller is.  
> 
> Something which talks about limits, resource management, quotas, etc
> would be nice.  
> 


The references, specially reference [1] contains a lot of details on limits,
guarantees, etc.  Since they've been documented in the past on lkml, I decided
to keep them out of the documentation and mention them as references. If it's
going to help to add that terminology; I can create another document describing
what resource management means and what the commonly used terms mean.

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
