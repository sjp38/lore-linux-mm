Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5207EhM009866
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 20:07:14 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5207ELI196266
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 20:07:14 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5207ELU030822
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 20:07:14 -0400
Date: Wed, 1 Jun 2005 17:07:11 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
Message-ID: <20050602000711.GA7910@w-mikek2.ibm.com>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <20050601234730.GF3998@w-mikek2.ibm.com> <429E4B22.5080404@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <429E4B22.5080404@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: jschopp@austin.ibm.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 02, 2005 at 09:56:18AM +1000, Nick Piggin wrote:
> Mike Kravetz wrote:
> >Allocating lots of MAX_ORDER blocks can be very useful for things
> >like hot-pluggable memory.  I know that this may not be of interest
> >to most.  However, I've been combining Mel's defragmenting patch
> >with the memory hotplug patch set.  As a result, I've been able to
> >go from 5GB down to 544MB of memory on my ppc64 system via offline
> >operations.  Note that ppc64 only employs a single (DMA) zone.  So,
> >page 'grouping' based on use is coming mainly from Mel's patch.
> >
> 
> Back in the day, Linus would tell you to take a hike if you
> wanted to complicate the buddy allocator to better support
> memory hotplug ;)
> 
> I don't know what's happened to him now though, he seems to
> have gone a little soft on you enterprise types.
> 
> Seriously - thanks for the data point, I had an idea that you
> guys wanted this for mem hotplug.

Mel wrote the patch independent of the mem hotplug effort.  As
part of the hotplug effort, we knew fragmentation needed to be
addressed.  So, when Mel released his patch we jumped all over
it.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
