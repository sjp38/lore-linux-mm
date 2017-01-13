Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57A736B0261
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:27:11 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so757757wmt.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:27:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m67si2170657wme.26.2017.01.13.05.27.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 05:27:10 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, page_alloc: Split buffered_rmqueue
References: <20170112104300.24345-1-mgorman@techsingularity.net>
 <20170112104300.24345-2-mgorman@techsingularity.net>
 <63cb1f14-ab02-31a2-f386-16c1b52f61fe@suse.cz>
 <20170112172131.wd64o44kqg6e4nou@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c24ac47f-2abb-1e46-d828-da4e26a6c9dc@suse.cz>
Date: Fri, 13 Jan 2017 14:27:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170112172131.wd64o44kqg6e4nou@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/12/2017 06:21 PM, Mel Gorman wrote:
>
>> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>> > Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
>> > ---
>> >  mm/page_alloc.c | 126 ++++++++++++++++++++++++++++++++++----------------------
>> >  1 file changed, 77 insertions(+), 49 deletions(-)
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 2c6d5f64feca..d8798583eaf8 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -2610,68 +2610,96 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
>> >  #endif
>> >  }
>> >
>> > +/* Remote page from the per-cpu list, caller must protect the list */
>>
>>     ^ Remove
>>
>> > +static struct page *__rmqueue_pcplist(struct zone *zone, unsigned int order,
>> > +			gfp_t gfp_flags, int migratetype, bool cold,
>>
>> order and gfp_flags seem unused here
>>
>
> This on top?

Yeah, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
