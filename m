Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB9E8D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 05:04:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4222D3EE081
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:04:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B2E045DE58
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:04:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 109FE45DE55
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:04:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01C3B1DB8048
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:04:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5ABA1DB8047
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:04:10 +0900 (JST)
Date: Mon, 21 Feb 2011 18:57:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: fix dubious code in __count_immobile_pages()
Message-Id: <20110221185757.85dcaaf1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
References: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Feb 2011 10:46:26 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> When pfn_valid_within() failed 'iter' was incremented twice.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/page_alloc.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e8b02771ccea..bf83d1c1d648 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5380,10 +5380,9 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
>  
> -		if (!pfn_valid_within(check)) {
> -			iter++;
> +		if (!pfn_valid_within(check))
>  			continue;
> -		}
> +
>  		page = pfn_to_page(check);
>  		if (!page_count(page)) {
>  			if (PageBuddy(page))
> -- 
> 1.7.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
