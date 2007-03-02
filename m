Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l224Z5vA304400
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 15:35:05 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l224MEne184240
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 15:22:14 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l224Igmm029715
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 15:18:43 +1100
Message-ID: <45E7A59E.6020004@in.ibm.com>
Date: Fri, 02 Mar 2007 09:48:38 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Fri, 2 Mar 2007, Balbir Singh wrote:
>>> My personal opinion is that while I'm not a huge fan of virtualization,
>>> these kinds of things really _can_ be handled more cleanly at that layer,
>>> and not in the kernel at all. Afaik, it's what IBM already does, and has
>>> been doing for a while. There's no shame in looking at what already works,
>>> especially if it's simpler.
>> Could you please clarify as to what "that layer" means - is it the
>> firmware/hardware for virtualization? or does it refer to user space?
> 
> Virtualization in general. We don't know what it is - in IBM machines it's 
> a hypervisor. With Xen and VMware, it's usually a hypervisor too. With 
> KVM, it's obviously a host Linux kernel/user-process combination.
> 

Thanks for clarifying.

> The point being that in the guests, hotunplug is almost useless (for 
> bigger ranges), and we're much better off just telling the virtualization 
> hosts on a per-page level whether we care about a page or not, than to 
> worry about fragmentation.
> 
> And in hosts, we usually don't care EITHER, since it's usually done in a 
> hypervisor.
> 
>> It would also be useful to have a resource controller like per-container
>> RSS control (container refers to a task grouping) within the kernel or
>> non-virtualized environments as well.
> 
> .. but this has again no impact on anti-fragmentation.
> 

Yes, I agree that anti-fragmentation and resource management are independent
of each other. I must admit to being a bit selfish here, in that my main
interest is in resource management and we would love to see a well
written  and easy to understand resource management infrastructure and 
controllers to control CPU and memory usage. Since the issue of
per-container RSS control came up, I wanted to ensure that we do not mix
up resource control and anti-fragmentation.

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
