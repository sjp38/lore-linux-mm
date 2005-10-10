Date: Mon, 10 Oct 2005 17:26:14 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Benchmarks to exploit LRU deficiencies
Message-ID: <20051010202614.GB15631@logos.cnet>
References: <20051010184636.GA15415@logos.cnet> <200510110213.29937.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510110213.29937.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 11, 2005 at 02:13:29AM +0200, Andi Kleen wrote:
> On Monday 10 October 2005 20:46, Marcelo Tosatti wrote:
> > Hi,
> >
> > There are a few experimental implementations of advanced replacement
> > algorithms being developed and discussed. Unfortunately, there is lack of
> > knowledge on how to properly test them.
> 
> I think if you want to really see advantages you should not implement
> the advanced algorithms for the page cache, but for the inode/dentry
> cache. 

The major problem I can see is that of page versus icache/dcache 
"unused" list ordering and fragmentation, which is why we're trying
to aim at entire pages.

But other than that it works fine AFAIK.

> We seem to have far more problems in this area than with the
> standard page cache.

How's that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
