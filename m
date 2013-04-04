Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D9DC76B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:35:37 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id jc3so1368374bkc.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 02:35:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <515C07E9.8080307@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-22-git-send-email-glommer@parallels.com>
	<CAFj3OHXp5K6TSCJq4gmi7Y_RpkmbLzDU3GP8vRMmChexULZjyQ@mail.gmail.com>
	<515C07E9.8080307@parallels.com>
Date: Thu, 4 Apr 2013 17:35:35 +0800
Message-ID: <CAFj3OHWEirUH-xWX4O1NVDXCc6EYtceYy9suUgphEQ3C-35oxQ@mail.gmail.com>
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 3, 2013 at 6:43 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 04/03/2013 02:11 PM, Sha Zhengju wrote:
>>> > +unsigned long
>>> > +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>>> > +{
>>> > +       int nid = zone_to_nid(zone);
>>> > +       int zid = zone_idx(zone);
>>> > +       unsigned long val;
>>> > +
>>> > +       val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
>>> > +       if (do_swap_account)
>> IMHO May get_nr_swap_pages() be more appropriate here?
>>
>
> This is a per-memcg number, how would get_nr_swap_pages() help us here?
>

I meant to add get_nr_swap_pages() as the if-judgement, that is:
   if (do_swap_account && get_nr_swap_pages())
       ....
since anon pages becomes unreclaimable if swap space is used up.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
