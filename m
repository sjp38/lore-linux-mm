Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A4C346B004D
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 22:58:18 -0500 (EST)
Message-ID: <4B7CBAB4.2010003@redhat.com>
Date: Wed, 17 Feb 2010 22:57:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/12] Direct compact when a high-order allocation fails
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-9-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/12/2010 07:00 AM, Mel Gorman wrote:
> Ordinarily when a high-order allocation fails, direct reclaim is entered to
> free pages to satisfy the allocation.  With this patch, it is determined if
> an allocation failed due to external fragmentation instead of low memory
> and if so, the calling process will compact until a suitable page is
> freed. Compaction by moving pages in memory is considerably cheaper than
> paging out to disk and works where there are locked pages or no swap. If
> compaction fails to free a page of a suitable size, then reclaim will
> still occur.
>
> Direct compaction returns as soon as possible. As each block is compacted,
> it is checked if a suitable page has been freed and if so, it returns.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
