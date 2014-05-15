Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 780FE6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 05:47:28 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so449874eek.18
        for <linux-mm@kvack.org>; Thu, 15 May 2014 02:47:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v47si2316651een.237.2014.05.15.02.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 02:47:26 -0700 (PDT)
Date: Thu, 15 May 2014 10:47:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved
 memory
Message-ID: <20140515094718.GE23991@suse.de>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <536CCC78.6050806@samsung.com>
 <20140513022603.GF23803@js1304-P5Q-DELUXE>
 <8738gcae4h.fsf@linux.vnet.ibm.com>
 <20140515021055.GC10116@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140515021055.GC10116@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>

On Thu, May 15, 2014 at 11:10:55AM +0900, Joonsoo Kim wrote:
> > That doesn't always prefer CMA region. It would be nice to
> > understand why grouping in pageblock_nr_pages is beneficial. Also in
> > your patch you decrement nr_try_cma for every 'order' allocation. Why ?
> 
> pageblock_nr_pages is just magic value with no rationale. :)

I'm not following this discussions closely but there is rational to that
value -- it's the size of a huge page for that architecture.  At the time
the fragmentation avoidance was implemented this was the largest allocation
size of interest.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
