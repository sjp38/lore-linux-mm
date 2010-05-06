Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 601586B02B8
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:34:34 -0400 (EDT)
Message-ID: <4BE2E167.2030806@redhat.com>
Date: Thu, 06 May 2010 11:33:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,compaction: Do not schedule work on other CPUs for
 compaction
References: <20100506150808.GC8704@csn.ul.ie>
In-Reply-To: <20100506150808.GC8704@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/06/2010 11:08 AM, Mel Gorman wrote:
> Migration normally requires a call to migrate_prep() as a preparation
> step. This schedules work on all CPUs for pagevecs to be drained. This
> makes sense for move_pages and memory hot-remove but is unnecessary
> for memory compaction.
>
> To avoid queueing work on multiple CPUs, this patch introduces
> migrate_prep_local() which drains just local pagevecs.
>
> This patch can be either merged with mmcompaction-memory-compaction-core.patch
> or placed immediately after it to clarify why migrate_prep_local() was
> introduced.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
