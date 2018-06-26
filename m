Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC7926B0007
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:06:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n2-v6so357366edr.5
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 05:06:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15-v6si859200edh.66.2018.06.26.05.06.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 05:06:26 -0700 (PDT)
Date: Tue, 26 Jun 2018 14:06:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: update stale account_page_redirty() comment
Message-ID: <20180626120624.duicgmjjmzhpqao4@quack2.suse.cz>
References: <20180625171526.173483-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180625171526.173483-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 25-06-18 10:15:26, Greg Thelen wrote:
> commit 93f78d882865 ("writeback: move backing_dev_info->bdi_stat[] into
> bdi_writeback") replaced BDI_DIRTIED with WB_DIRTIED in
> account_page_redirty().  Update comment to track that change.
>   BDI_DIRTIED => WB_DIRTIED
>   BDI_WRITTEN => WB_WRITTEN
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/page-writeback.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 337c6afb3345..6551d3b0dc30 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2490,8 +2490,8 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
>  
>  /*
>   * Call this whenever redirtying a page, to de-account the dirty counters
> - * (NR_DIRTIED, BDI_DIRTIED, tsk->nr_dirtied), so that they match the written
> - * counters (NR_WRITTEN, BDI_WRITTEN) in long term. The mismatches will lead to
> + * (NR_DIRTIED, WB_DIRTIED, tsk->nr_dirtied), so that they match the written
> + * counters (NR_WRITTEN, WB_WRITTEN) in long term. The mismatches will lead to
>   * systematic errors in balanced_dirty_ratelimit and the dirty pages position
>   * control.
>   */
> -- 
> 2.18.0.rc2.346.g013aa6912e-goog
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
