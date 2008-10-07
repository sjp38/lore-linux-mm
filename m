Date: Tue, 7 Oct 2008 09:53:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Message-ID: <20081007075309.GA16143@wotan.suse.de>
References: <20081007064834.GA5959@wotan.suse.de> <20081007070225.GB5959@wotan.suse.de> <20081007071827.GB5010@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081007071827.GB5010@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 07, 2008 at 03:18:27AM -0400, Christoph Hellwig wrote:
> > 
> > I'm cc'ing netdev because Dave did express some interest in using this for
> > some networking hashes, and network guys in general are pretty cluey when it
> > comes to hashes and such ;)
> 
> Without even looking at the code I'd say geeting the dcache lookup data
> structure as a hash is the main problem here.  Dcache lookup is
> fundamentally a tree lookup, with some very nice domain splits
> (superblocks or directories).

Dcache lookup is partially a tree lookup, but also how do you look up
entries in a given directory? That is not naturally a tree lookup. Could
be a per directory tree, though, or a hash, or trie.

Anyway, I don't volunteer to change that just yet ;)


>  Mapping these back to a global hash is
> a rather bad idea, not just for scalability purposes.

I don't disagree. But it can be improved by dynamically resizing
until it is replaced. I guess it is also a demonstration of how to
implement the algorithm.

PID hash is probably another good one to convert.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
