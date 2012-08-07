Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DC54D6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 09:30:18 -0400 (EDT)
Message-ID: <50211865.90702@redhat.com>
Date: Tue, 07 Aug 2012 09:30:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] mm: compaction: Capture a suitable high-order page
 immediately when it is made available
References: <1344342677-5845-1-git-send-email-mgorman@suse.de> <1344342677-5845-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On 08/07/2012 08:31 AM, Mel Gorman wrote:
> While compaction is moving pages to free up large contiguous blocks for
> allocation it races with other allocation requests that may steal these
> blocks or break them up. This patch alters direct compaction to capture a
> suitable free page as soon as it becomes available to reduce this race. It
> uses similar logic to split_free_page() to ensure that watermarks are
> still obeyed.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
