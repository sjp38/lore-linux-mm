Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E04206B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 12:30:21 -0400 (EDT)
Received: by lbon3 with SMTP id n3so1162755lbo.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 09:30:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <501BF98B.9030103@redhat.com>
References: <1343942664-13365-1-git-send-email-yinghan@google.com>
	<20120803140224.GC8434@dhcp22.suse.cz>
	<501BF98B.9030103@redhat.com>
Date: Fri, 3 Aug 2012 09:30:19 -0700
Message-ID: <CALWz4izRJqER=4feu0NJn4JeTX6r-utbNVbxHfTYG26XYVWOGg@mail.gmail.com>
Subject: Re: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Aug 3, 2012 at 9:17 AM, Rik van Riel <riel@redhat.com> wrote:
> On 08/03/2012 10:02 AM, Michal Hocko wrote:
>>
>> On Thu 02-08-12 14:24:24, Ying Han wrote:
>
>                 shrink_lruvec(lruvec, sc);
>>>
>>>
>>> +                       if (!mem_cgroup_is_root(memcg))
>>> +                               over_softlimit = true;
>>> +               }
>>> +
>>
>>
>> I think this is still not sufficient because you do not want to hammer
>> root in the ignore_softlimit case.
>
>
> Michal, please see my mail from a few days ago, describing how I
> plan to balance pressure between the various LRU lists.
>
> I hope to throw a prototype patch over the wall soon...

I assume this patch is still needed for your later ones, where your
patch will help to balance the
pressure better after start reclaiming.

--Ying

>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
