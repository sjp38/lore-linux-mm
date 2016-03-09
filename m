Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9F026B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:30:08 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so5285341wml.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:30:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 191si894643wmk.101.2016.03.09.14.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 14:30:07 -0800 (PST)
Date: Wed, 9 Mar 2016 17:30:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2]
 oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Message-ID: <20160309223000.GB3647@cmpxchg.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
 <1457442737-8915-3-git-send-email-mhocko@kernel.org>
 <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Mar 09, 2016 at 01:21:42PM -0800, Andrew Morton wrote:
> I found the below patch lying around but I didn't queue it properly. 
> Is it legit?

Yeah. Michal suggested this should be its own patch, which I agree
with. The subject would then be:

Subject: mm: oom_kill: don't ignore oom score on exiting tasks

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that one regardless of the score. Is there a possibility
> that the task might hang after it has set PF_EXITING? In that case the
> OOM killer should be able to move on to the next task.
> 
> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer. We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill.
> This is testing pure noise.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
