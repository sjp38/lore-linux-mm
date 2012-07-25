Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CB40B6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 18:30:59 -0400 (EDT)
Date: Wed, 25 Jul 2012 15:30:57 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
Message-ID: <20120725223057.GA4253@kroah.com>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 23, 2012 at 02:38:13PM +0100, Mel Gorman wrote:
> Changelog since V1
>   o Expand some of the notes					(jrnieder)
>   o Correct upstream commit SHA1				(hugh)
> 
> This series is related to the new addition to stable_kernel_rules.txt
> 
>  - Serious issues as reported by a user of a distribution kernel may also
>    be considered if they fix a notable performance or interactivity issue.
>    As these fixes are not as obvious and have a higher risk of a subtle
>    regression they should only be submitted by a distribution kernel
>    maintainer and include an addendum linking to a bugzilla entry if it
>    exists and additional information on the user-visible impact.
> 
> All of these patches have been backported to a distribution kernel and
> address some sort of performance issue in the VM. As they are not all
> obvious, I've added a "Stable note" to the top of each patch giving
> additional information on why the patch was backported. Lets see where
> the boundaries lie on how this new rule is interpreted in practice :).
> 
> Patch 1	Performance fix for tmpfs
> Patch 2 Memory hotadd fix
> Patch 3 Reduce boot time on large machines
> Patches 4-5 Reduce stalls for wait_iff_congested
> Patches 6-8 Reduce excessive reclaim of slab objects which for some workloads
> 	will reduce the amount of IO required
> Patches 9-10 limits the amount of page reclaim when THP/Compaction is active.
> 	Excessive reclaim in low memory situations can lead to stalls some
> 	of which are user visible.
> Patches 11-19 reduce the amount of churn of the LRU lists. Poor reclaim
> 	decisions can impair workloads in different ways and there have
> 	been complaints recently the reclaim decisions of modern kernels
> 	are worse than older ones.
> Patches 20-21 reduce the amount of CPU kswapd uses in some cases. This
> 	is harder to trigger but were developed due to bug reports about
> 	100% CPU usage from kswapd.
> Patches 22-25 are mostly related to interactivity when THP is enabled.
> Patches 26-30 are also related to page reclaim decisions, particularly
> 	the residency of mapped pages.
> Patches 31-34 fix a major page allocator performance regression
> 
> All of the patches will apply to 3.0-stable but the ordering of the
> patches is such that applying them to 3.2-stable and 3.4-stable should
> be straight-forward.

I can't find any of these that should have gone to 3.4-stable, given
that they all were included in 3.4 already, right?

I've queued up the whole lot for the 3.0-stable tree, thanks so much for
providing them.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
