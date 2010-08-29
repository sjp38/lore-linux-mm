Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1552A6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 11:49:18 -0400 (EDT)
Message-ID: <4C7A8173.5060306@redhat.com>
Date: Sun, 29 Aug 2010 11:49:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap
 system
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 08/29/2010 11:43 AM, Minchan Kim wrote:

> This patch prevents unnecessary anon pages demotion in not-swapon and
> non-configured swap system. Of course, it could make side effect that
> hot anon pages could swap out when admin does swap on.
> But I think sooner or later it would be steady state.
> So it's not a big problem.
> We could lose someting but gain more thing(TLB flush and unnecessary
> function call to demote anon pages).

A agree that is not a big worry.  I expect virtually all the
systems with swap space will do swapon at boot time.

> I used total_swap_pages because we want to age anon pages
> even though swap full happens.
>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Reported-by: Ying Han<yinghan@google.com>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
