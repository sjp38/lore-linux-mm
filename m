Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE56B009E
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:55:36 -0400 (EDT)
Date: Tue, 22 Sep 2009 13:55:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090922125546.GA25965@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1> <20090921180739.GT12726@csn.ul.ie> <4AB85A8F.6010106@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4AB85A8F.6010106@in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 10:33:11AM +0530, Sachin Sant wrote:
> Mel Gorman wrote:
>> On Mon, Sep 21, 2009 at 01:54:12PM -0400, Christoph Lameter wrote:
>>   
>>> Lets just keep SLQB back until the basic issues with memoryless nodes are
>>> resolved.
>>>     
>>
>> It's not even super-clear that the memoryless nodes issues are entirely
>> related to SLQB. Sachin for example says that there was a stall issue
>> with memoryless nodes that could be triggered without SLQB. Sachin, is
>> that still accurate?
>>   
> I think there are two different problems that we are dealing with.
>
> First one is the SLQB not working on a ppc64 box which seems to be specific
> to only one machine and i haven't seen that on other power boxes.The patches
> that you have posted seems to allow the box to boot, but eventually it hits
> the stall issue(related to percpu dynamic allocator not working on ppc64),
> which is the second problem we are dealing with.
>

Ok, I've sent out V3 of this. It's only a partial fix but it's about as
far as it can be brought until the other difficulties are resolved.

> The stall issue seems to be much more critical as it is affecting almost
> all of the power boxes that i have tested with (4 in all).
> This issue is seen with Linus tree as well and was first seen with
> 2.6.31-git5 (0cb583fd..) 
>
> The stall issue was reported here:
> http://lists.ozlabs.org/pipermail/linuxppc-dev/2009-September/075791.html
>

Can you bisect this please?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
