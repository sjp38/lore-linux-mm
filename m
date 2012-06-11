Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 671046B0112
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:44:23 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5G0041Y8H2XK30@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 11 Jun 2012 19:44:14 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5G00JJF8HNE390@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 11 Jun 2012 19:44:14 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v10] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
Date: Mon, 11 Jun 2012 12:43:14 +0200
References: <201206081046.32382.b.zolnierkie@samsung.com>
 <4FD54959.6060500@kernel.org>
In-reply-to: <4FD54959.6060500@kernel.org>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201206111243.14379.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Monday 11 June 2012 03:26:49 Minchan Kim wrote:
> Hi Bartlomiej,
> 
> On 06/08/2012 05:46 PM, Bartlomiej Zolnierkiewicz wrote:
> 
> > 
> > Hi,
> > 
> > This version is much simpler as it just uses __count_immobile_pages()
> > instead of using its own open coded version and it integrates changes
> 
> 
> That's a good idea. I don't have noticed that function is there.
> When I look at the function, it has a problem, too.
> Please, look at this.
> 
> https://lkml.org/lkml/2012/6/10/180
> 
> If reviewer is okay that patch, I would like to resend your patch based on that. 

Ok, I would later merge all changes into v11 and rebase on top of your patch.

> > from Minchan Kim (without page_count change as it doesn't seem correct
> 
> 
> Why do you think so?
> If it isn't correct, how can you prevent racing with THP page freeing?

After seeing the explanation for the previous fix it is all clear now.

> > and __count_immobile_pages() does the check in the standard way; if it
> > still is a problem I think that removing 1st phase check altogether
> > would be better instead of adding more locking complexity).
> > 
> > The patch also adds compact_rescued_unmovable_blocks vmevent to vmstats
> > to make it possible to easily check if the code is working in practice.
> 
> 
> I think that part should be another patch.
> 
> 1. Adding new vmstat would be arguable so it might interrupt this patch merging.

Why would it be arguable?  It seems non-intrusive and obvious to me.

> 2. New vmstat adding is just for this patch is effective or not in real practice
>    so if we prove it in future, let's revert the vmstat. Separating it would make it
>    easily.

I would like to add this vmstat permanently, not only for the testing period..

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
