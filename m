Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8BC82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 22:24:55 -0400 (EDT)
Received: by igvi2 with SMTP id i2so15586441igv.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:24:55 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id l67si1033235iod.90.2015.10.28.19.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 19:24:54 -0700 (PDT)
Received: by pasz6 with SMTP id z6so24675943pas.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:24:54 -0700 (PDT)
Date: Thu, 29 Oct 2015 11:24:47 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
Message-ID: <20151029022447.GB27115@mtj.duckdns.org>
References: <20151028024114.370693277@linux.com>
 <20151028024131.719968999@linux.com>
 <20151028024350.GA10448@mtj.duckdns.org>
 <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
 <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Hello,

That's weird.

On Wed, Oct 28, 2015 at 08:57:28PM +0900, Tetsuo Handa wrote:
> [  272.851035] Showing busy workqueues and worker pools:
> [  272.852583] workqueue events: flags=0x0
> [  272.853942]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
> [  272.855781]     pending: vmw_fb_dirty_flush [vmwgfx]
> [  272.857500]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> [  272.859359]     pending: vmpressure_work_fn
> [  272.860840] workqueue events_freezable_power_: flags=0x84
> [  272.862461]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
> [  272.864479]     in-flight: 11286:disk_events_workfn

What's this guy doing?  Can you get stack dump on 11286 (or whatever
is in flight in the next lockup)?

> [  272.866065]     pending: disk_events_workfn
> [  272.867587] workqueue vmstat: flags=0x8
> [  272.868942]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> [  272.870785]     pending: vmstat_update
> [  272.872248] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=4 idle: 14 218 43

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
