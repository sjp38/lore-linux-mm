Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 555386B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 11:25:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p42so1334761wrb.1
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 08:25:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c82si304664wmf.129.2017.08.31.08.25.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 08:25:25 -0700 (PDT)
Date: Thu, 31 Aug 2017 17:25:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170831152523.nwdbjock6b6tams5@dhcp22.suse.cz>
References: <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
 <20170829143817.GK491396@devbig577.frc2.facebook.com>
 <20170829214104.GW491396@devbig577.frc2.facebook.com>
 <201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
 <20170831014610.GE491396@devbig577.frc2.facebook.com>
 <201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

On Thu 31-08-17 23:52:57, Tetsuo Handa wrote:
[...]
> So, this pending state seems to be caused by many concurrent allocations by !PF_WQ_WORKER
> threads consuming too much CPU time (because they only yield CPU time by many cond_resched()
> and one schedule_timeout_uninterruptible(1)) enough to keep schedule_timeout_uninterruptible(1)
> by PF_WQ_WORKER threads away for order of minutes. A sort of memory allocation dependency
> observable in the form of CPU time starvation for the worker to wake up.

I do not understand this. Why is cond_resched from the user context
insufficient to let runable kworkers to run?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
