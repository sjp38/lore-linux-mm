Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1HLWahT018156
	for <linux-mm@kvack.org>; Fri, 17 Feb 2006 16:32:36 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1HLWaVT216856
	for <linux-mm@kvack.org>; Fri, 17 Feb 2006 16:32:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1HLWab9007891
	for <linux-mm@kvack.org>; Fri, 17 Feb 2006 16:32:36 -0500
Message-ID: <43F640AC.6060600@austin.ibm.com>
Date: Fri, 17 Feb 2006 15:31:24 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] ppc64 - Specify amount of kernel memory at boot	time
References: <20060217141552.7621.74444.sendpatchset@skynet.csn.ul.ie>	 <20060217141712.7621.49906.sendpatchset@skynet.csn.ul.ie> <1140196618.21383.112.camel@localhost.localdomain>
In-Reply-To: <1140196618.21383.112.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

>> This patch adds the kernelcore= parameter for ppc64.
>>
>> The amount of memory will requested will not be reserved in all nodes. The
>> first node that is found that can accomodate the requested amount of memory
>> and have remaining more for ZONE_EASYRCLM is used. If a node has memory holes,
>> it also will not be used.
> 
> One thing I think we really need to see before these go into mainline is
> the ability to shrink the ZONE_EASYRCLM at runtime, and give the memory
> back to NORMAL/DMA.
> 
> Otherwise, any system starting off sufficiently small will end up having
> lowmem starvation issues.  Allowing resizing at least gives the admin a
> chance to avoid those issues.
> 

I'm not too keen on calling it resizing, because that term is 
misleading.  The resizing is one way.  You can't later resize back. It's 
like a window that you can only close but never reopen.  We should call 
it "runtime incremental disabling", or RID.

I don't think we need RID in order to merge these patches.  RID can be 
merged later if people decide they want a special easy reclaim zone that 
could disappear at any moment.  I personally fall in the camp of wanting 
my zones I explicitly enabled to stay put and am opposed to RID.

If only somebody had presented a solution that was flexible enough to 
dynamically resize reclaimable and non-reclaimable both ways.
http://sourceforge.net/mailarchive/message.php?msg_id=13864331




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
