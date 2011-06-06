Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 978C66B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 09:27:22 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2309737pzk.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 06:27:20 -0700 (PDT)
Date: Mon, 6 Jun 2011 22:27:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606132709.GB1686@barrios-laptop>
References: <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
 <20110603144941.GI7306@suse.de>
 <20110604065853.GA4114@barrios-laptop>
 <20110606104345.GE5247@suse.de>
 <20110606124025.GB12887@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606124025.GB12887@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, Jun 06, 2011 at 02:40:25PM +0200, Andrea Arcangeli wrote:
> On Mon, Jun 06, 2011 at 11:43:45AM +0100, Mel Gorman wrote:
> > Maybe not full, but it has more PageReserved pages than anywhere else
> > and few MIGRATE_MOVABLE blocks. MIGRATE_MOVABLE gets skipped during
> > async compaction we could easily reach the end of the DMA zone quickly.
> 
> Debug data has nr_isolated_file in dma zone 1 and nr_isolated_file in
> normal zone being -1.

It's exactly match with Mel's case.
Thanks for the proving, Andrea.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
