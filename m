Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AD7A6B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 21:23:57 -0400 (EDT)
Message-ID: <4C816760.4010807@redhat.com>
Date: Fri, 03 Sep 2010 17:23:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap
 system
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com> <20100903140649.09dee316.akpm@linux-foundation.org>
In-Reply-To: <20100903140649.09dee316.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 09/03/2010 05:06 PM, Andrew Morton wrote:

> We don't have any quantitative data on the effect of these excess tlb
> flushes, which makes it difficult to decide which kernel versions
> should receive this patch.
>
> Help?

I assume it is a relatively small performance optimization,
as well as a nice code cleanup ... so probably no real hurry
to get it upstream (next time you send Linus mm patches?),
and no real reason to have it backported to a -stable kernel
either.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
