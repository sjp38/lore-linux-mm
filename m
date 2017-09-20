Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C52B76B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:35:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b9so3272397wra.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:35:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y35si1828556edb.258.2017.09.20.07.35.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:35:39 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:35:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/6] fs-writeback: make wb_start_writeback() static
Message-ID: <20170920143539.GE11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-5-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-5-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue 19-09-17 13:53:05, Jens Axboe wrote:
> We don't have any callers outside of fs-writeback.c anymore,
> make it private.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/fs-writeback.c           | 4 ++--
>  include/linux/backing-dev.h | 2 --
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 03fda0830bf8..7564347914f8 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -933,8 +933,8 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
>  
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
> -void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> -			bool range_cyclic, enum wb_reason reason)
> +static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> +			       bool range_cyclic, enum wb_reason reason)
>  {
>  	struct wb_writeback_work *work;
>  
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 854e1bdd0b2a..157e950a70dc 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -38,8 +38,6 @@ static inline struct backing_dev_info *bdi_alloc(gfp_t gfp_mask)
>  	return bdi_alloc_node(gfp_mask, NUMA_NO_NODE);
>  }
>  
> -void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> -			bool range_cyclic, enum wb_reason reason);
>  void wb_start_background_writeback(struct bdi_writeback *wb);
>  void wb_workfn(struct work_struct *work);
>  void wb_wakeup_delayed(struct bdi_writeback *wb);
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
