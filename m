Date: Wed, 18 Feb 2004 10:36:05 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040218183605.GG1269@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040218162858.2a230401.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Hellwig <hch@infradead.org>, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2004 at 04:28:58PM -0800, Andrew Morton wrote:
> Christoph Hellwig <hch@infradead.org> wrote:
> >
> > Yes.  Andrew, please read the GPL, it's very clear about derived works.
> > Then please tell me why you think gpfs is not a derived work.
> 
> OK, so I looked at the wrapper.  It wasn't a tremendously pleasant
> experience.  It is huge, and uses fairly standard-looking filesytem
> interfaces and locking primitives.  Also some awareness of NFSV4 for some
> reason.
>
> Still, the wrapper is GPL so this is not relevant.  Its only use is to tell
> us whether or not the non-GPL bits are "derived" from Linux, and it
> doesn't do that.

In the spirit of full disclosure, the wrapper is actually
distributed under the BSD license.  The GPFS guys tell
me that the "gpl" in the RPM name means "GPFS Portability
Layer".

					Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
