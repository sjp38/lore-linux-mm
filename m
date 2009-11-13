Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 585226B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 07:41:34 -0500 (EST)
Received: by pzk27 with SMTP id 27so2121289pzk.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 04:41:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
	 <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
Date: Fri, 13 Nov 2009 21:41:33 +0900
Message-ID: <28c262360911130441h24e45cd8l60e5e10aed0d3650@mail.gmail.com>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when deciding
	if kswapd is in trouble
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 4:30 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> If reclaim fails to make sufficient progress, the priority is raised.
> Once the priority is higher, kswapd starts waiting on congestion.
> However, on systems with large numbers of high-order atomics due to
> crappy network cards, it's important that kswapd keep working in
> parallel to save their sorry ass.
>
> This patch takes into account the order kswapd is reclaiming at before
> waiting on congestion. The higher the order, the longer it is before
> kswapd considers itself to be in trouble. The impact is that kswapd
> works harder in parallel rather than depending on direct reclaimers or
> atomic allocations to fail.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

It's make sense to me.
It can help high order atomic allocation which is a big problem of allocator. :)

Thanks Mel.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
