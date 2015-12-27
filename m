Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1AB6B029A
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 12:12:24 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id k189so189545557qkc.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 09:12:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h66si60661967qgf.80.2015.12.27.09.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 09:12:23 -0800 (PST)
Date: Sun, 27 Dec 2015 12:12:17 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH trivial] lib+mm: fix few spelling mistakes
Message-ID: <20151227171216.GA624@t510.redhat.com>
References: <1451224703-22358-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451224703-22358-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org, Bogdan Sikora <bsikora@redhat.com>, linux-mm@kvack.org, Kent Overstreet <kmo@daterainc.com>, Jan Kara <jack@suse.cz>

On Sun, Dec 27, 2015 at 02:58:23PM +0100, Jiri Slaby wrote:
> From: Bogdan Sikora <bsikora@redhat.com>
> 
> All are in comments.
> 
> Signed-off-by: Bogdan Sikora <bsikora@redhat.com>
> Cc: <linux-mm@kvack.org>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Kent Overstreet <kmo@daterainc.com>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> ---
>  lib/flex_proportions.c  | 2 +-
>  lib/percpu-refcount.c   | 2 +-
>  mm/balloon_compaction.c | 4 ++--
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index 8f25652f40d4..a71cf1bdd4c9 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -17,7 +17,7 @@
>   *
>   *   \Sum_{j} p_{j} = 1,
>   *
> - * This formula can be straightforwardly computed by maintaing denominator
> + * This formula can be straightforwardly computed by maintaining denominator
>   * (let's call it 'd') and for each event type its numerator (let's call it
>   * 'n_j'). When an event of type 'j' happens, we simply need to do:
>   *   n_j++; d++;
> diff --git a/lib/percpu-refcount.c b/lib/percpu-refcount.c
> index 6111bcb28376..2c1f256fdc84 100644
> --- a/lib/percpu-refcount.c
> +++ b/lib/percpu-refcount.c
> @@ -12,7 +12,7 @@
>   * particular cpu can (and will) wrap - this is fine, when we go to shutdown the
>   * percpu counters will all sum to the correct value
>   *
> - * (More precisely: because moduler arithmatic is commutative the sum of all the
> + * (More precisely: because moduler arithmetic is commutative the sum of all the
>   * percpu_count vars will be equal to what it would have been if all the gets
>   * and puts were done to a single integer, even if some of the percpu integers
>   * overflow or underflow).
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index d3116be5a00f..59c2bc8a1efc 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -13,10 +13,10 @@
>  /*
>   * balloon_page_enqueue - allocates a new page and inserts it into the balloon
>   *			  page list.
> - * @b_dev_info: balloon device decriptor where we will insert a new page to
> + * @b_dev_info: balloon device descriptor where we will insert a new page to
>   *
>   * Driver must call it to properly allocate a new enlisted balloon page
> - * before definetively removing it from the guest system.
> + * before definitively removing it from the guest system.
>   * This function returns the page address for the recently enqueued page or
>   * NULL in the case we fail to allocate a new page this turn.
>   */
> -- 
> 2.6.4
>
Thanks!
 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
