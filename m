Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 32B0E600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 10:35:56 -0400 (EDT)
Date: Tue, 27 Jul 2010 09:34:59 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1007270929290.28648@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com> <alpine.DEB.2.00.1007261136160.5438@router.home> <pfn.valid.v4.reply.1@mdm.bga.com> <AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com> <pfn.valid.v4.reply.2@mdm.bga.com>
 <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010, Minchan Kim wrote:

> But in fact I have a concern to use PG_reserved since it can be used
> afterward pfn_valid normally to check hole in non-hole system. So I
> think it's redundant.

PG_reserved is already used to mark pages not handled by the page
allocator (see mmap_init_zone).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
