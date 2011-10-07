Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1843F6B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 16:18:55 -0400 (EDT)
Date: Fri, 7 Oct 2011 21:18:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: vmscan: Limit direct reclaim for higher order
 allocations
Message-ID: <20111007201849.GC6418@suse.de>
References: <1318000643-27996-1-git-send-email-mgorman@suse.de>
 <1318000643-27996-2-git-send-email-mgorman@suse.de>
 <4E8F53CD.9000609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E8F53CD.9000609@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 07, 2011 at 03:32:29PM -0400, Rik van Riel wrote:
> On 10/07/2011 11:17 AM, Mel Gorman wrote:
> >From: Rik van Riel<riel@redhat.com>
> >
> >When suffering from memory fragmentation due to unfreeable pages,
> >THP page faults will repeatedly try to compact memory.  Due to the
> >unfreeable pages, compaction fails.
> 
> I believe Andrew just merged this one :)
> 

It's not the end of the world, this is not going to be the one mail that
bursts the inbox at the seams :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
