Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 674486B00EC
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 06:44:03 -0400 (EDT)
Message-ID: <515C07E9.8080307@parallels.com>
Date: Wed, 3 Apr 2013 14:43:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-22-git-send-email-glommer@parallels.com> <CAFj3OHXp5K6TSCJq4gmi7Y_RpkmbLzDU3GP8vRMmChexULZjyQ@mail.gmail.com>
In-Reply-To: <CAFj3OHXp5K6TSCJq4gmi7Y_RpkmbLzDU3GP8vRMmChexULZjyQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2013 02:11 PM, Sha Zhengju wrote:
>> > +unsigned long
>> > +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>> > +{
>> > +       int nid = zone_to_nid(zone);
>> > +       int zid = zone_idx(zone);
>> > +       unsigned long val;
>> > +
>> > +       val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
>> > +       if (do_swap_account)
> IMHO May get_nr_swap_pages() be more appropriate here?
> 

This is a per-memcg number, how would get_nr_swap_pages() help us here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
