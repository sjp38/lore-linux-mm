Date: Mon, 20 Aug 2007 12:15:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1187581894.6114.169.camel@twins>
Message-ID: <Pine.LNX.4.64.0708201210440.29092@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <20070815122253.GA15268@wotan.suse.de>
 <1187183526.6114.45.camel@twins>  <20070816032921.GA32197@wotan.suse.de>
 <1187581894.6114.169.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2007, Peter Zijlstra wrote:

> > > <> What Christoph is proposing is doing recursive reclaim and not
> > > initiating writeout. This will only work _IFF_ there are clean pages
> > > about. Which in the general case need not be true (memory might be
> > > packed with anonymous pages - consider an MPI cluster doing computation
> > > stuff). So this gets us a workload dependant solution - which IMHO is
> > > bad!
> > 
> > Although you will quite likely have at least a couple of MB worth of
> > clean program text. The important part of recursive reclaim is that it
> > doesn't so easily allow reclaim to blow all memory reserves (including
> > interrupt context). Sure you still have theoretical deadlocks, but if
> > I understand correctly, they are going to be lessened. I would be
> > really interested to see if even just these recursive reclaim patches
> > eliminate the problem in practice.
> 
> were we much bothered by the buffered write deadlock? - why accept a
> known deadlock if a solid solution is quite attainable?

Buffered write deadlock? How does that exactly occur? Memory allocation in 
the writeout path while we hold locks?

There are many worst case scenarios in the current reclaim implementation 
that are not addressed and we so far have not addressed these because the 
code is very sensitive and it is not clear that the complexity introduced 
by these changes is offset by the benefits gained.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
