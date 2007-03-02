Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l22DroA17626794
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:53:51 -0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l221u0tw162994
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:56:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l221qT7U023594
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:52:30 +1100
Message-ID: <45E7835A.8000908@in.ibm.com>
Date: Fri, 02 Mar 2007 07:22:26 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> On Thu, 1 Mar 2007, Andrew Morton wrote:
>> So some urgent questions are: how are we going to do mem hotunplug and
>> per-container RSS?
> 
> Also: how are we going to do this in virtualized environments? Usually the 
> people who care abotu memory hotunplug are exactly the same people who 
> also care (or claim to care, or _will_ care) about virtualization.
> 
> My personal opinion is that while I'm not a huge fan of virtualization, 
> these kinds of things really _can_ be handled more cleanly at that layer, 
> and not in the kernel at all. Afaik, it's what IBM already does, and has 
> been doing for a while. There's no shame in looking at what already works, 
> especially if it's simpler.

Could you please clarify as to what "that layer" means - is it the
firmware/hardware for virtualization? or does it refer to user space?
With virtualization the linux kernel would end up acting as a hypervisor
and resource management support like per-container RSS support needs to
be built into the kernel.

It would also be useful to have a resource controller like per-container
RSS control (container refers to a task grouping) within the kernel or
non-virtualized environments as well.

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
