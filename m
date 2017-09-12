Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 638E86B030C
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 00:48:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q76so18785910pfq.5
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 21:48:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l30sor2283390pgc.80.2017.09.11.21.48.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 21:48:07 -0700 (PDT)
Date: Tue, 12 Sep 2017 13:48:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/5] mm:swap: introduce SWP_SYNCHRONOUS_IO
Message-ID: <20170912044803.GB3963@jagdpanzerIV.localdomain>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
 <1505183833-4739-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505183833-4739-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (09/12/17 11:37), Minchan Kim wrote:
[..]
> If rw-page based fast storage is used for swap devices, we need to
> detect it to enhance swap IO operations.
> This patch is preparation for optimizing of swap-in operation with
> next patch.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/swap.h | 3 ++-
>  mm/swapfile.c        | 3 +++
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 8a807292037f..0f54b491e118 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -170,8 +170,9 @@ enum {
>  	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
>  	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
>  	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
> +	SWP_SYNCHRONOUS_IO = (1<<11),	/* synchronous IO is efficient */
a nitpick:                  (1 << 11)

	-ss

>  					/* add others here before... */
> -	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
> +	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
>  };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
