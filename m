Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4VJM4ua355404
	for <linux-mm@kvack.org>; Tue, 31 May 2005 15:22:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4VJM4mm161546
	for <linux-mm@kvack.org>; Tue, 31 May 2005 13:22:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4VJM3Lg017390
	for <linux-mm@kvack.org>; Tue, 31 May 2005 13:22:03 -0600
Date: Tue, 31 May 2005 12:13:03 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [ckrm-tech] Virtual NUMA machine and CKRM
Message-ID: <20050531191303.GE29202@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050527.221613.78716667.taka@valinux.co.jp> <1117203358.18725.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1117203358.18725.12.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 27, 2005 at 07:15:58AM -0700, Dave Hansen wrote:
> On Fri, 2005-05-27 at 22:16 +0900, Hirokazu Takahashi wrote:
> > Why don't you implement CKRM memory controller as virtual NUMA
> > node.
> > 
> > I think what you want do is almost what NUMA code does, which
> > restricts resources to use. If you define virtual NUMA node with
> > some memory and some virtual CPUs, you can just assign target jobs
> > to them.
> > 
> > What do you think of my idea?
> 
> First of all, NUMA nodes don't have any balancing done on them, so I
> don't think they're an appropriate structure.  But, NUMA nodes *do*
> contain zones, which are a slightly more appropriate structure.
> 
> One thing I pointed out when he first posted this code was that a lot of
> the accounting gets shifted from the 'struct zone' to the ckrm class.
> It was appropriate to have a set of macros to set up and perform this
> indirection.
> 
> However, a 'struct zone' currently has more than one job.  It collects
> "like" pages together, it provides accounting for those pages, and it
> represents a contiguous area of memory.
> 
> If you could collect just the accounting pieces out of 'struct zone',
> perhaps those could be used by both ckrm classes, and the old 'struct
> zone'.

will look into it.

Thanks
> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
