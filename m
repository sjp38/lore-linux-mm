Date: Sun, 1 Oct 2006 23:48:58 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061001234858.fe91109e.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

David wrote:
> It would be nice to be able to scale this so that the speed-up works 
> efficiently for numa=fake=256 (after NODES_SHIFT is increased from 6 to 8 
> on x86_64).

I'm not sure what you have in mind by "scale this."

We have a linear search of zones ... my speedup just changes the
constant multiplier, by converting that search from one that takes
one or two cache lines per node, to one that takes an unsigned
short, from compact array, per node.

This speedup should apply regardless of how many nodes (fake or
real or mixed) are present.

The fake node case is more interesting, because the usage pattern
it anticipates, with many, even most, of a long string of nodes
full during ordinary operation, stresses this linear scan more.

But whatever benefit this proposal has should be independent of the
value of NODES_SHIFT.

The systems I care most about, ia64 sn2, are already running with a
default NODES_SHIFT of 10.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
