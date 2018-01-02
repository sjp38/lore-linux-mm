Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8248D6B0294
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 04:15:01 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 59so16573997wro.7
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 01:15:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y40si26514296wry.358.2018.01.02.01.14.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 01:14:59 -0800 (PST)
Date: Tue, 2 Jan 2018 10:14:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Is GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) &
 ~__GFP_DIRECT_RECLAIM supported?
Message-ID: <20180102091457.GA25397@dhcp22.suse.cz>
References: <201801021108.BCC17635.FQtOHMOLJSVFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801021108.BCC17635.FQtOHMOLJSVFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, wei.w.wang@intel.com, willy@infradead.org, mst@redhat.com

On Tue 02-01-18 11:08:47, Tetsuo Handa wrote:
> virtio-balloon wants to try allocation only when that allocation does not cause
> OOM situation. Since there is no gfp flag which succeeds allocations only if
> there is plenty of free memory (i.e. higher watermark than other requests),
> virtio-balloon needs to watch for OOM notifier and release just allocated memory
> when OOM notifier is invoked.

I do not understand the last part mentioning OOM notifier.

> Currently virtio-balloon is using
> 
>   GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY
> 
> for allocation, but is
> 
>   GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM
> 
> supported (from MM subsystem's point of view) ?

Semantically I do not see any reason why we shouldn't support
non-sleeping user allocation with an explicit nomemalloc flag. Btw. why
is __GFP_NOMEMALLOC needed at all?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
