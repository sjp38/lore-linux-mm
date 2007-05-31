Date: Thu, 31 May 2007 10:39:14 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531073914.GA32365@minantech.com>
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com> <1180544104.5850.70.camel@localhost> <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com> <20070531061836.GL4715@minantech.com> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com> <20070531064753.GA31143@minantech.com> <Pine.LNX.4.64.0705302352590.6824@schroedinger.engr.sgi.com> <20070531071110.GB31143@minantech.com> <Pine.LNX.4.64.0705310021380.6969@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705310021380.6969@schroedinger.engr.sgi.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 12:24:06AM -0700, Christoph Lameter wrote:
> > > 2. Pagecache pages can be read and written by buffered I/O and
> > >    via mmap. Should there be different allocation semantics
> > >    depending on the way you got the page? Obviously no policy
> > >    for a memory range can be applied to a page allocated via
> > >    buffered I/O. Later it may be mapped via mmap but then
> > >    we never use policies if the page is already in memory.
> 
> > If page is already in the pagecache use it. Or return an error if strict
> > policy is in use. Or something else :) In my case I make sure that files
> > is accessed only through mmap interface.
> 
> On an mmap we cannot really return an error. If your program has just run 
> then pages may linger in memory. If you run it on another node then the 
> earlier used pages may be used.
I am OK with that behaviour. For already faulted pages there is nothing
we can do, so if application really cares it should make sure this doesn't
happen (flash file from pagecache before mmap. Is it even possible?).

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
