Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F245F60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:22:29 -0500 (EST)
Message-ID: <4B38246C.3020209@redhat.com>
Date: Sun, 27 Dec 2009 22:22:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page
 in LRU list.
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
In-Reply-To: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 12/27/2009 09:53 PM, Minchan Kim wrote:
>
> VM doesn't add zero page to LRU list.
> It means zero page's churning in LRU list is pointless.
>
> As a matter of fact, zero page can't be promoted by mark_page_accessed
> since it doesn't have PG_lru.
>
> This patch prevent unecessary mark_page_accessed call of zero page
> alghouth caller want FOLL_TOUCH.
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

The code looks correct, but I wonder how frequently we run into
the zero page in this code, vs. how much the added cost is of
having this extra code in follow_page.

What kind of problem were you running into that motivated you
to write this patch?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
