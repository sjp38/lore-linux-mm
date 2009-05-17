Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 493C96B004D
	for <linux-mm@kvack.org>; Sun, 17 May 2009 12:27:27 -0400 (EDT)
Date: Sun, 17 May 2009 17:27:01 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap
	has unexpected holes V2
Message-ID: <20090517162701.GB2664@n2100.arm.linux.org.uk>
References: <20090505082944.GA25904@csn.ul.ie> <20090505083614.GA28688@n2100.arm.linux.org.uk> <20090505084928.GC25904@csn.ul.ie> <20090513163448.GA18006@csn.ul.ie> <20090513124805.9c70c43c.akpm@linux-foundation.org> <20090514083947.GB16639@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090514083947.GB16639@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 09:39:47AM +0100, Mel Gorman wrote:
> It affected at least 2.6.28.4 so minimally, I'd like to see it in for 2.6.30.
> I think it's a -stable candidate but I'd like to hear from the ARM maintainer
> on whether he wants to push it or not to that tree.

I'm inclined to agree.

> > It applies OK to 2.6.28, 2.6.29, current mainline and mmotm, so I'll
> > just sit tight until I'm told what to do.
> > 
> 
> Please merge for 2.6.30 at least. Russell, are you ok with that? Are you ok
> with this being pushed to -stable?

I'll merge it into my master branch, which'll be going to Linus in the next
few days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
