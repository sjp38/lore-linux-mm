Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 89A3C6B005A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:05:17 -0400 (EDT)
Date: Tue, 9 Jun 2009 11:37:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v4] zone_reclaim is always 0 by default
Message-ID: <20090609103754.GN18380@csn.ul.ie>
References: <20090604192236.9761.A69D9226@jp.fujitsu.com> <20090608115048.GA15070@csn.ul.ie> <20090609095507.GA9851@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609095507.GA9851@attica.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 04:55:07AM -0500, Robin Holt wrote:
> On Mon, Jun 08, 2009 at 12:50:48PM +0100, Mel Gorman wrote:
> 
> Let me start by saying I agree completely with everything you wrote and
> still disagree with this patch, but was willing to compromise and work
> around this for our upcoming x86_64 machine by putting a "value add"
> into our packaging of adding a sysctl that turns reclaim back on.
> 

To be honest, I'm more leaning towards a NACK than an ACK on this one. I
don't support enough NUMA machines to feel strongly enough about it but
unconditionally setting zone_reclaim_mode to 0 on x86-64 just because i7's
might be there seems ill-advised to me and will have other consequences for
existing more traditional x86-64 NUMA machines.

> ...
> > > Index: b/arch/powerpc/include/asm/topology.h
> > > ===================================================================
> > > --- a/arch/powerpc/include/asm/topology.h
> > > +++ b/arch/powerpc/include/asm/topology.h
> > > @@ -10,6 +10,12 @@ struct device_node;
> > >  
> > >  #include <asm/mmzone.h>
> > >  
> > > +/*
> > > + * Distance above which we begin to use zone reclaim
> > > + */
> > > +#define RECLAIM_DISTANCE 20
> > > +
> > > +
> > 
> > Where is the ia-64-specific modifier to RECAIM_DISTANCE?
> 
> It was already defined as 15 in arch/ia64/include/asm/topology.h
> 

/me slaps self

thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
