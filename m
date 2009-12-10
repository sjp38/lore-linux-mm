Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 118B26B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 12:32:01 -0500 (EST)
Date: Thu, 10 Dec 2009 11:30:46 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC mm][PATCH 1/5] mm counter cleanup
In-Reply-To: <20091210163326.28bb7eb8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912101126480.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com> <20091210163326.28bb7eb8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:

> This patch modifies it to
>   - Define them in mm.h as inline functions
>   - Use array instead of macro's name creation. For making easier to add
>     new coutners.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

> @@ -454,8 +456,8 @@ static struct mm_struct * mm_init(struct
>  		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
>  	mm->core_state = NULL;
>  	mm->nr_ptes = 0;
> -	set_mm_counter(mm, file_rss, 0);
> -	set_mm_counter(mm, anon_rss, 0);
> +	for (i = 0; i < NR_MM_COUNTERS; i++)
> +		set_mm_counter(mm, i, 0);


memset? Or add a clear_mm_counter function? This also occurred earlier in
init_rss_vec().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
