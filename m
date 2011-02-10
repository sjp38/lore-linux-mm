Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8EAF8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:19:00 -0500 (EST)
Received: by pxi12 with SMTP id 12so271868pxi.14
        for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:18:58 -0800 (PST)
Subject: Re: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com>
References: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
	 <AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Feb 2011 22:18:49 +0900
Message-ID: <1297343929.1449.3.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-02-10 (ea(C)), 22:10 +0900, Minchan Kim:
> Hello Namhyung,
> 

Hi Minchan,


> On Thu, Feb 10, 2011 at 8:46 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> > Now I'm seeing that there are some cases to free all pages in a
> > pcp lists. In that case, just frees all pages in the lists instead
> > of being bothered with round-robin lists traversal.
> 
> I though about that but I didn't send the patch.
> That's because many cases which calls free_pcppages_bulk(,
> pcp->count,..) are slow path so it adds comparison overhead on fast
> path while it loses the effectiveness in slow path.
> 

Hmm.. How about adding unlikely() then? Doesn't it help much here?


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
