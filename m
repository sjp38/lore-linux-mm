Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DA3FC6B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 11:04:18 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so92966370wmn.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 08:04:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si43757084wjr.171.2016.03.02.08.04.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 08:04:17 -0800 (PST)
Date: Wed, 2 Mar 2016 17:04:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160302160437.GA2307@quack.suse.cz>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302133810.GB22171@pathway.suse.cz>
 <20160302143415.GB614@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302143415.GB614@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

On Wed 02-03-16 23:34:15, Sergey Senozhatsky wrote:
> > I am looking forward to have the console printing offloaded
> > into the workqueues. Then printk() will become consistently
> > "fast" operation and will cause less surprises like this.
> 
> I'm all for it. I need this rework badly. If Jan is too busy at
> the moment, which I surely can understand, then I'll be happy to
> help ("pick up the patches". please, don't get me wrong).

So I'm rather busy with other stuff currently so if you can pick up my
patches and finish them, it would be good. I think I have addressed all the
comments you had to the previous version, except for handling the case
where all the workers are too busy - maybe using a dedicated workqueue with
a rescueue worker instead of system_wq would solve this issue.

I've sent the current version of patches I have to you including the patch
3/3 which I use for debugging and testing whether the async printing really
helps avoiding softlockups.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
