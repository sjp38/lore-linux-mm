Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA1FXOkE021960
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 10:33:24 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA1FXOXg407508
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 08:33:24 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA1FXON0030134
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 08:33:24 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <45430000.1130858744@[10.10.2.4]>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie>
	 <20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au>
	 <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]>
	 <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet>
	 <4366C559.5090504@yahoo.com.au>  <45430000.1130858744@[10.10.2.4]>
Content-Type: text/plain
Date: Tue, 01 Nov 2005 16:33:13 +0100
Message-Id: <1130859193.14475.104.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-01 at 07:25 -0800, Martin J. Bligh wrote:
> > I really don't think we *want* to say we support higher order allocations
> > absolutely robustly, nor do we want people using them if possible. Because
> > we don't. Even with your patches.
> > 
> > Ingo also brought up this point at Ottawa.
> 
> Some of the driver issues can be fixed by scatter-gather DMA *if* the 
> h/w supports it. But what exactly do you propose to do about kernel
> stacks, etc? By the time you've fixed all the individual usages of it,
> frankly, it would be easier to provide a generic mechanism to fix the 
> problem ...

That generic mechanism is the kernel virtual remapping.  However, it has
a runtime performance cost, which is increased TLB footprint inside the
kernel, and a more costly implementation of __pa() and __va().

I'll admit, I'm biased toward partial solutions without runtime cost
before we start incurring constant cost across the entire kernel,
especially when those partial solutions have other potential in-kernel
users.

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
