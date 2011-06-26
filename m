Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4EDD99000BD
	for <linux-mm@kvack.org>; Sun, 26 Jun 2011 18:47:18 -0400 (EDT)
Message-ID: <4E07B6D6.8070203@redhat.com>
Date: Sun, 26 Jun 2011 18:46:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/2] mm: introduce __invalidate_mapping_pages()
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com> <1308923350-7932-2-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308923350-7932-2-git-send-email-andrea@betterlinux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/24/2011 09:49 AM, Andrea Righi wrote:

> diff --git a/mm/truncate.c b/mm/truncate.c
> index 3a29a61..90f3a97 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -312,20 +312,27 @@ void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
>   EXPORT_SYMBOL(truncate_inode_pages);
>
>   /**
> - * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
> + * __invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
>    * @mapping: the address_space which holds the pages to invalidate
>    * @start: the offset 'from' which to invalidate
>    * @end: the offset 'to' which to invalidate (inclusive)
> + * @force: always drop pages when true (otherwise, reduce cache eligibility)

I don't like the parameter name "force".

The parameter determines whether or not pages actually get
invalidated, so I'm guessing the parameter name should
reflect the function...

Maybe something like "invalidate"?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
