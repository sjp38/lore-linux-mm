Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id EAD3A6B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 22:10:07 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so5116106pbb.36
        for <linux-mm@kvack.org>; Sun, 18 May 2014 19:10:07 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id dh1si8692743pbc.198.2014.05.18.19.10.06
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 19:10:07 -0700 (PDT)
Date: Mon, 19 May 2014 11:12:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved
 memory
Message-ID: <20140519021234.GB19615@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <536CCC78.6050806@samsung.com>
 <20140513022603.GF23803@js1304-P5Q-DELUXE>
 <8738gcae4h.fsf@linux.vnet.ibm.com>
 <20140515021055.GC10116@js1304-P5Q-DELUXE>
 <20140515094718.GE23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140515094718.GE23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>

On Thu, May 15, 2014 at 10:47:18AM +0100, Mel Gorman wrote:
> On Thu, May 15, 2014 at 11:10:55AM +0900, Joonsoo Kim wrote:
> > > That doesn't always prefer CMA region. It would be nice to
> > > understand why grouping in pageblock_nr_pages is beneficial. Also in
> > > your patch you decrement nr_try_cma for every 'order' allocation. Why ?
> > 
> > pageblock_nr_pages is just magic value with no rationale. :)
> 
> I'm not following this discussions closely but there is rational to that
> value -- it's the size of a huge page for that architecture.  At the time
> the fragmentation avoidance was implemented this was the largest allocation
> size of interest.

Hello,

Indeed. There is a such good rationale.
Really thanks for informing it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
