Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705171029500.17245@schroedinger.engr.sgi.com>
References: <1179350433.2912.66.camel@lappy>
	 <Pine.LNX.4.64.0705161435110.11642@schroedinger.engr.sgi.com>
	 <1179386921.27354.29.camel@twins>
	 <Pine.LNX.4.64.0705171029500.17245@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 17 May 2007 19:53:50 +0200
Message-Id: <1179424430.2925.7.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-17 at 10:30 -0700, Christoph Lameter wrote:
> On Thu, 17 May 2007, Peter Zijlstra wrote:
> 
> > > 2. It seems to be based on global ordering of allocations which is
> > >    not possible given large systems and the relativistic constraints
> > >    of physics. Ordering of events get more expensive the bigger the
> > >    system is.
> > > 
> > >    How does this system work if you can just order events within
> > >    a processor? Or within a node? Within a zone?
> > 
> > /me fails again..
> > 
> > Its about ensuring ALLOC_NO_WATERMARKS memory only reaches PF_MEMALLOC
> > processes, not joe random's pi calculator.
> 
> Watermarks are per zone?

Yes, but the page allocator might address multiple zones in order to
obtain a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
