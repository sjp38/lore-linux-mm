Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5926B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 08:00:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d14so148095wrg.15
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:00:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si1885647edw.228.2017.11.28.05.00.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 05:00:19 -0800 (PST)
Date: Tue, 28 Nov 2017 14:00:17 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groups
 sharing the victim's mm.
Message-ID: <20171128130017.ma4qzyjay7p2zsbg@dhcp22.suse.cz>
References: <1511872888-4579-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511872888-4579-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 28-11-17 21:41:28, Tetsuo Handa wrote:
> Due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") and patch "mm,oom: Use ALLOC_OOM for OOM victim's last
> second allocation.", thread groups sharing the OOM victim's mm without
> setting ->signal->oom_mm before task_will_free_mem(current) is called
> might fail to try ALLOC_OOM allocation attempt.

Look, this is getting insane. The code complexity grows without any
real users asking for this. While this might look like an interesting
excercise to you I really hate the direction you are heading. This code
will always be just a heuristic and the more complicated it will be the
bigger chances of other side effects there will be as well.

So NACK to this unless I you can show a _real_ usecase that would
_suffer_ by this corner case.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
