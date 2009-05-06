Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5546B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 15:21:33 -0400 (EDT)
Date: Wed, 6 May 2009 20:20:35 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap
	has unexpected holes
Message-ID: <20090506192035.GB21993@n2100.arm.linux.org.uk>
References: <20090505082944.GA25904@csn.ul.ie> <20090505110653.GA16649@cmpxchg.org> <20090506143059.GB20709@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090506143059.GB20709@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 03:31:00PM +0100, Mel Gorman wrote:
> On Tue, May 05, 2009 at 01:06:53PM +0200, Johannes Weiner wrote:
> > I think we also need to fix up show_mem(). 
> 
> As it turns out, ARM has its own show_mem(). I don't see how, but ARM
> must not be using lib/show_mem.c even though it compiles it.

That happens because lib/show_mem.c is a library file, and since there
isn't an unresolved reference to show_mem in from within the object
files ld is asked to link, the version in the .a library won't be
brought in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
