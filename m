Date: Sat, 16 Aug 2008 22:07:14 +0200
Subject: Re: sparsemem support for mips with highmem
Message-ID: <20080816200714.GA7041@alpha.franken.de>
References: <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com> <20080815080331.GA6689@alpha.franken.de> <1218815299.23641.80.camel@nimitz> <48A5AADE.1050808@sciatl.com> <20080815163302.GA9846@alpha.franken.de> <48A5B9F1.3080201@sciatl.com> <1218821875.23641.103.camel@nimitz> <48A5C831.3070002@sciatl.com> <1218824638.23641.106.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1218824638.23641.106.camel@nimitz>
From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: C Michael Sundius <Michael.sundius@sciatl.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 15, 2008 at 11:23:58AM -0700, Dave Hansen wrote:
> On Fri, 2008-08-15 at 11:17 -0700, C Michael Sundius wrote:
> > 
> > diff --git a/include/asm-mips/sparsemem.h
> > b/include/asm-mips/sparsemem.h
> > index 795ac6c..64376db 100644
> > --- a/include/asm-mips/sparsemem.h
> > +++ b/include/asm-mips/sparsemem.h
> > @@ -6,7 +6,7 @@
> >   * SECTION_SIZE_BITS           2^N: how big each section will be
> >   * MAX_PHYSMEM_BITS            2^N: how much memory we can have in
> > that space
> >   */
> > -#define SECTION_SIZE_BITS       28
> > +#define SECTION_SIZE_BITS       27     /* 128 MiB */
> >  #define MAX_PHYSMEM_BITS        35
> 
> This looks great to me, as long as the existing MIPS users like it.

sounds good, I like it.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
