Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84A946B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:04:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g28so736718wrg.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:04:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si7496750wmv.33.2017.08.07.07.04.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 07:04:13 -0700 (PDT)
Date: Mon, 7 Aug 2017 16:04:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm, oom: fix oom_reaper fallouts
Message-ID: <20170807140409.GJ32434@dhcp22.suse.cz>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 07-08-17 22:28:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hi,
> > there are two issues this patch series attempts to fix. First one is
> > something that has been broken since MMF_UNSTABLE flag introduction
> > and I guess we should backport it stable trees (patch 1). The other
> > issue has been brought up by Wenwei Tao and Tetsuo Handa has created
> > a test case to trigger it very reliably. I am not yet sure this is a
> > stable material because the test case is rather artificial. If there is
> > a demand for the stable backport I will prepare it, of course, though.
> > 
> > I hope I've done the second patch correctly but I would definitely
> > appreciate some more eyes on it. Hence CCing Andrea and Kirill. My
> > previous attempt with some more context was posted here
> > http://lkml.kernel.org/r/20170803135902.31977-1-mhocko@kernel.org
> > 
> > My testing didn't show anything unusual with these two applied on top of
> > the mmotm tree.
> 
> I really don't like your likely/unlikely speculation.

Have you seen any non artificial workload triggering this? Look, I am
not going to argue about how likely this is or not. I've said I am
willing to do backports if there is a demand but please do realize that
this is not a trivial change to backport pre 4.9 kernels would require
MMF_UNSTABLE to be backported as well. This all can be discussed
after the merge so can we focus on the review now rather than any
distractions?

Also please note that while writing zeros is certainly bad any integrity
assumptions are basically off when an application gets killed
unexpectedly while performing an IO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
