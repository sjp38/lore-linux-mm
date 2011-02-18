Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7AC58D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 22:00:36 -0500 (EST)
Received: by yxl31 with SMTP id 31so1486347yxl.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 19:00:35 -0800 (PST)
Subject: Re: [PATCH] mm: fix dubious code in __count_immobile_pages()
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <AANLkTi=vRekoBFgHu-AXiLwTVTYLX-FFMBoF0twg1Rpg@mail.gmail.com>
References: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
	 <AANLkTi=vRekoBFgHu-AXiLwTVTYLX-FFMBoF0twg1Rpg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 12:00:28 +0900
Message-ID: <1297998028.1440.7.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2011-02-18 (e,?), 11:26 +0900, Minchan Kim:
> On Fri, Feb 18, 2011 at 10:46 AM, Namhyung Kim <namhyung@gmail.com> wrote:
> > When pfn_valid_within() failed 'iter' was incremented twice.
> >
> > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Nitpick.
> 
> I am not sure it's best. I don't like below trick.
> iter += (1 << page_order(page)) - 1;
> 
> So we can change for loop with while as removing -1 trick of PageBuddy.
> But if you don't like it, I don't mind it. :)
> 
> Thanks!
> 

Hi Minchan,

Either is fine to me. But I think current code would be shorter.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
