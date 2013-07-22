Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 309C16B0034
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 15:51:32 -0400 (EDT)
Message-ID: <51ED8D33.7050900@redhat.com>
Date: Mon, 22 Jul 2013 15:51:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: page_alloc: rearrange watermark checking in get_page_from_freelist
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374267325-22865-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/19/2013 04:55 PM, Johannes Weiner wrote:
> Allocations that do not have to respect the watermarks are rare
> high-priority events.  Reorder the code such that per-zone dirty
> limits and future checks important only to regular page allocations
> are ignored in these extraordinary situations.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
