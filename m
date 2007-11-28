Date: Wed, 28 Nov 2007 10:52:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: pseries (power3) boot hang  (pageblock_nr_pages==0)
Message-ID: <20071128105211.GB2238@csn.ul.ie>
References: <1195682111.4421.23.camel@farscape.rchland.ibm.com> <20071121220337.GB31674@csn.ul.ie> <1196105757.11297.11.camel@farscape.rchland.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1196105757.11297.11.camel@farscape.rchland.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Schmidt <will_schmidt@vnet.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On (26/11/07 13:35), Will Schmidt didst pronounce:
> 
> On Wed, 2007-11-21 at 22:03 +0000, Mel Gorman wrote:
> > On (21/11/07 15:55), Will Schmidt didst pronounce:
> > > Hi Folks, 
> > > 
> > > I imagine this would be properly fixed with something similar to the
> > > change for iSeries.  
> > 
> > Have you tried with the patch that fixed the iSeries boot problem?
> > Thanks for tracking down the problem to such a specific place.
> 
> I had not, but gave this patch a spin this morning, and it does the
> job.  :-)  

Brilliant.

> I was thinking (without really looking at it), that the
> iseries fix was in platform specific code.   Silly me. :-)
> 
> So for the record, this patch also fixes power3 pSeries systems.
> 
> fwiw:
> Tested-By:  Will Schmidt <will_schmidt@vnet.ibm.com>
> 

Thanks a lot for reporting and testing Will.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
