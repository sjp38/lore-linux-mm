Date: Tue, 8 Jan 2008 03:49:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080108024907.GB5264@wotan.suse.de>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de> <20080107103028.GA9325@flint.arm.linux.org.uk> <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com> <20080107194543.GA2788@flint.arm.linux.org.uk> <20080108023746.GC21068@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080108023746.GC21068@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 03:37:46AM +0100, Andi Kleen wrote:
> > - strongly ordered
> > - bufferable only *
> > - device, sharable *
> > - device, unsharable
> > - memory, bufferable and cacheable, write through, no write allocate
> > - memory, bufferable and cacheable, write back, no write allocate
> > - memory, bufferable and cacheable, write back, write allocate
> > - implementation defined combinations (eg, selecting "minicache")
> > - and a set of 16 states to allow the policy of inner and outer levels
> >   of cache to be defined (two bits per level).
> 
> Do you need all of those in user space? Perhaps you could give
> the bits different meanings depending on user or kernel space.
> I think Nick et.al. just need the bits for user space; they won't
> care about kernel mappings.

Yes correct -- they are only for userspace mappings. Though that includes mmaps
of /dev/mem and device drivers etc. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
