Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id AEA256B0070
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 20:16:53 -0400 (EDT)
Received: by dadi14 with SMTP id i14so98156dad.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 17:16:53 -0700 (PDT)
Date: Sat, 8 Sep 2012 09:16:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120908001643.GA2538@barrios>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <20120907022434.GG16231@bbox>
 <20120907082145.GV11266@suse.de>
 <20120907093203.GX11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120907093203.GX11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Sep 07, 2012 at 10:32:03AM +0100, Mel Gorman wrote:
> On Fri, Sep 07, 2012 at 09:21:45AM +0100, Mel Gorman wrote:
> > 
> > So other than the mix up of order parameters I think this should work.
> > 
> 
> But I'd be wrong, isolated page accounting is not fixed up so it will
> eventually hang on too_many_isolated. It turns out it is necessary

Good spot.

> to pass in zone after all. The following patch passed a high order
> allocation stress test. To actually exercise the path I had compaction
> call reclaim_clean_pages_from_list() in a separate debugging patch.
> 
> Minchan, can you test your CMA allocation latency test with this patch?
> If the figures are satisfactory could you add them to the changelog and
> consider replacing the MIGRATE_DISCARD pair of patches with this version
> please?

Of course, I will do next week.
Thanks!

--
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
