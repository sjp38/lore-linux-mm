Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11CF56B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 10:08:46 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f20so8798812ioj.2
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 07:08:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b7si2230763itj.17.2017.11.03.07.08.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 07:08:44 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Update comment for last second allocation attempt.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
	<1509716789-7218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171103135739.svmtesmgynshjuth@dhcp22.suse.cz>
In-Reply-To: <20171103135739.svmtesmgynshjuth@dhcp22.suse.cz>
Message-Id: <201711032308.GHE78150.LQOFOtVFFJMHSO@I-love.SAKURA.ne.jp>
Date: Fri, 3 Nov 2017 23:08:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org

Michal Hocko wrote:
> On Fri 03-11-17 22:46:29, Tetsuo Handa wrote:
> [...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index c274960..547e9cb 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3312,11 +3312,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  	}
> >  
> >  	/*
> > -	 * Go through the zonelist yet one more time, keep very high watermark
> > -	 * here, this is only to catch a parallel oom killing, we must fail if
> > -	 * we're still under heavy pressure. But make sure that this reclaim
> > -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> > -	 * allocation which will never fail due to oom_lock already held.
> > +	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
> > +	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
> > +	 * already held. And since this allocation attempt does not sleep,
> > +	 * there is no reason we must use high watermark here.
> >  	 */
> >  	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> >  				      ~__GFP_DIRECT_RECLAIM, order,
> 
> Which patch does this depend on?

This patch is preparation for "mm,oom: Move last second allocation to inside
the OOM killer." patch in order to use changelog close to what you suggested.
That is, I will move this comment and get_page_from_freelist() together to
alloc_pages_before_oomkill(), after we recorded why using ALLOC_WMARK_HIGH.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
