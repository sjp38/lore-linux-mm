Date: Wed, 16 Jun 2004 17:53:00 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616165300.GA15411@infradead.org>
References: <20040616142413.GA5588@sgi.com> <200406161646.i5GGkO5e194114@theriver.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200406161646.i5GGkO5e194114@theriver.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lori Gilbertson <loriann@sgi.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, lm@bitmover.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 11:46:24AM -0500, Lori Gilbertson wrote:
> hch wrote:
> 
> > Given you're @sgi.com address you probably know what
> > a freaking mess and maintaince nightmare IRIX has become because 
> > of that.
> 
> Hi Chris,
> 
> I'm very curious about this comment - wondering what you base it
> on?  I'm the engineering manager for IRIX real-time - we have
> no open bugs against it and have many customers depending on it.
> At least for the last 5 years had very low maintenance cost,
> mostly adding features, fixing a couple of bugs and producing new 
> releases.  
> 
> Perhaps you would be so kind to let me know what led you to
> your statement?

Looks at the overhead of the normal IRIX sleeping locks vs linux spinlock
(and the priority inversion and sleeping locks arguments are the next one
I'll get from you I bet :)), talk to Jeremy how the HBA performance went
down when he had to switch the drivers to the sleeping locks, look at the
complexity of the irix scheduler with it's gazillions of special cases
(and yes, I think the current Linux scheduler is already to complex), or
the big mess with interrupt thread.  

I've added Larry to the Cc list because he knows the IRIX internals much
better than I do (or at least did once) and has been warning of this move
that adds complexity to no end for all the special cases for at least five
years.  He also had some nice IRIX vs Linux benchmarks when Linux on Indys
was new.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
