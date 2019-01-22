Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0988E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:16:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so9337347edb.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:16:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17si3460052edq.40.2019.01.22.07.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:16:29 -0800 (PST)
Date: Tue, 22 Jan 2019 16:16:28 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190122151628.GI4087@dhcp22.suse.cz>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122150717.llf4owk6soejibov@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue 22-01-19 15:07:17, Wei Yang wrote:
> On Tue, Jan 22, 2019 at 09:55:24AM +0100, Michal Hocko wrote:
> >On Sat 19-01-19 07:49:05, Wei Yang wrote:
> >> Two cleanups in this patch:
> >> 
> >>   * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
> >>     and right shift pageblock_order could be replaced with
> >>     DIV_ROUND_UP()
> >
> >Why is this change worth it?
> >
> 
> To make it directly show usemapsize is number of times of
> pageblock_nr_pages.

Does this lead to a better code generation? Does it make the code easier
to read/maintain?

> >>   * use BITS_TO_LONGS() to get number of bytes for bitmap
> >> 
> >> This patch also fix one typo in comment.
> >> 
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >> ---
> >>  mm/page_alloc.c | 9 +++------
> >>  1 file changed, 3 insertions(+), 6 deletions(-)
> >> 
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index d295c9bc01a8..d7073cedd087 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -6352,7 +6352,7 @@ static void __init calculate_node_totalpages(struct pglist_data *pgdat,
> >>  /*
> >>   * Calculate the size of the zone->blockflags rounded to an unsigned long
> >>   * Start by making sure zonesize is a multiple of pageblock_order by rounding
> >> - * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
> >> + * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally
> >
> >why do you change this?
> >
> 
> Is the original comment not correct? Or I misunderstand the English
> word?

yes AFAICS

-- 
Michal Hocko
SUSE Labs
