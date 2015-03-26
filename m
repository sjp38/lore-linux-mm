Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 114746B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:43:11 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so60701641wib.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:43:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si27760362wik.5.2015.03.26.04.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 04:43:09 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:43:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/12] mm: oom_kill: remove unnecessary locking in
 oom_enable()
Message-ID: <20150326114306.GB15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:05, Johannes Weiner wrote:
> Setting oom_killer_disabled to false is atomic, there is no need for
> further synchronization with ongoing allocations trying to OOM-kill.

True, races with an ongoing allocations are not harmful.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2b665da1b3c9..73763e489e86 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -488,9 +488,7 @@ bool oom_killer_disable(void)
>   */
>  void oom_killer_enable(void)
>  {
> -	down_write(&oom_sem);
>  	oom_killer_disabled = false;
> -	up_write(&oom_sem);
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> -- 
> 2.3.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
