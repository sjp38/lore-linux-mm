Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id BAF956B005A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 04:48:14 -0400 (EDT)
Date: Mon, 8 Oct 2012 09:48:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121008084806.GH29125@suse.de>
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
 <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
 <20121002124814.GA31316@avionic-0098.mockup.avionic-design.de>
 <20121002144135.GO29125@suse.de>
 <20121002150307.GA1161@avionic-0098.mockup.avionic-design.de>
 <20121002151217.GP29125@suse.de>
 <20121008080654.GD13817@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121008080654.GD13817@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Mon, Oct 08, 2012 at 05:06:54PM +0900, Minchan Kim wrote:
> Hi Mel,
> 
> On Tue, Oct 02, 2012 at 04:12:17PM +0100, Mel Gorman wrote:
> > On Tue, Oct 02, 2012 at 05:03:07PM +0200, Thierry Reding wrote:
> > > On Tue, Oct 02, 2012 at 03:41:35PM +0100, Mel Gorman wrote:
> > > > On Tue, Oct 02, 2012 at 02:48:14PM +0200, Thierry Reding wrote:
> > > > > > So this really isn't all that new, but I just wanted to confirm my
> > > > > > results from last week. We'll see if bisection shows up something
> > > > > > interesting.
> > > > > 
> > > > > I just finished bisecting this and git reports:
> > > > > 
> > > > > 	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit
> > > > > 
> > > > > I'm attaching the complete bisection log and a diff of all the changes
> > > > > applied on top of the bad commit to make it compile and run on my board.
> > > > > Most of the patch is probably not important, though. There are two hunks
> > > > > which have the pageblock changes I already posted an two other hunks
> > > > > with the patch you posted earlier.
> > > > > 
> > > > > I hope this helps. If you want me to run any other tests, please let me
> > > > > know.
> > > > > 
> > > > 
> > > > Can you test with this on top please?
> > > 
> > > That doesn't build on top of the bad commit. Or is it supposed to go on
> > > top of next-20120926?
> > > 
> > 
> > It doesn't build or do you mean it doesn't apply? Assuming the problem
> > was that it didn't apply then try this one. It applies on top of
> > next-20120928 which is the closest tag I have to next-20120926.
> > 
> > ---8<---
> > mm: compaction: Cache if a pageblock was scanned and no pages were isolated -fix3
> > 
> > CMA requires that the PG_migrate_skip hint be skipped but it was only
> > skipping it when isolating pages for migration, not for free. Ensure
> > cc->isolate_skip_hint gets passed in both cases.
> > 
> > This is a fix for
> > mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix.patch
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> But please resend below compile error fixing.
> 

Thanks Minchan. I did resent this patch to Andrew with the subject "[PATCH]
mm: compaction: Cache if a pageblock was scanned and no pages were isolated
-fix3". It should have had the build errors fixed but has not been
picked up yet.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
