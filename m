Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3512F6B01CC
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:41:14 -0400 (EDT)
Message-ID: <4B9E38EA.6040205@redhat.com>
Date: Mon, 15 Mar 2010 09:40:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove return value of putback_lru_pages
References: <1268658994.1889.8.camel@barrios-desktop>
In-Reply-To: <1268658994.1889.8.camel@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/15/2010 09:16 AM, Minchan Kim wrote:
>
> Now putback_lru_page never can fail.
> So it doesn't matter count of "the number of pages put back".
>
> In addition, users of this functions don't use return value.
>
> Let's remove unnecessary code.
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
