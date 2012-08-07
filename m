Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E899A6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:23:42 -0400 (EDT)
Message-ID: <502116DA.4040409@redhat.com>
Date: Tue, 07 Aug 2012 09:23:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by reclaim/compaction
 based on failures
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/07/2012 08:31 AM, Mel Gorman wrote:
> If allocation fails after compaction then compaction may be deferred for
> a number of allocation attempts. If there are subsequent failures,
> compact_defer_shift is increased to defer for longer periods. This patch
> uses that information to scale the number of pages reclaimed with
> compact_defer_shift until allocations succeed again.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
