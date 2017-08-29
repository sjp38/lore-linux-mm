Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 978656B0292
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 10:33:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p13so10836642qtp.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:33:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y70sor1828577qka.19.2017.08.29.07.33.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 07:33:24 -0700 (PDT)
Date: Tue, 29 Aug 2017 07:33:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170829143319.GJ491396@devbig577.frc2.facebook.com>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <20170829133325.o2s4xiqnc3ez6qxb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829133325.o2s4xiqnc3ez6qxb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

Hello,

On Tue, Aug 29, 2017 at 03:33:25PM +0200, Michal Hocko wrote:
> Hmm, we have this in should_reclaim_retry
> 			/*
> 			 * Memory allocation/reclaim might be called from a WQ
> 			 * context and the current implementation of the WQ
> 			 * concurrency control doesn't recognize that
> 			 * a particular WQ is congested if the worker thread is
> 			 * looping without ever sleeping. Therefore we have to
> 			 * do a short sleep here rather than calling
> 			 * cond_resched().
> 			 */
> 			if (current->flags & PF_WQ_WORKER)
> 				schedule_timeout_uninterruptible(1);
> 
> And I thought it would be susfficient for kworkers for concurrency WQ
> congestion thingy to jump in. Or do we need something more generic. E.g.
> make cond_resched special for kworkers?

I actually think we're hitting a bug somewhere.  Tetsuo's trace with
the patch applies doesn't add up.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
