Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB4F6B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:39:44 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so1114435eek.35
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:39:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l41si34217519eef.68.2014.05.01.06.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:39:42 -0700 (PDT)
Date: Thu, 1 May 2014 14:39:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/17] mm: Do not use atomic operations when releasing
 pages
Message-ID: <20140501133938.GK23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-15-git-send-email-mgorman@suse.de>
 <20140501132922.GD23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140501132922.GD23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:29:22AM -0400, Johannes Weiner wrote:
> On Thu, May 01, 2014 at 09:44:45AM +0100, Mel Gorman wrote:
> > There should be no references to it any more and a parallel mark should
> > not be reordered against us. Use non-locked varient to clear page active.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/swap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index f2228b7..7a5bdd7 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -854,7 +854,7 @@ void release_pages(struct page **pages, int nr, bool cold)
> >  		}
> >  
> >  		/* Clear Active bit in case of parallel mark_page_accessed */
> > -		ClearPageActive(page);
> > +		__ClearPageActive(page);
> 
> Shouldn't this comment be removed also?

Why? We're still clearing the active bit.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
