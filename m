Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66C666B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:44:39 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so8491649wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:44:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f127si7007617wmf.124.2016.12.14.04.44.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 04:44:38 -0800 (PST)
Date: Wed, 14 Dec 2016 13:44:37 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214124437.GJ25573@dhcp22.suse.cz>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
 <20161214123644.GE16064@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214123644.GE16064@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On Wed 14-12-16 13:36:44, Petr Mladek wrote:
[...]
> There are basically two solution for this situation:
> 
> 1. Fix printk() so that it does not block forever. This will
>    get solved by the async printk patchset[*]. In the meantime,
>    a particular sensitive location might be worked around
>    by using printk_deferred() instead of printk()[**]

Absolutely!

> 2. Reduce the amount of messages. It is insane to report
>    the same problem many times so that the same messages
>    fill the entire log buffer. Note that the allocator
>    is not the only sinner here.

sure and the ratelimit patch should help in that direction.
show_mem for each allocation stall is really way too much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
