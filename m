Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 837D36B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 05:26:02 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so6144862wjc.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 02:26:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1si53615307wjz.272.2016.12.14.02.26.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 02:26:01 -0800 (PST)
Date: Wed, 14 Dec 2016 11:26:00 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214102600.GF25573@dhcp22.suse.cz>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214093706.GA16064@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On Wed 14-12-16 10:37:06, Petr Mladek wrote:
> On Tue 2016-12-13 21:06:57, Tetsuo Handa wrote:
[...]
> > Although it is fine to make warn_alloc() less verbose, this is not
> > a problem which can be avoided by simply reducing printk(). Unless
> > we give enough CPU time to the OOM killer and OOM victims, it is
> > trivial to lockup the system.
> 
> You could try to use printk_deferred() in warn_alloc(). It will not
> handle console.

the problem is, however, _any_ printk under the oom_lock. So all of them
would have to be converted AFAIU.

> It will help to be sure that the blocked printk()
> is the main problem.

I think we should rather ratelimit those messages than tweak the way how
the printk is used. The source of the heavy printk might be completely
different so this has to be addressed at the printk level.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
