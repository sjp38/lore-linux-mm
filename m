Date: Sun, 21 Mar 2004 23:02:03 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
 fix
In-Reply-To: <Pine.LNX.4.58.0403212241120.8267@rust.engin.umich.edu>
Message-ID: <Pine.LNX.4.44.0403212258530.20045-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: Andrea Arcangeli <andrea@suse.de>, akpm@osdl.org, torvalds@osdl.org, hugh@veritas.com, mbligh@aracnet.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Mar 2004, Rajesh Venkatasubramanian wrote:

> > what about the cost of a tree rebalance, is that O(log(N)) like with the
> > rbtrees?
> 
> Currently the tree is not balanced, so the tree can be totally skewed
> in some corner cases. However, the maximum height of the tree can be
> only 2 * BITS_PER_LONG.

Fair enough for a radix tree.  Andrea, remember that page
tables don't need to be balanced either, for obvious reasons ;)

> Moreover, I have added an optimization to increase the maximum height
> of the tree on demand. The tree height is controlled by keeping track
> of the maximum file offset mapped. If the number of bits required to
> represent the maximum file offset is B, then the height of the tree
> can be only 2 * B.

Nice touch.  That should really help keep the cost of the
prio_tree down in the common case.

Your stuff is so much nicer than the kb-trees I was thinking
about a year or two ago ... ;)


-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
