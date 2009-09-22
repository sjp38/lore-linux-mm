Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88EFA6B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 01:03:27 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8M53C2x028231
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:33:12 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8M53CeQ2031822
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:33:12 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8M53BRA028285
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 15:03:12 +1000
Message-ID: <4AB85A8F.6010106@in.ibm.com>
Date: Tue, 22 Sep 2009 10:33:11 +0530
From: Sachin Sant <sachinp@in.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1> <20090921180739.GT12726@csn.ul.ie>
In-Reply-To: <20090921180739.GT12726@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Mon, Sep 21, 2009 at 01:54:12PM -0400, Christoph Lameter wrote:
>   
>> Lets just keep SLQB back until the basic issues with memoryless nodes are
>> resolved.
>>     
>
> It's not even super-clear that the memoryless nodes issues are entirely
> related to SLQB. Sachin for example says that there was a stall issue
> with memoryless nodes that could be triggered without SLQB. Sachin, is
> that still accurate?
>   
I think there are two different problems that we are dealing with.

First one is the SLQB not working on a ppc64 box which seems to be specific
to only one machine and i haven't seen that on other power boxes.The patches
that you have posted seems to allow the box to boot, but eventually it hits
the stall issue(related to percpu dynamic allocator not working on ppc64),
which is the second problem we are dealing with.

The stall issue seems to be much more critical as it is affecting almost
all of the power boxes that i have tested with (4 in all).
This issue is seen with Linus tree as well and was first seen with
2.6.31-git5 (0cb583fd..) 

The stall issue was reported here:
http://lists.ozlabs.org/pipermail/linuxppc-dev/2009-September/075791.html

Thanks
-Sachin


> If so, it's possible that SLQB somehow exasperates the problem in some
> unknown fashion.
>
>   
>> There does not seem to be an easy way to deal with this. Some
>> thought needs to go into how memoryless node handling relates to per cpu
>> lists and locking. List handling issues need to be addressed before SLQB.
>> can work reliably. The same issues can surface on x86 platforms with weird
>> NUMA memory setups.
>>
>>     
>
> Can you spot if there is something fundamentally wrong with patch 2? I.e. what
> is wrong with treating the closest node as local instead of only the
> closest node?
>
>   
>> Or just allow SLQB for !NUMA configurations and merge it now.
>>
>>     
>
> Forcing SLQB !NUMA will not rattle out any existing list issues
> unfortunately :(.
>
>   


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
