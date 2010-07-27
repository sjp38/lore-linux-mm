Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BE593600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 18:33:09 -0400 (EDT)
Received: by gxk4 with SMTP id 4so1915040gxk.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 15:33:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1007270929290.28648@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
	<pfn.valid.v4.reply.1@mdm.bga.com>
	<AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
	<pfn.valid.v4.reply.2@mdm.bga.com>
	<20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
	<alpine.DEB.2.00.1007270929290.28648@router.home>
Date: Wed, 28 Jul 2010 07:33:07 +0900
Message-ID: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 11:34 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Tue, 27 Jul 2010, Minchan Kim wrote:
>
>> But in fact I have a concern to use PG_reserved since it can be used
>> afterward pfn_valid normally to check hole in non-hole system. So I
>> think it's redundant.

Ignore me. I got confused.

>
> PG_reserved is already used to mark pages not handled by the page
> allocator (see mmap_init_zone).


I will resend below approach.

static inline int memmap_valid(unsigned long pfn)
{
       struct page *page = pfn_to_page(pfn);
       struct page *__pg = virt_to_page(page);
       return page_private(__pg) == MAGIC_MEMMAP && PageReserved(__pg);
}

Thanks, all.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
