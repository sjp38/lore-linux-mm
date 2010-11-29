Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A9B96B00A9
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 06:21:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oATBLct6026422
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 20:21:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DEAAE45DE56
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 20:21:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C886D45DE55
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 20:21:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC8681DB8038
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 20:21:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89EEE1DB8037
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 20:21:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX] vmstat: fix dirty threshold ordering
In-Reply-To: <20101129103845.GA1195@localhost>
References: <20101129103845.GA1195@localhost>
Message-Id: <20101129202124.82CC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 29 Nov 2010 20:21:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> The nr_dirty_[background_]threshold fields are misplaced before the
> numa_* fields, and users will read strange values.
> 
> This is the right order. Before patch, nr_dirty_background_threshold
> will read as 0 (the value from numa_miss).
> 
> 	numa_hit 128501
> 	numa_miss 0
> 	numa_foreign 0
> 	numa_interleave 7388
> 	numa_local 128501
> 	numa_other 0
> 	nr_dirty_threshold 144291
> 	nr_dirty_background_threshold 72145
> 
> Cc: Michael Rubin <mrubin@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Obviously. :-/

Thanks, Wu.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/vmstat.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-next.orig/mm/vmstat.c	2010-11-28 16:02:12.000000000 +0800
> +++ linux-next/mm/vmstat.c	2010-11-28 16:02:24.000000000 +0800
> @@ -750,8 +750,6 @@ static const char * const vmstat_text[] 
>  	"nr_shmem",
>  	"nr_dirtied",
>  	"nr_written",
> -	"nr_dirty_threshold",
> -	"nr_dirty_background_threshold",
>  
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
> @@ -761,6 +759,8 @@ static const char * const vmstat_text[] 
>  	"numa_local",
>  	"numa_other",
>  #endif
> +	"nr_dirty_threshold",
> +	"nr_dirty_background_threshold",
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  	"pgpgin",
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
