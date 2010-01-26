Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EB9426B0089
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 19:42:56 -0500 (EST)
Date: Tue, 26 Jan 2010 01:42:48 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] trivial grammar fix: if and only if
In-Reply-To: <1264451889-10234-1-git-send-email-u.kleine-koenig@pengutronix.de>
Message-ID: <alpine.LNX.2.00.1001260142380.30977@pobox.suse.cz>
References: <1264451889-10234-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nico@marvell.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 2010, Uwe Kleine-KA?nig wrote:

> Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
> Cc: Nicolas Pitre <nico@marvell.com>
> ---
>  mm/highmem.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/highmem.c b/mm/highmem.c
> index 9c1e627..bed8a8b 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -220,7 +220,7 @@ EXPORT_SYMBOL(kmap_high);
>   * @page: &struct page to pin
>   *
>   * Returns the page's current virtual memory address, or NULL if no mapping
> - * exists.  When and only when a non null address is returned then a
> + * exists.  If and only if a non null address is returned then a
>   * matching call to kunmap_high() is necessary.
>   *
>   * This can be called from any context.

Applied, thanks.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
