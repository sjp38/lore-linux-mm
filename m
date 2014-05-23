Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id E80486B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 06:49:49 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so7619264qgf.17
        for <linux-mm@kvack.org>; Fri, 23 May 2014 03:49:49 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1lp0145.outbound.protection.outlook.com. [207.46.163.145])
        by mx.google.com with ESMTPS id b62si3012733qgb.26.2014.05.23.03.49.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 May 2014 03:49:49 -0700 (PDT)
Date: Fri, 23 May 2014 18:49:14 +0800
From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH v2] mm, compaction: properly signal and act upon lock and
 need_sched() contention
Message-ID: <20140523104911.GA7306@dragon>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
 <1400233673-11477-1-git-send-email-vbabka@suse.cz>
 <CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com>
 <CAAQ0ZWQDVxAzZVm86ATXd1JGUVoLXj_Y5Ske7htxH_6a4GPKRg@mail.gmail.com>
 <537F082F.50501@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <537F082F.50501@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Kevin Hilman <khilman@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David
 Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On Fri, May 23, 2014 at 10:34:55AM +0200, Vlastimil Babka wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 23 May 2014 10:18:56 +0200
> Subject: mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention-fix2
> 
> Step 1: Change function name and comment between v1 and v2 so that the return
>         value signals the opposite thing.
> Step 2: Change the call sites to reflect the opposite return value.
> Step 3: ???
> Step 4: Make a complete fool of yourself.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Tested-by: Shawn Guo <shawn.guo@linaro.org>

> ---
>  mm/compaction.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a525cd4..5175019 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -237,13 +237,13 @@ static inline bool compact_should_abort(struct compact_control *cc)
>  	if (need_resched()) {
>  		if (cc->mode == MIGRATE_ASYNC) {
>  			cc->contended = true;
> -			return false;
> +			return true;
>  		}
>  
>  		cond_resched();
>  	}
>  
> -	return true;
> +	return false;
>  }
>  
>  /* Returns true if the page is within a block suitable for migration to */
> -- 
> 1.8.4.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
