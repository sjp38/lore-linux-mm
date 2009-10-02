Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA9056B004F
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 04:00:48 -0400 (EDT)
Date: Fri, 2 Oct 2009 10:10:12 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] congestion_wait() don't use WRITE
Message-ID: <20091002081012.GH14918@kernel.dk>
References: <20091002170343.5F67.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091002170343.5F67.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 02 2009, KOSAKI Motohiro wrote:
> 
> commit 8aa7e847d (Fix congestion_wait() sync/async vs read/write confusion)
> replace WRITE with BLK_RW_ASYNC.
> Unfortunately, concurrent mm development made the unchanged place
> accidentally.

I see that was added after 2.6.31, and that is wrong. Your patch looks
good.

Acked-by: Jens Axboe <jens.axboe@oracle.com>

> 
> This patch fixes it too.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4a7b0d5..e4a915b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1088,7 +1088,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  	int lumpy_reclaim = 0;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
> -		congestion_wait(WRITE, HZ/10);
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
>  		if (fatal_signal_pending(current))
> -- 
> 1.6.0.GIT
> 
> 
> 

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
