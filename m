Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D6D08440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 01:34:06 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so53622666wmp.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 22:34:06 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g2si28840749wje.67.2016.02.05.22.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 22:34:05 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r129so6168004wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 22:34:05 -0800 (PST)
Date: Sat, 6 Feb 2016 07:34:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm, oom_reaper: report success/failure
Message-ID: <20160206063403.GA20537@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-5-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1602031505210.10331@chino.kir.corp.google.com>
 <20160204064636.GD8581@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602041428120.29117@chino.kir.corp.google.com>
 <20160205092640.GA5477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160205092640.GA5477@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 05-02-16 10:26:40, Michal Hocko wrote:
[...]
> From 402090df64de7f80d7d045b0b17e860220837fa6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 5 Feb 2016 10:24:23 +0100
> Subject: [PATCH] mm-oom_reaper-report-success-failure-fix
> 
> update the log message to be more specific
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 87d644c97ac9..ca61e6cfae52 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -479,7 +479,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  		}
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
> -	pr_info("oom_reaper: reaped process :%d (%s) anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lulB\n",
> +	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lulB\n",

Dohh, s@lulB@ulkB@

>  			task_pid_nr(tsk), tsk->comm,
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
>  			K(get_mm_counter(mm, MM_FILEPAGES)),
> -- 
> 2.7.0
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
