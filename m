Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15A5F6B0038
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 18:54:39 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j18so127071883ioe.3
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 15:54:39 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id z128si8031361itg.118.2017.01.15.15.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 15:54:38 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id o138so10715547ito.3
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 15:54:38 -0800 (PST)
Date: Sun, 15 Jan 2017 18:54:31 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: use rb_entry()
Message-ID: <20170115235431.GF14446@mtj.duckdns.org>
References: <5b23d0cb523f4719673a462ab1569ae99084337e.1483685419.git.geliangtang@gmail.com>
 <671275de093d93ddc7c6f77ddc0d357149691a39.1484306840.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <671275de093d93ddc7c6f77ddc0d357149691a39.1484306840.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jens Axboe <axboe@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2017 at 11:17:12PM +0800, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  mm/backing-dev.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 3bfed5ab..ffb77a1 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -410,8 +410,8 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
>  
>  	while (*node != NULL) {
>  		parent = *node;
> -		congested = container_of(parent, struct bdi_writeback_congested,
> -					 rb_node);
> +		congested = rb_entry(parent, struct bdi_writeback_congested,
> +				     rb_node);

I don't get the rb_entry() macro.  It's just another name for
container_of().  I have no objection to the patch but this macro is a
bit silly.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
