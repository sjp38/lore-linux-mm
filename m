Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 975806B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 12:21:41 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9749886qcs.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 09:21:40 -0800 (PST)
Message-ID: <4EFCA1A1.70507@gmail.com>
Date: Thu, 29 Dec 2011 12:21:37 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: fix typo in isolating lru pages
References: <CAJd=RBAp=ooYGoDqJG0qkUhRuYTsSKG9h+bUvC0dvuVCvfkCgQ@mail.gmail.com>
In-Reply-To: <CAJd=RBAp=ooYGoDqJG0qkUhRuYTsSKG9h+bUvC0dvuVCvfkCgQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

(12/29/11 7:38 AM), Hillf Danton wrote:
> It is not the tag page but the cursor page that we should process, and it looks
> a typo.
>
> Signed-off-by: Hillf Danton<dhillf@gmail.com>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton<akpm@linux-foundation.org>
> Cc: David Rientjes<rientjes@google.com>
> Cc: Hugh Dickins<hughd@google.com>
> ---
>
> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Thu Dec 29 20:23:30 2011
> @@ -1231,13 +1231,13 @@ static unsigned long isolate_lru_pages(u
>
>   				mem_cgroup_lru_del(cursor_page);
>   				list_move(&cursor_page->lru, dst);
> -				isolated_pages = hpage_nr_pages(page);
> +				isolated_pages = hpage_nr_pages(cursor_page);
>   				nr_taken += isolated_pages;
>   				nr_lumpy_taken += isolated_pages;
>   				if (PageDirty(cursor_page))
>   					nr_lumpy_dirty += isolated_pages;
>   				scan++;
> -				pfn += isolated_pages-1;
> +				pfn += isolated_pages - 1;
>   			} else {
>   				/*
>   				 * Check if the page is freed already.

Looks correct.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
