Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kAHGkuwg018860
	for <linux-mm@kvack.org>; Sat, 18 Nov 2006 03:46:56 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAHGbewu213622
	for <linux-mm@kvack.org>; Sat, 18 Nov 2006 03:38:00 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAHGYEx5009958
	for <linux-mm@kvack.org>; Sat, 18 Nov 2006 03:34:14 +1100
Message-ID: <455DE480.7000500@in.ibm.com>
Date: Fri, 17 Nov 2006 22:04:08 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH 5/8] RSS controller task migration	support
References: <20061117132533.A5FCF1B6A2@openx4.frec.bull.fr>
In-Reply-To: <20061117132533.A5FCF1B6A2@openx4.frec.bull.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Patrick.Le-Dot" <Patrick.Le-Dot@bull.net>
Cc: ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Patrick.Le-Dot wrote:
>> ...
>> For implementing guarantees, we can use limits. Please see
>> http://wiki.openvz.org/Containers/Guarantees_for_resources.
> 
> Nack.
> 
> This seems to be correct for resources like cpu, disk or network
> bandwidth but not for the memory just because nobody in this wiki
> speaks about the kswapd and page reclaim (but it's true that a such
> demon does not exist for cpu, disk or... then the problem is more
> simple).
> 
> For a customer the main reason to use guarantee is to be sure that
> some pages of a job remain in memory when the system is low on free
> memory. This should be true even for a job in group/container A with
> a smooth activity compared to a group/container B with a set of jobs
> using memory more agressively...
> 

I am not against guarantees, but

Consider the following scenario, let's say we implement guarantees

1. If we account for kernel resources, how do you provide guarantees
   when you have non-reclaimable resources?
2. If a customer runs a system with swap turned off (which is quite
   common), then anonymous memory becomes irreclaimable. If a group
   takes more than it's fair share (exceeds its guarantee), you
   have scenario similar to 1 above.

> What happens if we use limits to implement guarantees ?
> 
>>> ...
>>> The idea of getting a guarantee is simple:
>>> if any group gi requires a Gi units of resource from R units available
>>> then limiting all the rest groups with R - Gi units provides a desired
>>> guarantee
> 
> If the limit is a "hard limit" then we have implemented reservation and
> this is too strict.
>
> If the limit is a "soft limit" then group/container B is autorized to
> use more than the limit and nothing is guaranteed for group/container A...
> 
> Patrick


Yes, but it is better than failing to meet a guarantee (if guarantees are
desired :))


-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
