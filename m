Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4926B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 10:17:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u23so3513681pgo.4
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 07:17:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s16si4708183plp.187.2017.11.03.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 07:17:06 -0700 (PDT)
Date: Fri, 3 Nov 2017 15:17:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Update comment for last second allocation
 attempt.
Message-ID: <20171103141703.lgke7jetrjelydd3@dhcp22.suse.cz>
References: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
 <1509716789-7218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171103135739.svmtesmgynshjuth@dhcp22.suse.cz>
 <201711032308.GHE78150.LQOFOtVFFJMHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711032308.GHE78150.LQOFOtVFFJMHSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org

On Fri 03-11-17 23:08:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 03-11-17 22:46:29, Tetsuo Handa wrote:
> > [...]
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index c274960..547e9cb 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3312,11 +3312,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> > >  	}
> > >  
> > >  	/*
> > > -	 * Go through the zonelist yet one more time, keep very high watermark
> > > -	 * here, this is only to catch a parallel oom killing, we must fail if
> > > -	 * we're still under heavy pressure. But make sure that this reclaim
> > > -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> > > -	 * allocation which will never fail due to oom_lock already held.
> > > +	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
> > > +	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
> > > +	 * already held. And since this allocation attempt does not sleep,
> > > +	 * there is no reason we must use high watermark here.
> > >  	 */
> > >  	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> > >  				      ~__GFP_DIRECT_RECLAIM, order,
> > 
> > Which patch does this depend on?
> 
> This patch is preparation for "mm,oom: Move last second allocation to inside
> the OOM killer." patch in order to use changelog close to what you suggested.
> That is, I will move this comment and get_page_from_freelist() together to
> alloc_pages_before_oomkill(), after we recorded why using ALLOC_WMARK_HIGH.

Is it really worth a separate patch, though? Aren't you overcomplicating
things again?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
