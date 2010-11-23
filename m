Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E00DB6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 05:04:21 -0500 (EST)
Date: Tue, 23 Nov 2010 10:04:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101123100402.GH19571@csn.ul.ie>
References: <20101115195246.GB17387@hostway.ca> <20101122154419.ee0e09d2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101122154419.ee0e09d2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 03:44:19PM -0800, Andrew Morton wrote:
> On Mon, 15 Nov 2010 11:52:46 -0800
> Simon Kirby <sim@hostway.ca> wrote:
> 
> > I noticed that CONFIG_NUMA seems to enable some more complicated
> > reclaiming bits and figured it might help since most stock kernels seem
> > to ship with it now.  This seems to have helped, but it may just be
> > wishful thinking.  We still see this happening, though maybe to a lesser
> > degree.  (The following observations are with CONFIG_NUMA enabled.)
> > 

Hi,

As this is a NUMA machine, what is the value of
/proc/sys/vm/zone_reclaim_mode ? When enabled, this reclaims memory
local to the node in preference to using remote nodes. For certain
workloads this performs better but for users that expect all of memory
to be used, it has surprising results.

If set to 1, try testing with it set to 0 and see if it makes a
difference. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
