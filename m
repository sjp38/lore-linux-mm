Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E23E06B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 15:41:23 -0500 (EST)
Received: by qyk5 with SMTP id 5so105048qyk.14
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 12:41:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210162052.GB2371@cmpxchg.org>
References: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com>
	 <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090210215811.7010.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090210162052.GB2371@cmpxchg.org>
Date: Wed, 11 Feb 2009 05:41:21 +0900
Message-ID: <2f11576a0902101241j5a006e09w46ecdbdb9c77e081@mail.gmail.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: MinChan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>  {
>>       struct zone *zone;
>> -     unsigned long nr_to_scan, ret = 0;
>> +     unsigned long nr_to_scan;
>>       enum lru_list l;
>
> Basing it on swsusp-clean-up-shrink_all_zones.patch probably makes it
> easier for Andrew to pick it up.

ok, thanks.

>>                       reclaim_state.reclaimed_slab = 0;
>> -                     shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
>> -                     ret += reclaim_state.reclaimed_slab;
>> -             } while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
>> +                     shrink_slab(nr_pages, sc.gfp_mask,
>> +                                 global_lru_pages());
>> +                     sc.nr_reclaimed += reclaim_state.reclaimed_slab;
>> +             } while (sc.nr_reclaimed < nr_pages &&
>> +                      reclaim_state.reclaimed_slab > 0);
>
> :(
>
> Is this really an improvement?  `ret' is better to read than
> `sc.nr_reclaimed'.

I know it's debetable thing.
but I still think code consistency is important than variable name preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
