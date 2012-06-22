Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 93CDD6B0255
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:12:56 -0400 (EDT)
Date: Fri, 22 Jun 2012 13:12:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: compaction: add /proc/vmstat entry for rescued
 MIGRATE_UNMOVABLE pageblocks
Message-Id: <20120622131254.cc606c00.akpm@linux-foundation.org>
In-Reply-To: <4FDA0F82.2030708@gmail.com>
References: <201206141802.50075.b.zolnierkie@samsung.com>
	<4FDA0F82.2030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, 14 Jun 2012 12:21:22 -0400
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> (6/14/12 12:02 PM), Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> > Subject: [PATCH] mm: compaction: add /proc/vmstat entry for rescued MIGRATE_UNMOVABLE pageblocks
> >
> > compact_rescued_unmovable_blocks shows the number of MIGRATE_UNMOVABLE
> > pageblocks converted back to MIGRATE_MOVABLE type by the memory compaction
> > code.  Non-zero values indicate that large kernel-originated allocations
> > of MIGRATE_UNMOVABLE type happen in the system and need special handling
> > from the memory compaction code.
> >
> > This new vmstat entry is optional but useful for development and understanding
> > the system.
> 
> This description don't describe why admin need this stat and how to use it.
> 

Was there a response to this?

patch [1/2] doesn't apply.  Refresh and resend the series, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
