Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B87B46B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 18:21:02 -0500 (EST)
Date: Mon, 14 Nov 2011 15:21:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Reduce the amount of work done when updating
 min_free_kbytes
Message-Id: <20111114152100.1333a015.akpm@linux-foundation.org>
In-Reply-To: <20111111162119.GP3083@suse.de>
References: <20111111162119.GP3083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Nov 2011 16:21:19 +0000
Mel Gorman <mgorman@suse.de> wrote:

> When min_free_kbytes is updated, some pageblocks are marked MIGRATE_RESERVE.
> Ordinarily, this work is unnoticable as it happens early in boot but on
> large machines with 1TB of memory, this has been reported to delay
> boot times, probably due to the NUMA distances involved.
> 
> The bulk of the work is due to calling calling pageblock_is_reserved()
> an unnecessary amount of times and accessing far more struct page
> metadata than is necessary. This patch significantly reduces the
> amount of work done by setup_zone_migrate_reserve() improving boot
> times on 1TB machines.
> 

By how much? :)

(I mainly ask because I'm curious to know how long the kernel takes to
boot on a 1TB machine...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
