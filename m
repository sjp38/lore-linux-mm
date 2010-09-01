Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6072B6B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:51:25 -0400 (EDT)
Message-ID: <4C7E5A52.7080806@redhat.com>
Date: Wed, 01 Sep 2010 09:51:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan,tmpfs: treat used once pages on tmpfs as used
 once
References: <20100901103653.974C.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100901103653.974C.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 08/31/2010 09:37 PM, KOSAKI Motohiro wrote:
> When a page has PG_referenced, shrink_page_list() discard it only
> if it is no dirty. This rule works completely fine if the backend
> filesystem is regular one. PG_dirty is good signal that it was used
> recently because flusher thread clean pages periodically. In addition,
> page writeback is costly rather than simple page discard.
>
> However, When a page is on tmpfs, this heuristic don't works because
> flusher thread don't writeback tmpfs pages. then, tmpfs pages always
> rotate lru twice at least and it makes unnecessary lru churn. Merely
> tmpfs streaming io shouldn't cause large anonymous page swap-out.
>
> This patch remove this unncessary reclaim bonus of tmpfs pages.
>
> Cc: Hugh Dickins<hughd@google.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Rik van Riel<riel@redhat.com>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
