Date: Thu, 27 Mar 2008 12:55:32 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Increase max physical memory size of x86_64
Message-ID: <20080327175532.GA24412@sgi.com>
References: <20080321133157.GA10911@sgi.com> <20080325164154.GA5909@alberich.amd.com> <20080325165438.GA5298@sgi.com> <47E96876.3050206@redhat.com> <20080327173027.GA26969@alberich.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080327173027.GA26969@alberich.amd.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Herrmann <andreas.herrmann3@amd.com>
Cc: Chris Snook <csnook@redhat.com>, mingo@elte.hu, ak@suse.de, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 27, 2008 at 06:30:27PM +0100, Andreas Herrmann wrote:
> On Tue, Mar 25, 2008 at 05:02:46PM -0400, Chris Snook wrote:
> > Jack Steiner wrote:
> >> On Tue, Mar 25, 2008 at 05:41:54PM +0100, Andreas Herrmann wrote:
> >>> On Fri, Mar 21, 2008 at 08:31:57AM -0500, Jack Steiner wrote:
> >>>> Increase the maximum physical address size of x86_64 system
> >>>> to 44-bits. This is in preparation for future chips that
> >>>> support larger physical memory sizes.
> >>> Shouldn't this be increased to 48?
> >>> AMD family 10h CPUs actually support 48 bits for the
> >>> physical address.
> >> You are probably correct but I don't work with AMD processors
> >> and don't understand their requirements. If someone
> >> wants to submit a patch to support larger phys memory sizes,
> >> I certainly have no objections....
> >
> > The only advantage 44 bits has over 48 bits is that it allows us to 
> > uniquely identify 4k physical pages with 32 bits, potentially allowing for 
> > tighter packing of certain structures.  Do we have any code that does this, 
> > and if so, is it a worthwhile optimization?
> 
> I've checked where those defines are used. If I didn't miss something
> MAX_PHYSADDR_BITS isn't used at all on x86 and MAX_PHYSMEM_BITS is
> used (directly or indirectly) in several other macros.
> 
> But basically it's just section_to_node_table which would increase to 2
> or 4 MB depending on MAX_NUMNODES.  Using 44 bits this table is just
> 128 kB resp. 256 kB in size.
> 
> > Personally, I think we should support the full capability of the hardware, 
> > but I don't have a 17 TB Opteron box to test with.
> 
> I don't have one either.
> By adjusting some NB-registers it might be possible to configure
> physical addresses larger than 40 or 44 bits though. (Even if the
> machine has not more than 1 or 16 TB.) I'll verify whether this is
> really possible.
> 
> At the moment I think it's best to leave the define as is (44 or 40
> bit) as there is currently no practical benefit from increasing it to
> 48 bit.

Sounds reasonable to me (44 bits). Let someone with access to
new hardware verify that changing to 48 actually works. 


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
