Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7A6F56B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 22:32:58 -0500 (EST)
Message-ID: <4EEABBE3.1050309@redhat.com>
Date: Thu, 15 Dec 2011 22:32:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: compaction: Determine if dirty pages can be
 migrated without blocking within ->migratepage
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> Asynchronous compaction is used when allocating transparent hugepages
> to avoid blocking for long periods of time. Due to reports of
> stalling, there was a debate on disabling synchronous compaction
> but this severely impacted allocation success rates. Part of the
> reason was that many dirty pages are skipped in asynchronous compaction
> by the following check;
>
> 	if (PageDirty(page)&&  !sync&&
> 		mapping->a_ops->migratepage != migrate_page)
> 			rc = -EBUSY;
>
> This skips over all mapping aops using buffer_migrate_page()
> even though it is possible to migrate some of these pages without
> blocking. This patch updates the ->migratepage callback with a "sync"
> parameter. It is the responsibility of the callback to fail gracefully
> if migration would block.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
