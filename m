Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 974666B0022
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 08:39:22 -0400 (EDT)
Received: by wwi18 with SMTP id 18so3341120wwi.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 05:39:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 1 Jun 2011 21:38:59 +0900
Message-ID: <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

2011/6/1 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
> Please be more polite to other people. After a197b59ae6 all allocations
> with GFP_DMA set on nodes without ZONE_DMA fail nearly silently (only
> one warning during bootup is emited, no matter how many things fail).
> This is a very crude change on behaviour. To be more civil, instead of
> failing emit noisy warnings each time smbd. tries to allocate a GFP_DMA
> memory on non-ZONE_DMA node.
>
> This change should be reverted after one or two major releases, but
> we should be more accurate rather than hoping for the best.
>
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Instaed of, shouldn't we revert a197b59ae6? Some arch don't have
DMA_ZONE at all.
and a197b59ae6 only care x86 embedded case. If we accept your patch, I
can imagine
other people will claim warn foold is a bug. ;)

However, I think, you should explain which platform and drivers hit
this breakage.
Otherwise developers can't learn which platform should care.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
