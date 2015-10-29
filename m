Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5D982F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 23:08:29 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so19829716pad.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:08:29 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id yf8si74989710pbc.129.2015.10.28.20.08.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 20:08:28 -0700 (PDT)
Received: by pasz6 with SMTP id z6so25797847pas.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:08:28 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:08:22 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
Message-ID: <20151029030822.GD27115@mtj.duckdns.org>
References: <20151028024114.370693277@linux.com>
 <20151028024131.719968999@linux.com>
 <20151028024350.GA10448@mtj.duckdns.org>
 <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
 <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
 <20151029022447.GB27115@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029022447.GB27115@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Thu, Oct 29, 2015 at 11:24:47AM +0900, Tejun Heo wrote:
> Hello,
> 
> That's weird.
> 
> On Wed, Oct 28, 2015 at 08:57:28PM +0900, Tetsuo Handa wrote:
> > [  272.851035] Showing busy workqueues and worker pools:
> > [  272.852583] workqueue events: flags=0x0
> > [  272.853942]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
> > [  272.855781]     pending: vmw_fb_dirty_flush [vmwgfx]
> > [  272.857500]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> > [  272.859359]     pending: vmpressure_work_fn
> > [  272.860840] workqueue events_freezable_power_: flags=0x84
> > [  272.862461]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
> > [  272.864479]     in-flight: 11286:disk_events_workfn
> 
> What's this guy doing?  Can you get stack dump on 11286 (or whatever
> is in flight in the next lockup)?

Wait, this series doesn't include Tetsuo's change.  Of course it won't
fix the deadlock problem.  What's necessary is Tetsuo's patch +
WQ_MEM_RECLAIM.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
