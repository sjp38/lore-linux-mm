Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E10488D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 21:26:27 -0500 (EST)
Received: by iwc10 with SMTP id 10so3178845iwc.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:26:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
References: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
Date: Fri, 18 Feb 2011 11:26:26 +0900
Message-ID: <AANLkTi=vRekoBFgHu-AXiLwTVTYLX-FFMBoF0twg1Rpg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix dubious code in __count_immobile_pages()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Feb 18, 2011 at 10:46 AM, Namhyung Kim <namhyung@gmail.com> wrote:
> When pfn_valid_within() failed 'iter' was incremented twice.
>
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nitpick.

I am not sure it's best. I don't like below trick.
iter += (1 << page_order(page)) - 1;

So we can change for loop with while as removing -1 trick of PageBuddy.
But if you don't like it, I don't mind it. :)

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
