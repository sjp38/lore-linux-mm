Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A36778D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 06:15:46 -0500 (EST)
Date: Sun, 14 Nov 2010 12:03:36 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] cleanup kswapd()
In-Reply-To: <20101114180505.BEE2.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LNX.2.00.1011141202430.3460@swampdragon.chaosbits.net>
References: <20101114180505.BEE2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:

> 
> Currently, kswapd() function has deeper nest and it slightly harder to
> read. cleanup it.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   71 +++++++++++++++++++++++++++++++---------------------------
>  1 files changed, 38 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8cc90d5..82ffe5f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2364,6 +2364,42 @@ out:
>  	return sc.nr_reclaimed;
>  }
>  
> +void kswapd_try_to_sleep(pg_data_t *pgdat, int order)

Shouldn't this be

  static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)

??


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
