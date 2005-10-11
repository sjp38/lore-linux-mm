Date: Mon, 10 Oct 2005 21:04:00 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Benchmarks to exploit LRU deficiencies
In-Reply-To: <200510110213.29937.ak@suse.de>
Message-ID: <Pine.LNX.4.63.0510102102260.20944@cuia.boston.redhat.com>
References: <20051010184636.GA15415@logos.cnet> <200510110213.29937.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Tue, 11 Oct 2005, Andi Kleen wrote:

> I think if you want to really see advantages you should not implement
> the advanced algorithms for the page cache,

I suspect the page cache really wants it too, especially
for database workloads.

> but for the inode/dentry cache. We seem to have far more problems in 
> this area than with the standard page cache.

However, I agree with you that the inode/dentry cache
probably needs it more on file and web server workloads.

The page cache getting invalidated whole inodes at a
time, even when the inode is getting referenced frequently,
could be a performance problem on some systems.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
