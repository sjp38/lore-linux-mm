Date: Sun, 17 Sep 2006 06:06:02 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917060602.3207ae15.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609170533140.14453@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
	<20060916083825.ba88eee8.akpm@osdl.org>
	<20060916145117.9b44786d.pj@sgi.com>
	<20060916161031.4b7c2470.akpm@osdl.org>
	<Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
	<20060916215545.32fba5c7.akpm@osdl.org>
	<Pine.LNX.4.64.0609170533140.14453@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> What you are doing is using nodes to partition memory into small chunks
> that are then collected in a cpuset. That is not the way how nodes
> or cpusets were designed to work.

Agreed, and a tad frustrating.

However, in Andrew's favor, he has discovered that despite our best
design efforts, this node/cpuset/... stuff actually does work "out
of the box" when (ab)used in this strange fashion.

Except for one performance glitch, where a loop in the routine
get_page_from_freelist() loops too many times, he's got the makings
of memory containers 'for free.'

If he could just get the performance of that loop in this fake NUMA
setup from linear in the number of filled up fake nodes, back to a
small constant, he'd be good to go with this new mechanism.

The only useful part of this debate is how many words of cached data
per something (cpu, cpuset, node, zonelist, task, ...)  it will take
to get this loop cost back to a small constant, even when presented
with such a sorry excuse for a zonelist.

Andrew started at one word; I started at MAX_NUMNODES words.  I've got
him up to two words; he has me down to three words.

We're converging fast.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
