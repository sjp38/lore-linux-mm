Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 54B416B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 02:20:25 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so3059584pdi.25
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 23:20:25 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id bc9si14693382pbd.13.2014.06.01.23.20.23
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 23:20:24 -0700 (PDT)
Date: Mon, 2 Jun 2014 15:23:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140602062344.GB7713@js1304-P5Q-DELUXE>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
 <53883902.8020701@lge.com>
 <CAAmzW4Nyic0VC9W16ZbjsZtNGGBet4HBDomQfMi-OvMGMKv9iw@mail.gmail.com>
 <538C1196.9000608@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <538C1196.9000608@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>

On Mon, Jun 02, 2014 at 02:54:30PM +0900, Gioh Kim wrote:
> I found 2 problems at my platform.
> 
> 1st is occured when I set CMA size 528MB and total memory is 960MB.
> I print some values in adjust_managed_cma_page_count(),
> the total value becomes 105439 and cma value 131072.
> Finally movable value becomes negative value.
> 
> The total value 105439 means 411MB.
> Is the zone->managed_pages value pages amount except the CMA?
> I think zone->managed_pages value is including CMA size but it's value is strange.

Hmm...
zone->managed_pages includes nr of CMA pages.
Is there any mistake about your printk?

> 
> 2nd is a kernel panic at __netdev_alloc_skb().
> I'm not sure it is caused by the CMA.
> I'm checking it again and going to send you another report with detail call-stacks.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
