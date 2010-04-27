Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C80A26B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:08:35 -0400 (EDT)
Message-ID: <4BD62AE3.2070302@redhat.com>
Date: Mon, 26 Apr 2010 20:08:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm,migration: During fork(), wait for migration to
 end if migration PTE is encountered
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1272321478-28481-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/26/2010 06:37 PM, Mel Gorman wrote:
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> At page migration, we replace pte with migration_entry, which has
> similar format as swap_entry and replace it with real pfn at the
> end of migration. But there is a race with fork()'s copy_page_range().

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
