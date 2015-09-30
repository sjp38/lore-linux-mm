Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CD4846B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:29:01 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so34516830pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:29:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id rw6si43946261pbb.52.2015.09.30.01.29.00
        for <linux-mm@kvack.org>;
        Wed, 30 Sep 2015 01:29:00 -0700 (PDT)
Date: Wed, 30 Sep 2015 17:30:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/9] mm/compaction: allow to scan nonmovable pageblock
 when depleted state
Message-ID: <20150930083023.GC29589@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-6-git-send-email-iamjoonsoo.kim@lge.com>
 <560522A2.50609@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560522A2.50609@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Sep 25, 2015 at 12:32:02PM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> 
> [...]
> 
> > 
> > Because we just allow freepage scanner to scan non-movable pageblock
> > in very limited situation, more scanning events happen. But, allowing
> > in very limited situation results in a very important benefit that
> > memory isn't fragmented more than before. Fragmentation effect is
> > measured on following patch so please refer it.
> 
> AFAICS it's measured only for the whole series in the cover letter, no? Just to
> be sure I didn't overlook something.

It takes too much time so no measurement is done on every patch.
I will try to measure it on at least this patch in next revision.

> 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/mmzone.h |  1 +
> >  mm/compaction.c        | 27 +++++++++++++++++++++++++--
> >  2 files changed, 26 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index e13b732..5cae0ad 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -545,6 +545,7 @@ enum zone_flags {
> >  					 */
> >  	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
> >  	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
> > +	ZONE_COMPACTION_SCANALLFREE,	/* scan all kinds of pageblocks */
> 
> "SCANALLFREE" is hard to read. Otherwise yeah, I agree scanning unmovable
> pageblocks is necessary sometimes, and this seems to make a reasonable tradeoff.

Good! I will think better name.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
