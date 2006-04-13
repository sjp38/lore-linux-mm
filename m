Date: Thu, 13 Apr 2006 20:18:01 +0100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFD hugetlbfs] strict accounting and wasteful reservations
Message-ID: <20060413191801.GA9195@localhost.localdomain>
References: <1144949802.10795.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1144949802.10795.99.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 13, 2006 at 12:36:42PM -0500, Adam Litke wrote:
> Sorry to bring this up after the strict accounting patch was merged but
> things moved along a bit too fast for me to intervene.
> 
> In the thread beginning at http://lkml.org/lkml/2006/3/8/47 , a
> discussion was had to compare the patch from David Gibson (the patch
> that was ultimately merged) with an alternative patch from Ken Chen.
> The main functional difference is how we handle arbitrary file offsets
> into a hugetlb file.  The current patch reserves enough huge pages to
> populate the whole file up to the highest file offset in use.  Ken's
> patch supported arbitrary blocks.
> 
> For libhugetlbfs, we would like to have sparsely populated hugetlb files
> without wasting all the extra huge pages that the current implementation
> requires.  That aside, having yet another difference in behavior for
> hugetlbfs files (that isn't necessary) seems like a bad idea.

We would?  Why?

> So on to my questions.  Do people agree that supporting reservation for
> sparsely populated hugetlbfs files makes sense?
> 
> I've been hearing complaints about the code churn in hugetlbfs code
> lately, so is there a way to adapt what we currently have to support
> this?
> 
> Otherwise, should I (or Ken?) take a stab at resurrecting Ken's
> competing patch with the intent of eventually replacing the current
> code?

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
