Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C72DD6B0062
	for <linux-mm@kvack.org>; Mon, 12 May 2014 21:38:44 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so336363pbc.4
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:38:44 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ul9si11635773pac.118.2014.05.12.18.38.42
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 18:38:44 -0700 (PDT)
Date: Tue, 13 May 2014 10:40:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list
 placement of CMA and RESERVE pages
Message-ID: <20140513014049.GE23803@js1304-P5Q-DELUXE>
References: <1396539618-31362-2-git-send-email-vbabka@suse.cz>
 <53616F39.2070001@oracle.com>
 <53638ADA.5040200@suse.cz>
 <5367A1E5.2020903@oracle.com>
 <5367B356.1030403@suse.cz>
 <20140507013333.GB26212@bbox>
 <536A4A3B.1090403@suse.cz>
 <20140508055421.GC9161@js1304-P5Q-DELUXE>
 <20140508061937.GE5282@bbox>
 <20140508153433.7fcbe624549259b68659fe10@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140508153433.7fcbe624549259b68659fe10@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On Thu, May 08, 2014 at 03:34:33PM -0700, Andrew Morton wrote:
> On Thu, 8 May 2014 15:19:37 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > I also think that VM_DEBUG overhead isn't problem because of same
> > > reason from Vlastimil.
> > 
> > Guys, please read this.
> > 
> > https://lkml.org/lkml/2013/7/17/591
> > 
> > If you guys really want it, we could separate it with
> > CONFIG_DEBUG_CMA or CONFIG_DEBUG_RESERVE like stuff.
> > Otherwise, just remain in mmotm.
> 
> Wise words, those.
> 
> Yes, these checks are in a pretty hot path.  I'm inclined to make the
> patch -mm (and -next) only.
> 
> Unless there's a really good reason, such as "nobody who uses CMA is
> likely to be testing -next", which sounds likely :(

Hello,

Now, I think that dropping this patch is better if we can only use it
on MIGRATE_CMA case. Later, if I feel that this case should be checked,
I will resend the patch with appropriate argument.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
