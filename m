Date: Fri, 26 Jan 2007 16:58:40 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Christoph Lameter wrote:

> Unmovable allocations in the movable zone. Yuck.

I know, but my objective at this time is to allow the hugepage pool to be 
resized at runtime for situations where the number of required hugepages 
is not known in advance. Having a zone for movable pages allows that to 
happen. Also, it's possible that migration of hugepages will be supported 
at some time in the future. That's a more reasonable possibility than 
moving kernel memory.

> Why dont you abandon the
> whole concept of statically sized movable zone and go back to the nice
> earlier idea of dynamically assigning MAX_ORDER chunks to be movable or not?
>

Because Andrew has made it pretty clear he will not take those patches on 
the grounds of complexity - at least until it can be shown that they fix 
the e1000 problem. Any improvement on the behavior of those patches such 
as address biasing to allow memory hot-remove of the higher addresses 
makes them even more complex.

Also, almost every time the anti-frag patches are posted, someone suggests 
that zones be used instead. I wanted to show what those patches look like.
(of course, every time I post the zone approach, someone suggests I go 
back the other way)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
