Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DC5246B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 06:53:37 -0400 (EDT)
Date: Sat, 10 Oct 2009 12:53:33 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091010105333.GR9228@kernel.dk>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009143124.1241a6bc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091009143124.1241a6bc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 09 2009, Andrew Morton wrote:
> On Fri, 9 Oct 2009 14:29:52 +0200
> Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> > On Fri, Oct 09 2009, Peter Zijlstra wrote:
> > > On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
> > > > From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> > > > 
> > > > On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
> > > > and can be configured per block device queue.
> > > > On the other hand a lot of admins do not use it, therefore it is reasonable to
> > > > set a wise default.
> > > > 
> > > > This path allows to configure the value via Kconfig mechanisms and therefore
> > > > allow the assignment of different defaults dependent on other Kconfig symbols.
> > > > 
> > > > Using this, the patch increases the default max readahead for s390 improving
> > > > sequential throughput in a lot of scenarios with almost no drawbacks (only
> > > > theoretical workloads with a lot concurrent sequential read patterns on a very
> > > > low memory system suffer due to page cache trashing as expected).
> > > 
> > > Why can't this be solved in userspace?
> > > 
> > > Also, can't we simply raise this number if appropriate? Wu did some
> > > read-ahead trashing detection bits a long while back which should scale
> > > the read-ahead window back when we're low on memory, not sure that ever
> > > made it in, but that sounds like a better option than having different
> > > magic numbers for each platform.
> > 
> > Agree, making this a config option (and even defaulting to a different
> > number because of an arch setting) is crazy.
> 
> Given the (increasing) level of disparity between different kinds of
> storage devices, having _any_ default is crazy.

You have to start somewhere :-). 0 is a default, too.

> Would be better to make some sort of vaguely informed guess at
> runtime, based upon the characteristics of the device.

I'm pretty sure the readahead logic already does respond to eg memory
pressure, not sure if it attempts to do anything based on how quickly
the device is doing IO. Wu?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
