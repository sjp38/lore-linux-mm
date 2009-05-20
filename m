Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 234516B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 05:57:22 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so65113wah.22
        for <linux-mm@kvack.org>; Wed, 20 May 2009 02:58:15 -0700 (PDT)
Date: Wed, 20 May 2009 18:58:03 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/3] clean up setup_per_zone_pages_min
Message-Id: <20090520185803.e5b0698a.minchan.kim@barrios-desktop>
In-Reply-To: <20090520085416.GA27056@csn.ul.ie>
References: <20090520161853.1bfd415c.minchan.kim@barrios-desktop>
	<20090520085416.GA27056@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel. 

On Wed, 20 May 2009 09:54:16 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, May 20, 2009 at 04:18:53PM +0900, Minchan Kim wrote:
> > 
> > Mel changed zone->pages_[high/low/min] with zone->watermark array.
> > So, setup_per_zone_pages_min also have to be changed.
> > 
> 
> Just to be clear, this is a function renaming to match the new zone
> field name, not something I missed. As the function changes min, low and
> max, a better name might have been setup_per_zone_watermarks but whether

At first, I thouht, too. But It's handle of min_free_kbytes.
Documentation said, it's to compute a watermark[WMARK_MIN]. 
I think many people already used that knob to contorl pages_min to keep the 
low pages. 

So, I determined function name is proper now. 
If setup_per_zone_watermark is better than it, we also have to change with 
documentation. 

> you go with that name or not, this is better than what is there so;
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
