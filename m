Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B76A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:22:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id d186so41564128lfg.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:22:41 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id 207si7176862lfi.402.2016.10.12.23.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 23:22:39 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id x79so10870187lff.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:22:39 -0700 (PDT)
Date: Thu, 13 Oct 2016 08:22:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, compaction: allow compaction for GFP_NOFS requests
Message-ID: <20161013062238.GA21678@dhcp22.suse.cz>
References: <20161012114721.31853-1-mhocko@kernel.org>
 <224e7340-411c-f0ea-a9b5-0191517fbf7d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <224e7340-411c-f0ea-a9b5-0191517fbf7d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 13-10-16 08:19:53, Vlastimil Babka wrote:
> On 10/12/2016 01:47 PM, Michal Hocko wrote:
[...]
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> 
> Small nitpick below.
> 
> > @@ -1696,14 +1703,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> >  		unsigned int alloc_flags, const struct alloc_context *ac,
> >  		enum compact_priority prio)
> >  {
> > -	int may_enter_fs = gfp_mask & __GFP_FS;
> >  	int may_perform_io = gfp_mask & __GFP_IO;
> >  	struct zoneref *z;
> >  	struct zone *zone;
> >  	enum compact_result rc = COMPACT_SKIPPED;
> > 
> > -	/* Check if the GFP flags allow compaction */
> > -	if (!may_enter_fs || !may_perform_io)
> > +	/*
> > +	 * Check if the GFP flags allow compaction - GFP_NOIO is really
> > +	 * tricky context because the migration might require IO and
> 
> "and" ?

a leftover from a longer comment. s@ and@.@

Thanks for the review!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
