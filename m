Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1276B004F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:49:57 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id n99Dnrr1024674
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 13:49:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n99Dnrls3383360
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 15:49:53 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n99DnraV023066
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 15:49:53 +0200
Date: Fri, 9 Oct 2009 15:49:50 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com>
In-Reply-To: <20091009122952.GI9228@kernel.dk>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
	<1255090830.8802.60.camel@laptop>
	<20091009122952.GI9228@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009 14:29:52 +0200
Jens Axboe <jens.axboe@oracle.com> wrote:

> On Fri, Oct 09 2009, Peter Zijlstra wrote:
> > On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
> > > From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> > > 
> > > On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
> > > and can be configured per block device queue.
> > > On the other hand a lot of admins do not use it, therefore it is reasonable to
> > > set a wise default.
> > > 
> > > This path allows to configure the value via Kconfig mechanisms and therefore
> > > allow the assignment of different defaults dependent on other Kconfig symbols.
> > > 
> > > Using this, the patch increases the default max readahead for s390 improving
> > > sequential throughput in a lot of scenarios with almost no drawbacks (only
> > > theoretical workloads with a lot concurrent sequential read patterns on a very
> > > low memory system suffer due to page cache trashing as expected).
> > 
> > Why can't this be solved in userspace?
> > 
> > Also, can't we simply raise this number if appropriate? Wu did some
> > read-ahead trashing detection bits a long while back which should scale
> > the read-ahead window back when we're low on memory, not sure that ever
> > made it in, but that sounds like a better option than having different
> > magic numbers for each platform.
> 
> Agree, making this a config option (and even defaulting to a different
> number because of an arch setting) is crazy.

The patch from Christian fixes a performance regression in the latest
distributions for s390. So we would opt for a larger value, 512KB seems
to be a good one. I have no idea what that will do to the embedded
space which is why Christian choose to make it configurable. Clearly
the better solution would be some sort of system control that can be
modified at runtime. 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
