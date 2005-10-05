Date: Wed, 5 Oct 2005 14:42:54 -0400
From: Bob Picco <bob.picco@hp.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005184254.GA25483@localhost.localdomain>
References: <1128527554.26009.2.camel@localhost> <20051005155823.GA10119@osiris.ibm.com> <1128528340.26009.8.camel@localhost> <20051005161009.GA10146@osiris.ibm.com> <1128529222.26009.16.camel@localhost> <20051005171230.GA10204@osiris.ibm.com> <1128532809.26009.39.camel@localhost> <20051005174542.GB10204@osiris.ibm.com> <1128535054.26009.53.camel@localhost> <20051005180443.GC10204@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051005180443.GC10204@osiris.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

Heiko Carstens wrote:	[Wed Oct 05 2005, 02:04:43PM EDT]
> > > > > Anything specific you need to know about the memory layout?
> > > > How sparse is it?  How few present pages can be there be in a worst-case
> > > > physical area?
> > > 
> > > Worst case that is already currently valid is that you can have 1 MB
> > > segments whereever you want in address space.
> > ...
> > > Even though it's currently not possible to define memory segments above
> > > 1TB, this limit is likely to go away.
> > 
> > Go away, or get moved up?
> > 
> > ia64 today is designed to work with 50 bits of physical address space,
> > and 30 bit sections.  That's exactly the same scale that you're talking
> > about with 1MB sections and 1TB of physical space.  So, sparsemem
> > extreme should be perfectly fine for that case (that's explicitly what
> > it was designed for).
> > 
> > How much bigger than 1TB will it go?
> 
> As already mentioned, we will have physical memory with the MSB set. Afaik
> the hardware uses this bit to distinguish between different types of memory.
> So we are going to have the full 64 bit address space.
> 
> Heiko
Possibly the architects did a similar thing to ia64.  When bit 63 is set the
access in uncached. This doesn't seem relevant to sparsemem.  The attribute
could be stored in page structure flags or some other way.

bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
