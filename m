Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QNWHf7006886
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 18:32:17 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QNUTeQ270224
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:30:29 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QNWHqH032027
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:32:17 -0700
Message-ID: <43D95BFE.4010705@us.ibm.com>
Date: Thu, 26 Jan 2006 15:32:14 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 0/9] Critical Mempools
References: <1138217992.2092.0.camel@localhost.localdomain> <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com> <43D954D8.2050305@us.ibm.com> <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 26 Jan 2006, Matthew Dobson wrote:
> 
> 
>>>All subsystems will now get more complicated by having to add this 
>>>emergency functionality?
>>
>>Certainly not.  Only subsystems that want to use emergency pools will get
>>more complicated.  If you have a suggestion as to how to implement a
>>similar feature that is completely transparent to its users, I would *love*
> 
> 
> I thought the earlier __GFP_CRITICAL was a good idea.

Well, I certainly could have used that feedback a month ago! ;)  The
general response to that patchset was overwhelmingly negative.  Yours is
the first vote in favor of that approach, that I'm aware of.


>>to hear it.  I have tried to keep the changes to implement this
>>functionality to a minimum.  As the patches currently stand, existing slab
>>allocator and mempool users can continue using these subsystems without
>>modification.
> 
> 
> The patches are extensive and the required changes to subsystems in order 
> to use these pools are also extensive.

I can't really argue with your first point, but the changes required to use
the pools should actually be quite small.  Sridhar (cc'd on this thread) is
working on the changes required for the networking subsystem to use these
pools, and it looks like the patches will be no larger than the ones from
the last attempt.


>>>There surely must be a better way than revising all subsystems for 
>>>critical allocations.
>>
>>Again, I could not find any way to implement this functionality without
>>forcing the users of the functionality to make some, albeit very minor,
>>changes.  Specific suggestions are more than welcome! :)
> 
> 
> Gfp flag? Better memory reclaim functionality?

Well, I've got patches that implement the GFP flag approach, but as I
mentioned above, that was poorly received.  Better memory reclaim is a
broad and general approach that I agree is useful, but will not necessarily
solve the same set of problems (though it would likely lessen the severity
somewhat).

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
