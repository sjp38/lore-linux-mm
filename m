Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 873876B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:30:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r136so8805674wmf.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:30:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si942915edi.295.2017.09.25.07.30.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 07:30:54 -0700 (PDT)
Date: Mon, 25 Sep 2017 16:30:52 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] [PATCH v3] mm, oom: task_will_free_mem(current) should
 ignore MMF_OOM_SKIP for once.
Message-ID: <20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
References: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Fri 22-09-17 17:57:26, Tetsuo Handa wrote:
[...]
> Michal Hocko has nacked this patch [3], and he suggested an alternative
> patch [4]. But he himself is not ready to clarify all the concerns with
> the alternative patch [5]. In addition to that, nobody is interested in
> either patch; we can not make progress here. Let's choose this patch for
> now, for this patch has smaller impact than the alternative patch.

My Nack stands and it is really annoying you are sending a patch for
inclusion regardless of that fact. An alternative approach has been
proposed and the mere fact that I do not have time to pursue this
direction is not reason to go with a incomplete solution. This is not an
issue many people would be facing to scream for a quick and dirty
workarounds AFAIK (there have been 0 reports from non-artificial
workloads).

> [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> [2] http://lkml.kernel.org/r/201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp
> [3] http://lkml.kernel.org/r/20170821084307.GB25956@dhcp22.suse.cz
> [4] http://lkml.kernel.org/r/1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> [5] http://lkml.kernel.org/r/20170918064353.v35prpp6bkkbgqr6@dhcp22.suse.cz
> 
> Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: David Rientjes <rientjes@google.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
