Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 12EB26B00EA
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 23:46:32 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1638042lag.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:46:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F8625AD.6000707@redhat.com>
References: <1334181614-26836-1-git-send-email-yinghan@google.com>
	<4F8625AD.6000707@redhat.com>
Date: Wed, 11 Apr 2012 20:46:29 -0700
Message-ID: <CALWz4iyoiXpcqSvSqFpRjxt2dEj+8ub15jLUk8FbHfUm5SYBLg@mail.gmail.com>
Subject: Re: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 5:45 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/11/2012 06:00 PM, Ying Han wrote:
>>
>> 1. If soft_limit are all set to MAX, it wastes first three periority
>> iterations
>> without scanning anything.
>>
>> 2. By default every memcg is eligibal for softlimit reclaim, and we can
>> also
>> set the value to MAX for special memcg which is immune to soft limit
>> reclaim.
>>
>> This idea is based on discussion with Michal and Johannes from LSF.
>
>
> Combined with patch 2/5, would this not result in always
> returning "reclaim from this memcg" for groups without a
> configured softlimit, while groups with a configured
> softlimit only get reclaimed from when they are over
> their limit?

> Is that the desired behaviour when a system has some
> cgroups with a configured softlimit, and some without?

That is expected behavior. Basically after this change, by default all
memcgs are eligible for reclaim under global memory pressure. Only
those memcgs who sets their softlimit will be skipped if usage less
than softlimit.

Does it answer your question? I might misunderstood.

--Ying
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
