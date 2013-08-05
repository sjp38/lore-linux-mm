Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 050B16B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:38:42 -0400 (EDT)
Message-ID: <51FFF122.6020203@redhat.com>
Date: Mon, 05 Aug 2013 14:38:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] mm: zone_reclaim: compaction: add compaction to zone_reclaim_mode
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com> <1375459596-30061-10-git-send-email-aarcange@redhat.com> <20130804165526.GG27921@redhat.com>
In-Reply-To: <20130804165526.GG27921@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On 08/04/2013 12:55 PM, Andrea Arcangeli wrote:
> On Fri, Aug 02, 2013 at 06:06:36PM +0200, Andrea Arcangeli wrote:
>> +		need_compaction = false;
>
> This should be changed to "*need_compaction = false". It's actually a
> cleanup because it's a nooperational change at runtime.
> need_compaction was initialized to false by the only caller so it
> couldn't harm. But it's better to fix it to avoid
> confusion. Alternatively the above line can be dropped entirely but I
> thought it was cleaner to have a defined value as result of the
> function.
>
> Found by Fengguang kbuild robot.
>
> A new replacement patch 9/9 is appended below:
>
> ===
> From: Andrea Arcangeli <aarcange@redhat.com>
> Subject: [PATCH] mm: zone_reclaim: compaction: add compaction to
>   zone_reclaim_mode
>
> This adds compaction to zone_reclaim so THP enabled won't decrease the
> NUMA locality with /proc/sys/vm/zone_reclaim_mode > 0.
>
> It is important to boot with numa_zonelist_order=n (n means nodes) to
> get more accurate NUMA locality if there are multiple zones per node.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
