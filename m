Date: Mon, 10 Oct 2005 20:21:04 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Benchmarks to exploit LRU deficiencies
Message-ID: <20051010232104.GB4946@logos.cnet>
References: <20051010184636.GA15415@logos.cnet> <200510110213.29937.ak@suse.de> <20051010202614.GB15631@logos.cnet> <200510110241.42225.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510110241.42225.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 11, 2005 at 02:41:41AM +0200, Andi Kleen wrote:
> On Monday 10 October 2005 22:26, Marcelo Tosatti wrote:
> 
> > But other than that it works fine AFAIK.
> 
> I don't think so.
> 
> >
> > > We seem to have far more problems in this area than with the
> > > standard page cache.
> >
> > How's that?
> 
> At least in many cases where i've seen machines becomming unusable
> the problem was dcache/inode pollution, not page cache getting
> unbalanced.
> 
> Good example is running rsync.

You mean rsync kicks out your pagecache working set?

How come the machine is unusable?

How can the problem be reproduced? Run rsync is too vague I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
