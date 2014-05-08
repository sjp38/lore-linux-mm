Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 11B496B0125
	for <linux-mm@kvack.org>; Thu,  8 May 2014 18:34:37 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so3408899pab.14
        for <linux-mm@kvack.org>; Thu, 08 May 2014 15:34:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yd10si1168358pab.2.2014.05.08.15.34.35
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 15:34:36 -0700 (PDT)
Date: Thu, 8 May 2014 15:34:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list
 placement of CMA and RESERVE pages
Message-Id: <20140508153433.7fcbe624549259b68659fe10@linux-foundation.org>
In-Reply-To: <20140508061937.GE5282@bbox>
References: <533D8015.1000106@suse.cz>
	<1396539618-31362-1-git-send-email-vbabka@suse.cz>
	<1396539618-31362-2-git-send-email-vbabka@suse.cz>
	<53616F39.2070001@oracle.com>
	<53638ADA.5040200@suse.cz>
	<5367A1E5.2020903@oracle.com>
	<5367B356.1030403@suse.cz>
	<20140507013333.GB26212@bbox>
	<536A4A3B.1090403@suse.cz>
	<20140508055421.GC9161@js1304-P5Q-DELUXE>
	<20140508061937.GE5282@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On Thu, 8 May 2014 15:19:37 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > I also think that VM_DEBUG overhead isn't problem because of same
> > reason from Vlastimil.
> 
> Guys, please read this.
> 
> https://lkml.org/lkml/2013/7/17/591
> 
> If you guys really want it, we could separate it with
> CONFIG_DEBUG_CMA or CONFIG_DEBUG_RESERVE like stuff.
> Otherwise, just remain in mmotm.

Wise words, those.

Yes, these checks are in a pretty hot path.  I'm inclined to make the
patch -mm (and -next) only.

Unless there's a really good reason, such as "nobody who uses CMA is
likely to be testing -next", which sounds likely :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
