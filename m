Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D2BD86B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 06:53:01 -0400 (EDT)
Date: Fri, 28 Sep 2012 11:52:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928105255.GA29125@suse.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@avionic-design.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Sep 28, 2012 at 12:38:15PM +0200, Thierry Reding wrote:
> >
> > 
> > I've been running a few tests and indeed this solves the obvious problem
> > that the coherent pool cannot be created at boot (which in turn caused
> > the ethernet adapter to fail on Tegra).
> > 
> > However I've been working on the Tegra DRM driver, which uses CMA to
> > allocate large chunks of framebuffer memory and these are now failing.
> > I'll need to check if Minchan's patch solves that problem as well.
> 
> Indeed, with Minchan's patch the DRM can allocate the framebuffer
> without a problem. Something else must be wrong then.
> 

Can you check if Minchan's version 100% succeeds and my version 100%
fails or is it a case that sometimes CMA works and sometimes fails with
both versions?

I'll examine the patch of course and see what flaw is there this time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
