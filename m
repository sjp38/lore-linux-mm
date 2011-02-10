Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DD04D8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:10:41 -0500 (EST)
Received: by iwc10 with SMTP id 10so1287129iwc.14
        for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:10:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
References: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
Date: Thu, 10 Feb 2011 22:10:38 +0900
Message-ID: <AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Namhyung,

On Thu, Feb 10, 2011 at 8:46 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> Now I'm seeing that there are some cases to free all pages in a
> pcp lists. In that case, just frees all pages in the lists instead
> of being bothered with round-robin lists traversal.

I though about that but I didn't send the patch.
That's because many cases which calls free_pcppages_bulk(,
pcp->count,..) are slow path so it adds comparison overhead on fast
path while it loses the effectiveness in slow path.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
