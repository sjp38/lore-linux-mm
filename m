Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B885B6B0264
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:02:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so8675996wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:02:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p129si29322998wmp.104.2016.06.08.09.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 09:02:58 -0700 (PDT)
Date: Wed, 8 Jun 2016 12:02:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/10] mm: remove LRU balancing effect of temporary page
 isolation
Message-ID: <20160608160255.GD6727@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-6-hannes@cmpxchg.org>
 <20160608073944.GA28620@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608073944.GA28620@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Wed, Jun 08, 2016 at 04:39:44PM +0900, Minchan Kim wrote:
> On Mon, Jun 06, 2016 at 03:48:31PM -0400, Johannes Weiner wrote:
> > @@ -832,9 +854,9 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
> >   * Add the passed pages to the LRU, then drop the caller's refcount
> >   * on them.  Reinitialises the caller's pagevec.
> >   */
> > -void __pagevec_lru_add(struct pagevec *pvec)
> > +void __pagevec_lru_add(struct pagevec *pvec, bool new)
> >  {
> > -	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
> > +	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)new);
> >  }
> 
> Just trivial:
> 
> 'new' argument would be not clear in this context what does it mean
> so worth to comment it, IMO but no strong opinion.

True, it's a little mysterious. I'll document it.

> Other than that,
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
