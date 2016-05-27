Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEBF26B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:13:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id w16so47767890lfd.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:13:30 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y187si12505442wmc.112.2016.05.27.07.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 07:13:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so15281539wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:13:29 -0700 (PDT)
Date: Fri, 27 May 2016 16:13:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: zap ZONE_OOM_LOCKED
Message-ID: <20160527141327.GO27686@dhcp22.suse.cz>
References: <1464358093-22663-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464358093-22663-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 17:08:13, Vladimir Davydov wrote:
> Not used since oom_lock was instroduced.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 1 -
>  mm/oom_kill.c          | 4 ++--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 02069c23486d..3388ccbab7d6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -524,7 +524,6 @@ struct zone {
>  
>  enum zone_flags {
>  	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
> -	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
>  	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>  					 * a congested BDI
>  					 */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1685890d424e..b95c4c101b35 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -997,8 +997,8 @@ bool out_of_memory(struct oom_control *oc)
>  
>  /*
>   * The pagefault handler calls here because it is out of memory, so kill a
> - * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
> - * parallel oom killing is already in progress so do nothing.
> + * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
> + * killing is already in progress so do nothing.
>   */
>  void pagefault_out_of_memory(void)
>  {
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
