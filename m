Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 77A2B6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 06:27:35 -0400 (EDT)
Date: Fri, 28 Sep 2012 11:27:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928102728.GN3429@suse.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50656459.70309@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Ujfalusi <peter.ujfalusi@ti.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wrote:
> Hi,
> 
> On 09/28/2012 11:37 AM, Mel Gorman wrote:
> >> I hope this patch fixes the bug. If this patch fixes the problem
> >> but has some problem about description or someone has better idea,
> >> feel free to modify and resend to akpm, Please.
> >>
> > 
> > A full revert is overkill. Can the following patch be tested as a
> > potential replacement please?
> > 
> > ---8<---
> > mm: compaction: Iron out isolate_freepages_block() and isolate_freepages_range() -fix1
> > 
> > CMA is reported to be broken in next-20120926. Minchan Kim pointed out
> > that this was due to nr_scanned != total_isolated in the case of CMA
> > because PageBuddy pages are one scan but many isolations in CMA. This
> > patch should address the problem.
> > 
> > This patch is a fix for
> > mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> linux-next + this patch alone also works for me.
> 
> Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>

Thanks Peter. I expect it also works for Thierry as I expect you were
suffering the same problem but obviously confirmation of that would be nice.

Andrew, can you pick up this version of the patch instead of Minchan's
revert?

Thanks Minchan for pointing out the obvious flaw in "mm: compaction:
Iron out isolate_freepages_block() and isolate_freepages_range()".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
