Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 79F766B005D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 05:32:48 -0400 (EDT)
Date: Tue, 22 Sep 2009 10:32:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] slqb: Allow SLQB to be used on PPC
Message-ID: <20090922093249.GC12254@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253549426-917-4-git-send-email-mel@csn.ul.ie> <20090922093023.GA22441@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090922093023.GA22441@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 11:30:23AM +0200, Heiko Carstens wrote:
> On Mon, Sep 21, 2009 at 05:10:26PM +0100, Mel Gorman wrote:
> > SLQB was disabled on PPC as it would stab itself in the face when running
> > on machines with CPUs on memoryless nodes. As those configurations should
> > now work, allow SLQB to be configured again on PPC.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  init/Kconfig |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/init/Kconfig b/init/Kconfig
> > index adc10ab..8f55fde 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -1033,7 +1033,7 @@ config SLUB
> > 
> >  config SLQB
> >  	bool "SLQB (Queued allocator)"
> > -	depends on !PPC && !S390
> > +	depends on !S390
> 
> You can remove S390 from the list independently from this patch set.
> As already mentioned SLQB works again on s390 and whatever caused the
> bug I reported a few weeks back is gone.
> 

Nice one. Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
