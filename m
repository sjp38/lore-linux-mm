Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7C70F6B0027
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:25:11 -0400 (EDT)
Message-ID: <515E8A60.3010203@parallels.com>
Date: Fri, 5 Apr 2013 12:25:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-22-git-send-email-glommer@parallels.com> <CAFj3OHXp5K6TSCJq4gmi7Y_RpkmbLzDU3GP8vRMmChexULZjyQ@mail.gmail.com> <515C07E9.8080307@parallels.com> <CAFj3OHWEirUH-xWX4O1NVDXCc6EYtceYy9suUgphEQ3C-35oxQ@mail.gmail.com>
In-Reply-To: <CAFj3OHWEirUH-xWX4O1NVDXCc6EYtceYy9suUgphEQ3C-35oxQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/04/2013 01:35 PM, Sha Zhengju wrote:
> On Wed, Apr 3, 2013 at 6:43 PM, Glauber Costa <glommer@parallels.com> wrote:
>> On 04/03/2013 02:11 PM, Sha Zhengju wrote:
>>>>> +unsigned long
>>>>> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>>>>> +{
>>>>> +       int nid = zone_to_nid(zone);
>>>>> +       int zid = zone_idx(zone);
>>>>> +       unsigned long val;
>>>>> +
>>>>> +       val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
>>>>> +       if (do_swap_account)
>>> IMHO May get_nr_swap_pages() be more appropriate here?
>>>
>>
>> This is a per-memcg number, how would get_nr_swap_pages() help us here?
>>
> 
> I meant to add get_nr_swap_pages() as the if-judgement, that is:
>    if (do_swap_account && get_nr_swap_pages())
>        ....
> since anon pages becomes unreclaimable if swap space is used up.
> 
> 
Well, I believe this is doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
