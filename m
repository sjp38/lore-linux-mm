Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BBDC6B0083
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 12:55:48 -0500 (EST)
Date: Thu, 10 Dec 2009 11:55:25 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC mm][PATCH 3/5] counting swap ents per mm
In-Reply-To: <20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912101153130.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com> <20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:

> Index: mmotm-2.6.32-Dec8/mm/rmap.c
> ===================================================================
> --- mmotm-2.6.32-Dec8.orig/mm/rmap.c
> +++ mmotm-2.6.32-Dec8/mm/rmap.c
> @@ -814,7 +814,7 @@ int try_to_unmap_one(struct page *page,
>  	update_hiwater_rss(mm);
>
>  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> -		if (PageAnon(page))
> +		if (PageAnon(page)) /* Not increments swapents counter */
>  			dec_mm_counter(mm, MM_ANONPAGES);

Remove comment. Its not helping.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
