Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C76CB6B00AB
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:04:53 -0500 (EST)
Received: by pxi26 with SMTP id 26so2063217pxi.1
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 08:04:52 -0800 (PST)
Subject: Re: [PATCH] shmem : remove redundant code
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Mar 2010 01:04:45 +0900
Message-ID: <1268064285.1254.6.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-08 at 17:33 +0800, Huang Shijie wrote:
> The  prep_new_page() will call set_page_private(page, 0) to initiate
> the page.
> 
> So the code is redundant.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Long time ago, nr_swapped named is meaningful as a comment at least.
But as split page table lock is introduced in 4c21e2f2441, it was 
changed by just set_page_private. 
So even it's not meaningful any more as a comment, I think. 
So let's remove redundant code. 

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
