Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B45FF90012A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 08:28:26 -0400 (EDT)
Date: Tue, 5 Jul 2011 13:27:21 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 4/8] mm: MIGRATE_CMA migration type added
Message-ID: <20110705122721.GB8286@n2100.arm.linux.org.uk>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <1309851710-3828-5-git-send-email-m.szyprowski@samsung.com> <201107051344.31298.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201107051344.31298.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, Jul 05, 2011 at 01:44:31PM +0200, Arnd Bergmann wrote:
> > @@ -198,6 +198,12 @@ config MIGRATION
> >  	  pages as migration can relocate pages to satisfy a huge page
> >  	  allocation instead of reclaiming.
> >  
> > +config CMA_MIGRATE_TYPE
> > +	bool
> > +	help
> > +	  This enables the use the MIGRATE_CMA migrate type, which lets lets CMA
> > +	  work on almost arbitrary memory range and not only inside ZONE_MOVABLE.
> > +
> >  config PHYS_ADDR_T_64BIT
> >  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
> 
> This is currently only selected on ARM with your patch set. 

That's because CMA is targeted at solving the "we need massive contiguous
DMA areas" problem on ARM SoCs.

And it does this without addressing the technical architecture problems
surrounding multiple aliasing mappings with differing attributes which
actually make it unsuitable for use on ARM.  This is not the first time
I've pointed that out, and I'm now at the point of basically ignoring
this CMA work because I'm tired of constantly pointing this out.

My silence on this subject must not be taken as placid acceptance of the
approach, but revulsion at seemingly being constantly ignored and having
these patches pushed time and time again with nothing really changing on
that issue.

It will be a sad day if these patches make their way into mainline without
that being addressed, and will show contempt for architecture maintainers
if it does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
