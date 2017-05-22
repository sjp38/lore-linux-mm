Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10791831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 05:31:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 10so24559157wml.4
        for <linux-mm@kvack.org>; Mon, 22 May 2017 02:31:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19si11595268wra.150.2017.05.22.02.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 02:31:15 -0700 (PDT)
Date: Mon, 22 May 2017 11:31:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170522093111.GE8509@dhcp22.suse.cz>
References: <20170519112604.29090-3-mhocko@kernel.org>
 <201705192202.EDD30719.OSLJHFMOFtFVOQ@I-love.SAKURA.ne.jp>
 <20170519132209.GG29839@dhcp22.suse.cz>
 <201705200022.BFJ12428.JFOSMLFOtFHOVQ@I-love.SAKURA.ne.jp>
 <20170519155057.GM29839@dhcp22.suse.cz>
 <201705200843.HAI95393.FQSFLOHVMJtOFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705200843.HAI95393.FQSFLOHVMJtOFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 20-05-17 08:43:29, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Why would looping inside an allocator with a restricted context be any
> > better than retrying the whole thing?
> 
> I'm not suggesting you to loop inside an allocator nor retry the whole thing.
> I'm suggesting you to avoid returning VM_FAULT_OOM by making allocations succeed
> (by e.g. calling oom_kill_process()) regardless of restricted context if you
> want to remove out_of_memory() from pagefault_out_of_memory(), for situation
> will not improve until memory is allocated (e.g. somebody else calls
> oom_kill_process() via a __GFP_FS allocation request).

And again for the hundred and so many times I will only repeat that
triggering OOM from those restricted contexts is just too dangerous
without other changes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
