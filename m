Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 049716B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:51:06 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y15so4610789wrc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:51:05 -0800 (PST)
Received: from outbound-smtp22.blacknight.com (outbound-smtp22.blacknight.com. [81.17.249.190])
        by mx.google.com with ESMTPS id y89si3523893eda.212.2017.12.07.11.51.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 11:51:04 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp22.blacknight.com (Postfix) with ESMTPS id 2932FB8C12
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:51:04 +0000 (GMT)
Date: Thu, 7 Dec 2017 19:51:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-ID: <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171207170314.4419-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Thu, Dec 07, 2017 at 06:03:14PM +0100, Lucas Stach wrote:
> Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
> a list of pages) we see excessive IRQ disabled times of up to 250ms on an
> embedded ARM system (tracing overhead included).
> 
> This is due to graphics buffers being freed back to the system via
> release_pages(). Graphics buffers can be huge, so it's not hard to hit
> cases where the list of pages to free has 2048 entries. Disabling IRQs
> while freeing all those pages is clearly not a good idea.
> 

250ms to free 2048 entries? That seems excessive but I guess the
embedded ARM system is not that fast.

> Introduce a batch limit, which allows IRQ servicing once every few pages.
> The batch count is the same as used in other parts of the MM subsystem
> when dealing with IRQ disabled regions.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Thanks.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
