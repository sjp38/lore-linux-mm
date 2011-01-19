Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C073E6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:17:23 -0500 (EST)
Received: by iyj17 with SMTP id 17so264310iyj.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:17:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
Date: Wed, 19 Jan 2011 10:17:22 +0900
Message-ID: <AANLkTi=FWDf7DMA=huWzWa6a9cObKKcLFeoPvk3ynTfP@mail.gmail.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 8:18 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> Andrew,
>
> Can you please apply this to -mm, for 2.6.39?
>
> v4:
> - updated to latest -git
> - added acks
> - updated changelog
>
> Thanks,
> Miklos

6072d13c added freepage callback of filesystem.
So, all callers of __remove_from_page_cache handles it now.
Although NFS only need it and only FUSE use replace_page_cache_page,
do we have to handle it in replace_page_cache_page, too?

Or we pass mapping to __remove_from_page_cache and handle it in
__remove_from_page_cache?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
