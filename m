Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D37F16B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 21:11:21 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so5222574pad.7
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 18:11:21 -0800 (PST)
Date: Thu, 24 Jan 2013 10:11:08 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
Message-ID: <20130124021108.GB32496@kernel.org>
References: <766b9855-adf5-47ce-9484-971f88ff0e54@default>
 <e59b7d62-67f5-4afb-8c8e-d422d3e82832@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e59b7d62-67f5-4afb-8c8e-d422d3e82832@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: shli@fusionio.com, linux-mm@kvack.org

On Wed, Jan 23, 2013 at 03:05:22PM -0800, Dan Magenheimer wrote:
> I would be very interested in this topic.
> 
> > Because of high density, low power and low price, flash storage (SSD) is a good
> > candidate to partially replace DRAM. A quick answer for this is using SSD as
> > swap. But Linux swap is designed for slow hard disk storage. There are a lot of
> > challenges to efficiently use SSD for swap:
> > 
> > 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> > 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
> > overhead is very high even in a normal 2-socket machine.
> > 3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
> > which makes swap IO pattern is interleave. Block layer isn't always efficient
> > to do request merge. Such IO pattern also makes swap prefetch hard.
> 
> Shaohua --
> 
> Have you considered the possibility of subverting the block layer entirely
> and accessing the SSD like slow RAM rather than a fast I/O device?  E.g.
> something like NVME and as in this paper?
> 
> http://static.usenix.org/events/fast12/tech/full_papers/Yang.pdf 
> 
> If you think this could be an option, it could make a very
> interesting backend to frontswap (something like ramster).

We had discussion about this before, but looks this requires very low latency
storage, didn't take it serious yet.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
