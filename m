Date: Thu, 1 Mar 2007 16:44:42 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 1 Mar 2007, Andrew Morton wrote:
> 
> So some urgent questions are: how are we going to do mem hotunplug and
> per-container RSS?

Also: how are we going to do this in virtualized environments? Usually the 
people who care abotu memory hotunplug are exactly the same people who 
also care (or claim to care, or _will_ care) about virtualization.

My personal opinion is that while I'm not a huge fan of virtualization, 
these kinds of things really _can_ be handled more cleanly at that layer, 
and not in the kernel at all. Afaik, it's what IBM already does, and has 
been doing for a while. There's no shame in looking at what already works, 
especially if it's simpler.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
