Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A4EE6006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 09:23:40 -0400 (EDT)
Message-ID: <4C35D139.90006@redhat.com>
Date: Thu, 08 Jul 2010 09:23:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,
 not page order
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com> <20100708163934.CD37.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100708163934.CD37.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 07/08/2010 03:40 AM, KOSAKI Motohiro wrote:
> Fix simple argument error. Usually 'order' is very small value than
> lru_pages. then it can makes unnecessary icache dropping.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
