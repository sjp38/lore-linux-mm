Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49E406B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 08:12:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h19so1526153wmi.10
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 05:12:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si25126513wrc.32.2017.04.12.05.12.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 05:12:34 -0700 (PDT)
Date: Wed, 12 Apr 2017 14:12:32 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test
 in warn_alloc().
Message-ID: <20170412121232.GD7157@dhcp22.suse.cz>
References: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170412102341.GA13958@redhat.com>
 <20170412105951.GB7157@dhcp22.suse.cz>
 <20170412112154.GB14892@redhat.com>
 <20170412113528.GC7157@dhcp22.suse.cz>
 <20170412114754.GA15135@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412114754.GA15135@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed 12-04-17 13:48:16, Stanislaw Gruszka wrote:
> On Wed, Apr 12, 2017 at 01:35:28PM +0200, Michal Hocko wrote:
> > OK, I see. That is a rather weird feature and the naming is more than
> > surprising. But put that aside. Then it means that the check should be
> > pulled out to 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6632256ef170..1e5f3b5cdb87 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3941,7 +3941,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto retry;
> >  	}
> >  fail:
> > -	warn_alloc(gfp_mask, ac->nodemask,
> > +	if (!debug_guardpage_minorder())
> > +		warn_alloc(gfp_mask, ac->nodemask,
> >  			"page allocation failure: order:%u", order);
> >  got_pg:
> >  	return page;
> 
> Looks good to me assuming it will be applied on top of Tetsuo's patch.

This also asks for a comment explaining why debug_guardpage_minorder is
special. Your previous clarification should be OK.
 
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>

Tetsuo care to send an updated patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
