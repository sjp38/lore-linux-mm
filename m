Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE096B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:52:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so7397485lfg.6
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:52:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d80si4996854lfg.375.2016.10.12.07.52.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 07:52:33 -0700 (PDT)
Date: Wed, 12 Oct 2016 16:52:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: remove extra newline from allocation stall warning
Message-ID: <20161012145230.GO17128@dhcp22.suse.cz>
References: <1476026219-7974-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161010072123.GA20420@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161010072123.GA20420@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Let's CC Andrew -
http://lkml.kernel.org/r/1476026219-7974-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

On Mon 10-10-16 09:21:23, Michal Hocko wrote:
> On Mon 10-10-16 00:16:59, Tetsuo Handa wrote:
> > Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> > too long") by error embedded "\n" in the format string, resulting in
> > strange output.
> > 
> > [  722.876655] kworker/0:1: page alloction stalls for 160001ms, order:0
> > [  722.876656] , mode:0x2400000(GFP_NOIO)
> > [  722.876657] CPU: 0 PID: 6966 Comm: kworker/0:1 Not tainted 4.8.0+ #69
> 
> Ups, thanks for catching that.
> 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index ca423cc..828ee76 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3653,7 +3653,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> >  	/* Make sure we know about allocations which stall for too long */
> >  	if (time_after(jiffies, alloc_start + stall_timeout)) {
> >  		warn_alloc(gfp_mask,
> > -			"page alloction stalls for %ums, order:%u\n",
> > +			"page alloction stalls for %ums, order:%u",
> >  			jiffies_to_msecs(jiffies-alloc_start), order);
> >  		stall_timeout += 10 * HZ;
> >  	}
> > -- 
> > 1.8.3.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
