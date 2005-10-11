Date: Tue, 11 Oct 2005 08:23:32 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Benchmarks to exploit LRU deficiencies
In-Reply-To: <200510110213.29937.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0510110820070.897@schroedinger.engr.sgi.com>
References: <20051010184636.GA15415@logos.cnet> <200510110213.29937.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Oct 2005, Andi Kleen wrote:

> I think if you want to really see advantages you should not implement
> the advanced algorithms for the page cache, but for the inode/dentry
> cache. We seem to have far more problems in this area than with the
> standard page cache.

We have had significant problems with the page cache for a long time. 
Systems slow down because node memory is filled up with page cache 
pages that are not properly reclaimed and thus off node allocation 
occurs. The current method of freeing memory requires a scan which 
makes this whole thing painfully slow. There are special hacks in SLES9 to 
deal with these issues.

Moreover the LRU algorithm leads to the eviction of important pages if a 
program does a simple scan of a large file.

I hope that the advanced page replacement methods address some of these 
problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
