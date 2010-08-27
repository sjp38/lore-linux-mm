Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 458316B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 21:03:07 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2737089iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 18:03:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1282867897-31201-1-git-send-email-yinghan@google.com>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
Date: Fri, 27 Aug 2010 10:03:05 +0900
Message-ID: <AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello.

On Fri, Aug 27, 2010 at 9:11 AM, Ying Han <yinghan@google.com> wrote:
> Fix a missed place where checks nr_swap_pages to do shrink_active_list. Make the
> change that moves the check to common function inactive_anon_is_low.
>

Hmm.. AFAIR, we discussed it at that time but we concluded it's not good.
That's because nr_swap_pages < 0 means both "NO SWAP" and "NOT enough
swap space now". If we have a swap device or file but not enough space
now, we need to aging anon pages to make inactive list enough size.
Otherwise, working set pages would be swapped out more fast before
promotion.

That aging is done by kswapd so I think it's not big harmful in the system.
But if you want to remove aging completely in non-swap system, we need
to identify non swap system and not enough swap space. I thought we
need it for embedded system.

Thanks.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
