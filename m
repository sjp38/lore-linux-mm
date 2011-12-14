Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0260D6B0296
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 19:45:09 -0500 (EST)
Date: Tue, 13 Dec 2011 16:45:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] vmscan/trace: Add 'active' and 'file' info to
 trace_mm_vmscan_lru_isolate.
Message-Id: <20111213164507.fbee477c.akpm@linux-foundation.org>
In-Reply-To: <1323614784-2924-1-git-send-email-tm@tao.ma>
References: <1323614784-2924-1-git-send-email-tm@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>

On Sun, 11 Dec 2011 22:46:24 +0800
Tao Ma <tm@tao.ma> wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1103,7 +1103,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
>  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		struct list_head *src, struct list_head *dst,
>  		unsigned long *scanned, int order, isolate_mode_t mode,
> -		int file)
> +		int active, int file)
>  {
>  	unsigned long nr_taken = 0;
>  	unsigned long nr_lumpy_taken = 0;
> @@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			nr_to_scan, scan,
>  			nr_taken,
>  			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
> -			mode);
> +			mode, active, file);
>  	return nr_taken;
>  }
>  
> @@ -1237,7 +1237,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
>  	if (file)
>  		lru += LRU_FILE;
>  	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
> -								mode, file);
> +							mode, active, file);
>  }

It would be nice to avoid adding permanent runtime overhead on behalf
of tracing.  It sounds like sending "mode" will satisfy this - please
check that in the v2 patch. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
