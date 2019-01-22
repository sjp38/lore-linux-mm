Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE8F78E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:56:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so9612665eda.10
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:56:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21-v6sor11563877ejx.10.2019.01.22.07.56.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 07:56:30 -0800 (PST)
Date: Tue, 22 Jan 2019 15:56:28 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190122155628.eu4sxocyjb5lrcla@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
 <20190122151628.GI4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122151628.GI4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, Jan 22, 2019 at 04:16:28PM +0100, Michal Hocko wrote:
>On Tue 22-01-19 15:07:17, Wei Yang wrote:
>> On Tue, Jan 22, 2019 at 09:55:24AM +0100, Michal Hocko wrote:
>> >On Sat 19-01-19 07:49:05, Wei Yang wrote:
>> >> Two cleanups in this patch:
>> >> 
>> >>   * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
>> >>     and right shift pageblock_order could be replaced with
>> >>     DIV_ROUND_UP()
>> >
>> >Why is this change worth it?
>> >
>> 
>> To make it directly show usemapsize is number of times of
>> pageblock_nr_pages.
>
>Does this lead to a better code generation? Does it make the code easier
>to read/maintain?
>

I think the answer is yes.

  * it reduce the code from 6 lines to 3 lines, 50% off
  * by reducing calculation back and forth, it would be easier for
    audience to catch what it tries to do

>> >>   * use BITS_TO_LONGS() to get number of bytes for bitmap
>> >> 
>> >> This patch also fix one typo in comment.
>> >> 
>> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> >> ---
>> >>  mm/page_alloc.c | 9 +++------
>> >>  1 file changed, 3 insertions(+), 6 deletions(-)
>> >> 
>> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> >> index d295c9bc01a8..d7073cedd087 100644
>> >> --- a/mm/page_alloc.c
>> >> +++ b/mm/page_alloc.c
>> >> @@ -6352,7 +6352,7 @@ static void __init calculate_node_totalpages(struct pglist_data *pgdat,
>> >>  /*
>> >>   * Calculate the size of the zone->blockflags rounded to an unsigned long
>> >>   * Start by making sure zonesize is a multiple of pageblock_order by rounding
>> >> - * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
>> >> + * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally
>> >
>> >why do you change this?
>> >
>> 
>> Is the original comment not correct? Or I misunderstand the English
>> word?
>
>yes AFAICS

ok, maybe the first time to know this. So I guess they are the same
meaning? I searched in google, but no specific explanation on this.

>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
