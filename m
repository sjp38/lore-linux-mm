Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAB176B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 07:23:24 -0500 (EST)
Date: Tue, 15 Nov 2011 12:23:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Reduce the amount of work done when updating
 min_free_kbytes
Message-ID: <20111115122315.GD27150@suse.de>
References: <20111111162119.GP3083@suse.de>
 <20111114152100.1333a015.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111114152100.1333a015.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 14, 2011 at 03:21:00PM -0800, Andrew Morton wrote:
> On Fri, 11 Nov 2011 16:21:19 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > When min_free_kbytes is updated, some pageblocks are marked MIGRATE_RESERVE.
> > Ordinarily, this work is unnoticable as it happens early in boot but on
> > large machines with 1TB of memory, this has been reported to delay
> > boot times, probably due to the NUMA distances involved.
> > 
> > The bulk of the work is due to calling calling pageblock_is_reserved()
> > an unnecessary amount of times and accessing far more struct page
> > metadata than is necessary. This patch significantly reduces the
> > amount of work done by setup_zone_migrate_reserve() improving boot
> > times on 1TB machines.
> > 
> 
> By how much? :)
> 
> (I mainly ask because I'm curious to know how long the kernel takes to
> boot on a 1TB machine...)
> 


Good question. I don't have access to the machine but based on the dmesg
they posted before and after, this patch reduced boot times by 27
seconds.

With only dmesg, I don't know how long it is taking to start services
and mount of the filesystem but assuming no major problems or timeouts
from drivers it looks like it is taking about 6 minutes to boot.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
