Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 516C96B0101
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 13:28:27 -0400 (EDT)
Received: by lagz14 with SMTP id z14so5373221lag.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:28:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120412000413.GB1787@cmpxchg.org>
References: <1334181594-26671-1-git-send-email-yinghan@google.com>
	<20120412000413.GB1787@cmpxchg.org>
Date: Mon, 16 Apr 2012 10:28:25 -0700
Message-ID: <CALWz4ixkD9TE1s=miMpC_CB3pV4K2=QPPvdZ_dfwghEJMX4Ugg@mail.gmail.com>
Subject: Re: [PATCH V2 1/5] memcg: revert current soft limit reclaim implementation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 5:04 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Apr 11, 2012 at 02:59:54PM -0700, Ying Han wrote:
>> This patch reverts all the existing softlimit reclaim implementations.
>
> This ordering makes it quite hard to revert individual patches after
> merging in case they are faulty, because we end up with a tree state
> that has no soft limit implementation at all, or a newly broken one.
>
> Could you reorder the series such that each patch leaves the tree in a
> sane state?
>
> I.e. also don't introduce an endless loop in the page allocator
> through one patch and fix it later in another one ;) Noone will be
> able to remember these cross-dependencies in a couple of weeks.

Make sense to me. I will try to make the ordering better for the next post :)

--Ying



> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
