Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8B1FF6B01B6
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:33:36 -0400 (EDT)
Received: by iwn36 with SMTP id 36so318629iwn.14
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100625181221.805A.A69D9226@jp.fujitsu.com>
References: <20100625181221.805A.A69D9226@jp.fujitsu.com>
Date: Sun, 27 Jun 2010 08:33:34 +0900
Message-ID: <AANLkTinXLZD-8QkMU8T5xqnGg2Fl55Nkzd6HzNT1FhPo@mail.gmail.com>
Subject: Re: [PATCH] vmscan: recalculate lru_pages on each priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 6:13 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> shrink_zones() need relatively long time. and lru_pages can be
> changed dramatically while shrink_zones().
> then, lru_pages need recalculate on each priority.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Kosaki's patch seems to be reasonable to me.

I looked into background reclaim. It already has done until now.
(ie, background : dynamic lru_pages in each priority, direct reclaim :
static lru_pages in each priority).
Firstly In 53dce00d, Andrew did it.
Why does he do it with unbalance?
I guess it was just a mistake.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
