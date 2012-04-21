Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 954D56B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 20:49:17 -0400 (EDT)
Date: Sat, 21 Apr 2012 02:48:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120421004858.GH2536@cmpxchg.org>
References: <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
 <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
 <20120420131722.GD2536@cmpxchg.org>
 <CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
 <20120420185846.GD15021@tiehlicka.suse.cz>
 <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
 <20120421001914.GG2536@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120421001914.GG2536@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Apr 21, 2012 at 02:19:14AM +0200, Johannes Weiner wrote:
> It's like you're trying to redefine multiplication because you
> accidentally used * instead of + in your equation.

You could for example do this:

-> A (hard limit = 16G)
   -> A1 (hard limit = 10G)
   -> A2 (hard limit =  6G)

and say the same: you want to account A, A1, and A2 under the same
umbrella, so you want the same hierarchy.  And you want to limit the
memory in A (from finished jobs and tasks running directly in A), but
this limit should NOT apply to A1 and A2 when they have not reached
THEIR respective limits.

You can apply all your current arguments to this same case.  And yet,
you say hierarchical hard limits make sense while hierarchical soft
limits don't.  I hope this example makes it clear why this is not true
at all.

We have cases where we want the hierarchical limits.  Both hard limits
and soft limits.  You can easily fix your setup without taking away
this power from everyone else or introducing inconsistency.  Your
whole problem stems from a simple misconfiguration.

The solution to both cases is this: don't stick memory in these meta
groups and complain that their hierarchical limits apply to their
children.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
