Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C41DB6B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 00:40:05 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id z8so10466719ige.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 21:40:05 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id u98si3068572ioi.74.2016.03.02.21.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 21:40:05 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id 63so8250046pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 21:40:05 -0800 (PST)
Date: Thu, 3 Mar 2016 14:41:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160303054124.GA411@swordfish>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302133810.GB22171@pathway.suse.cz>
 <20160302143415.GB614@swordfish>
 <20160302160437.GA2307@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302160437.GA2307@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

On (03/02/16 17:04), Jan Kara wrote:
> On Wed 02-03-16 23:34:15, Sergey Senozhatsky wrote:
> > > I am looking forward to have the console printing offloaded
> > > into the workqueues. Then printk() will become consistently
> > > "fast" operation and will cause less surprises like this.
> > 
> > I'm all for it. I need this rework badly. If Jan is too busy at
> > the moment, which I surely can understand, then I'll be happy to
> > help ("pick up the patches". please, don't get me wrong).
> 
> So I'm rather busy with other stuff currently so if you can pick up my
> patches and finish them, it would be good. I think I have addressed all the
> comments you had to the previous version, except for handling the case
> where all the workers are too busy - maybe using a dedicated workqueue with
> a rescueue worker instead of system_wq would solve this issue.
> 
> I've sent the current version of patches I have to you including the patch
> 3/3 which I use for debugging and testing whether the async printing really
> helps avoiding softlockups.

great, thank you! will take a look.

and yes, I was thinking about using printk's own workqueue with a
rescue thread bit set (Petr Mladek also proposed this).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
