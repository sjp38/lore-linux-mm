Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BA6856B0082
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:26:09 -0400 (EDT)
Received: by pxi37 with SMTP id 37so309705pxi.12
        for <linux-mm@kvack.org>; Wed, 20 May 2009 00:26:33 -0700 (PDT)
Date: Wed, 20 May 2009 16:26:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/3] clean up setup_per_zone_pages_min
Message-Id: <20090520162623.1e03a5e4.minchan.kim@barrios-desktop>
In-Reply-To: <20090520162231.7446.A69D9226@jp.fujitsu.com>
References: <20090520161853.1bfd415c.minchan.kim@barrios-desktop>
	<20090520162231.7446.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 May 2009 16:23:46 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > 
> > Mel changed zone->pages_[high/low/min] with zone->watermark array.
> > So, setup_per_zone_pages_min also have to be changed.
> 
> Only naming change?
> if so, the description sould talk about this explicitly.
> 
>  - kosaki
> 

OK. I will add it in next version. 
Thanks, Kosaki. 

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
