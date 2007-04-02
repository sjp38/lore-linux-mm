Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32L8BNa032669
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 17:08:11 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32L8Bxt031572
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:08:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32L8AmX019955
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:08:11 -0600
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
	 <200704011246.52238.ak@suse.de>
	 <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
	 <1175544797.22373.62.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 14:08:06 -0700
Message-Id: <1175548086.22373.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 13:30 -0700, Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Dave Hansen wrote:
> > I completely agree, it looks like it should be faster.  The code
> > certainly has potential benefits.  But, to add this neato, apparently
> > more performant feature, we unfortunately have to add code.  Adding the
> > code has a cost: code maintenance.  This isn't a runtime cost, but it is
> > a real, honest to goodness tradeoff.
> 
> Its just the opposite. The vmemmap code is so efficient that we can remove 
> lots of other code and gops of these alternate implementations.

We do want to make sure that there isn't anyone relying on these.  Are
you thinking of simple sparsemem vs. extreme vs. sparsemem vmemmap?  Or,
are you thinking of sparsemem vs. discontig?

> On x86_64 
> its even superior to FLATMEM since FLATMEM still needs a memory reference 
> for the mem_map area. So if we make SPARSE standard for all 
> configurations then there is no need anymore for FLATMEM DISCONTIG etc 
> etc. Can we not cleanup all this mess? Get rid of all the gazillions 
> of #ifdefs please? This would ease code maintenance significantly. I hate 
> having to constantly navigate my way through all the alternatives.

Amen, brother.  I'd love to see DISCONTIG die, with sufficient testing,
of course.  Andi, do you have any ideas on how to get sparsemem out of
the 'experimental' phase?

I have noticed before that sparsemem should be able to cover the flatmem
case if we make MAX_PHYSMEM_BITS == SECTION_SIZE_BITS and massage from
there.  
 
-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
