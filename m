Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BABBD6B40C5
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:42:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c14-v6so3860764qtc.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:42:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x9-v6si5044296qkl.52.2018.08.27.06.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 06:42:35 -0700 (PDT)
Date: Mon, 27 Aug 2018 09:42:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/3] mm, mmu_notifier: be explicit about range invalition
 non-blocking mode
Message-ID: <20180827134231.GA3930@redhat.com>
References: <20180827112623.8992-1-mhocko@kernel.org>
 <20180827112623.8992-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827112623.8992-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Aug 27, 2018 at 01:26:22PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> If invalidate_range_start is called for !blocking mode then all
> callbacks have to guarantee they will no block/sleep. The same obviously
> applies to invalidate_range_end because this operation pairs with the
> former and they are called from the same context. Make sure this is
> appropriately documented.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>


> ---
>  include/linux/mmu_notifier.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 133ba78820ee..698e371aafe3 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -153,7 +153,9 @@ struct mmu_notifier_ops {
>  	 *
>  	 * If blockable argument is set to false then the callback cannot
>  	 * sleep and has to return with -EAGAIN. 0 should be returned
> -	 * otherwise.
> +	 * otherwise. Please note that if invalidate_range_start approves
> +	 * a non-blocking behavior then the same applies to
> +	 * invalidate_range_end.
>  	 *
>  	 */
>  	int (*invalidate_range_start)(struct mmu_notifier *mn,
> -- 
> 2.18.0
> 
