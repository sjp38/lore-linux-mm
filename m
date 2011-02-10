Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0A88D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:54:26 -0500 (EST)
Received: by pwj8 with SMTP id 8so411068pwj.14
        for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:53:19 -0800 (PST)
Subject: Re: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <AANLkTimcLgsdEm6XKESc34Z=nsJkZqz8H1jR-ARZo_Gq@mail.gmail.com>
References: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
	 <AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com>
	 <1297343929.1449.3.camel@leonhard>
	 <AANLkTimcLgsdEm6XKESc34Z=nsJkZqz8H1jR-ARZo_Gq@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Feb 2011 22:53:13 +0900
Message-ID: <1297345993.1449.10.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-02-10 (ea(C)), 22:38 +0900, Minchan Kim:
> > Hmm.. How about adding unlikely() then? Doesn't it help much here?
> 
> Yes. It would help but I am not sure how much it is.
> AFAIR, when Mel submit the patch, he tried to prove the effectiveness
> with some experiment and profiler.
> I think if you want it really, we might need some number.
> I am not sure it's worth.
> 

OK. Thanks for the comments. :)

And it would be really great if you (or somebody) told me how could I
make the numbers on my desktop.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
