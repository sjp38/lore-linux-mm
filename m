Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 92A0A6B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 03:53:12 -0500 (EST)
Date: Fri, 16 Nov 2012 08:53:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: +
 mm-revert-mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures.patch
 added to -mm tree
Message-ID: <20121116085306.GX8218@suse.de>
References: <20121113224710.346805C0050@hpza9.eem.corp.google.com>
 <20633.1353006410@turing-police.cc.vt.edu>
 <42264.1353033363@turing-police.cc.vt.edu>
 <50A5F092.2000303@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A5F092.2000303@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org, jirislaby@gmail.com, riel@redhat.com, zkabelac@redhat.com, linux-mm@kvack.org

On Fri, Nov 16, 2012 at 08:51:46AM +0100, Jiri Slaby wrote:
> Fixed Mel's address.
> 
> On 11/16/2012 03:36 AM, Valdis.Kletnieks@vt.edu wrote:
> > On Thu, 15 Nov 2012 14:06:50 -0500, Valdis.Kletnieks@vt.edu said:
> > 
> >> On Tue, 13 Nov 2012 14:45:06 -0800, you said:
> >>> 
> >>> The patch titled Subject: mm: vmscan: scale number of pages
> >>> reclaimed by reclaim/compaction only in direct reclaim has been
> >>> removed from the -mm tree.  Its filename was 
> >>> mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-only-in-direct-reclaim.patch
> >>>
> >>>
> >>> 
> This patch was dropped because it was withdrawn
> >> 
> >> On Tue, 13 Nov 2012 14:47:09 -0800, akpm@linux-foundation.org
> >> said:
> >>> 
> >>> The patch titled Subject: mm: revert "mm: vmscan: scale number
> >>> of pages reclaimed by reclaim/compaction based on failures" has
> >>> been added to the -mm tree.  Its filename is 
> >>> mm-revert-mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures.patch
> >>
> >>
> >>> 
> Confirming that next-20121114 with the first patch reverted and
> >> the second patch applied is behaving on my laptop, with no
> >> kswapd storms being spotted in over 24 hours now.
> > 
> > OK.  Now I'm well and truly mystified.  That makes *twice* now that
> > I've said "Patch makes the kswapd spinning go away", only to have
> > kswapd start burning CPU a bit later.
> 
> For me and Zdenek, we think we need a couple of suspend/resume cycles.
> Anyway, there was a severe slab memleak in -next kernels in the TTY
> layer I fixed yesterday and should be in -next today. Could that be
> causing this?
> 

It would not have helped but it's still the case that kswapd does not
properly reach its exit conditions if it's woken for THP allocation.
It's not fixing the underlying problem which needs to be investigated but
it's why there is a patch out there reverting the __GFP_NO_KSWAPD change
entirely until it can.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
