Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 963EA831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:01:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z88so9818070wrc.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:01:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si6411223wrg.172.2017.05.18.08.01.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 08:01:53 -0700 (PDT)
Date: Thu, 18 May 2017 17:01:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170518150147.GB13940@dhcp22.suse.cz>
References: <20170517161446.GB20660@dhcp22.suse.cz>
 <20170517194316.GA30517@castle>
 <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
 <20170518084729.GB25462@dhcp22.suse.cz>
 <20170518090039.GC25462@dhcp22.suse.cz>
 <201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp>
 <20170518142901.GA13940@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518142901.GA13940@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-05-17 16:29:01, Michal Hocko wrote:
> On Thu 18-05-17 22:57:10, Tetsuo Handa wrote:
[...]
> > Anyway, I want
> > 
> > 	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE))
> > +	if (alloc_flags == ALLOC_NO_WATERMARKS && test_thread_flag(TIF_MEMDIE))
> > 		goto nopage;
> > 
> > so that we won't see similar backtraces and memory information from both
> > out_of_memory() and warn_alloc().
> 
> I do not think this is an improvement and it is unrelated to the
> discussion here.

I am sorry, I've misread the diff. It was the comment below the diff
which confused me. Now that I looked at it again it actually makes sense.
I would still like to get rid of out_of_memory from pagefault_out_of_memory
but doing the above sounds safer for the stable backport. Care to create
a proper patch with the full changelog, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
