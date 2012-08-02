Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6E24D6B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 20:43:54 -0400 (EDT)
Message-ID: <5019CD23.90709@redhat.com>
Date: Wed, 01 Aug 2012 20:43:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343687538-24284-1-git-send-email-yinghan@google.com> <20120731155932.GB16924@tiehlicka.suse.cz> <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com> <20120731200205.GA19524@tiehlicka.suse.cz> <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com> <20120801084553.GD4436@tiehlicka.suse.cz> <CALWz4iwzJp8EwSeP6ap7_adW6sF8YR940sky6vJS3SD8FO6HkA@mail.gmail.com> <50198D38.1000905@redhat.com> <CALWz4iz3Fo90PLNVgzza2Bdt04VS6asxXWUuU==LW8-Hx-fSjA@mail.gmail.com>
In-Reply-To: <CALWz4iz3Fo90PLNVgzza2Bdt04VS6asxXWUuU==LW8-Hx-fSjA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/01/2012 08:09 PM, Ying Han wrote:
> On Wed, Aug 1, 2012 at 1:10 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 08/01/2012 03:04 PM, Ying Han wrote:
>>
>>> That is true. Hmm, then two things i can do:
>>>
>>> 1. for kswapd case, make sure not counting the root cgroup
>>> 2. or check nr_scanned. I like the nr_scanned which is telling us
>>> whether or not the reclaim ever make any attempt ?
>>
>>
>> I am looking at a more advanced case of (3) right
>> now.  Once I have the basics working, I will send
>> you a prototype (that applies on top of your patches)
>> to play with.
>
> Rik,
>
> Thank you for looking into that. Before I dig into the algorithm you
> described here, do you think we need to hold this patchset for that?
> It would be easier to build on top of the things after the ground work
> is sorted out.

I'm fine either way.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
