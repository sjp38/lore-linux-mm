Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6B36F6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:06:37 -0500 (EST)
Received: by gxk24 with SMTP id 24so21151977gxk.6
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:06:35 -0800 (PST)
Date: Mon, 11 Jan 2010 14:04:14 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/4] mm/page_alloc : modify the return type of
 __free_one_page
Message-Id: <20100111140414.36cea1c1.minchan.kim@barrios-desktop>
In-Reply-To: <1263184634-15447-3-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
	<1263184634-15447-2-git-send-email-shijie8@gmail.com>
	<1263184634-15447-3-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 12:37:13 +0800
Huang Shijie <shijie8@gmail.com> wrote:

>   Modify the return type for __free_one_page.
> It will return 1 on success, and return 0 when
> the check of the compound page is failed.
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
