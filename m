Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id A30A06B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:30:36 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id b186so52361559vkb.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 12:30:36 -0700 (PDT)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id v124si3656534vkv.253.2016.10.20.12.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 12:30:36 -0700 (PDT)
Received: by mail-qk0-f173.google.com with SMTP id z190so113697946qkc.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 12:30:35 -0700 (PDT)
Date: Thu, 20 Oct 2016 21:30:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: How to make warn_alloc() reliable?
Message-ID: <20161020193034.GD27342@dhcp22.suse.cz>
References: <201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp>
 <20161018122749.GE12092@dhcp22.suse.cz>
 <201610192027.GFB17670.VOtOLQFFOSMJHF@I-love.SAKURA.ne.jp>
 <20161019115525.GH7517@dhcp22.suse.cz>
 <201610202107.FBC86440.SVFHFtOFOOLQJM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201610202107.FBC86440.SVFHFtOFOOLQJM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-10-16 21:07:49, Tetsuo Handa wrote:
[...]
> By the way, regarding "making the direct reclaim path more deterministic"
> part, I wish that we can
> 
>   (1) introduce phased watermarks which varies based on stage of reclaim
>       operation (e.g. watermark_lower()/watermark_higher() which resembles
>       preempt_disable()/preempt_enable() but is propagated to other threads
>       when delegating operations needed for reclaim to other threads).
> 
>   (2) introduce dedicated kernel threads which perform only specific
>       reclaim operation, using watermark propagated from other threads
>       which performs different reclaim operation.
> 
>   (3) remove direct reclaim which bothers callers with managing correct
>       GFP_NOIO / GFP_NOFS / GFP_KERNEL distinction. Then, normal
>       ___GFP_DIRECT_RECLAIM callers can simply wait for
>       wait_event(get_pages_from_freelist() succeeds) rather than polling
>       with complicated short sleep. This will significantly save CPU
>       resource (especially when oom_lock is held) which is wasted by
>       activities by multiple concurrent direct reclaim.

As always, you are free to come up with patches with the proper
justification and convince people that those steps will help both the
regular case as well of those you are bothered with.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
