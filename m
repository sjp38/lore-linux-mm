Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 401EB8D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:27:57 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E74C63EE0C5
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:27:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C6A6F45DE5A
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:27:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE37445DE57
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:27:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7046EE18003
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:27:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36D8DE08003
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:27:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove inline from scan_swap_map
In-Reply-To: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
References: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
Message-Id: <20110307102754.89EA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 10:27:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org

> scan_swap_map is a large function (224 lines), with several loops and a
> complex control flow involving several gotos.
> 
> Given all that, it is a bit silly that is is marked as inline. The
> compiler agrees with me: on a x86-64 compile, it did not inline the
> function.
> 
> Remove the "inline" and let the compiler decide instead.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> ---
>  mm/swapfile.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 0341c57..8ed42e7 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -212,8 +212,8 @@ static int wait_for_discard(void *word)
>  #define SWAPFILE_CLUSTER	256
>  #define LATENCY_LIMIT		256
>  
> -static inline unsigned long scan_swap_map(struct swap_info_struct *si,
> -					  unsigned char usage)
> +static unsigned long scan_swap_map(struct swap_info_struct *si,
> +				   unsigned char usage)

I agree.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
