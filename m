Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0752B6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 02:11:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g26-v6so164485pfo.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:11:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q12-v6si526675pgg.532.2018.07.25.23.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 23:11:18 -0700 (PDT)
Date: Thu, 26 Jul 2018 08:11:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: fix page_freeze_refs in comment.
Message-ID: <20180726061115.GR28386@dhcp22.suse.cz>
References: <1532561657-98783-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532561657-98783-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Thu 26-07-18 07:34:17, Jiang Biao wrote:
> page_freeze_refs has already been relplaced by page_ref_freeze, but
> it is not modified in the comment.

Hmm
$ git grep page_refs_freeze origin/master
$

The same is the case in the linux-next tree. Which tree are you looking at?

> 
> Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 03822f8..d29e207 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -744,7 +744,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		refcount = 2;
>  	if (!page_ref_freeze(page, refcount))
>  		goto cannot_free;
> -	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
> +	/* note: atomic_cmpxchg in page_refs_freeze provides the smp_rmb */
>  	if (unlikely(PageDirty(page))) {
>  		page_ref_unfreeze(page, refcount);
>  		goto cannot_free;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
