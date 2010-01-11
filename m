Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 032436B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:02:34 -0500 (EST)
Received: by ywh5 with SMTP id 5so44832911ywh.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:02:33 -0800 (PST)
Date: Mon, 11 Jan 2010 14:00:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/4] mm/page_alloc : rename rmqueue_bulk to
 rmqueue_single
Message-Id: <20100111140013.956da543.minchan.kim@barrios-desktop>
In-Reply-To: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 12:37:11 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> There is only one place calls rmqueue_bulk to allocate the single
> pages. So rename it to rmqueue_single, and remove an argument
> order.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
