Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 67B148D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 15:21:05 -0500 (EST)
Message-ID: <4D4F0291.4070301@redhat.com>
Date: Sun, 06 Feb 2011 15:20:33 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Add hook of freepage
References: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

On 02/06/2011 10:08 AM, Minchan Kim wrote:
> Recently, "Call the filesystem back whenever a page is removed from
> the page cache(6072d13c)" added new freepage hook in page cache
> drop function.
>
> So, replace_page_cache_page should call freepage to support
> page cleanup to fs.
>
> Cc: Miklos Szeredi<mszeredi@suse.cz>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
