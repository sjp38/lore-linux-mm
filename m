Date: Wed, 18 Feb 2004 07:06:07 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040218150607.GE1269@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040218211035.A13866@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjanv@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2004 at 09:10:35PM +0000, Christoph Hellwig wrote:
> On Wed, Feb 18, 2004 at 06:00:21AM -0800, Paul E. McKenney wrote:
> > There is a small shim layer required, but the bulk of the code
> > implementing GPFS is common between AIX and Linux.  It was on AIX
> > first by quite a few years.
> 
> Small glue layer?  Unfortunately ibm took it off the website, but
> the thing is damn huge.

Perhaps it is huge, but it is a small fraction of the GPFS kernel
implementation.

> > > it only uses "core unix" apis ?
> > 
> > If they are made available, yes.  That is the point of this patch,
> > after all.  ;-)
> 
> No, that's wrong.  It patches the syscall table and plays evilish
> tricks with lowlevel MM code.

The sys_call_table stuff was under #ifdef, and was intended for
use by a research project that was later put out of its misery.
This stuff has since been removed from the source tree.

As to the evilish tricks with lowlevel MM code, the whole point
of the mmap_invalidate_range() patch is to be able to rid GPFS
of exactly these evilish tricks.

> > > It doesn't require knowledge of deep and changing internals ? *buzz*
> > 
> > That is indeed the idea.
> 
> The one on the ibm website a little ago did.  You're free to upload
> a new one that clearly doesn't need all this, but..

Again, the point of the mmap_invalidate_range() patch is to be able
to do precisely this.

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
