Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 551346B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 20:19:42 -0400 (EDT)
Date: Sat, 21 Apr 2012 02:19:14 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120421001914.GG2536@cmpxchg.org>
References: <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
 <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
 <20120420131722.GD2536@cmpxchg.org>
 <CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
 <20120420185846.GD15021@tiehlicka.suse.cz>
 <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 03:50:28PM -0700, Ying Han wrote:
> On Fri, Apr 20, 2012 at 11:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 20-04-12 10:44:14, Ying Han wrote:
> >> On Fri, Apr 20, 2012 at 6:17 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> > Let me repeat the pros here: no breaking of existing semantics.  No
> >> > introduction of unprecedented semantics into the cgroup mess.  No
> >> > changing of kernel code necessary (except what we want to tune
> >> > anyway).  No computational overhead for you or anyone else.
> >>
> >> >
> >> > If your only counter argument to this is that you can't be bothered to
> >> > slightly adjust your setup, I'm no longer interested in this
> >> > discussion.
> >>
> >> Before going further, I wanna make sure there is no mis-communication
> >> here. As I replied to Michal, I feel that we are mixing up global
> >> reclaim and target reclaim policy here.
> >
> > I was referring to the global reclaim and my understanding is that
> > Johannes did the same when talking about soft reclaim (even though it
> > makes some sense to apply the same rules to the hard limit reclaim as
> > well - but later to that one...)
> >
> > The primary question is whether soft reclaim should be hierarchical or
> > not. That is what I've tried to express in other email earlier in this
> > thread where I've tried (very briefly) to compare those approaches.
> > It currently _is_ hierarchical and your patch changes that so we have to
> > be sure that this change in semantic is reasonable.
> 
> Yes, after reading the other thread and I suddenly realized what you
> guys are talking about.
> 
> The only workload
> > that you seem to consider is when you have a full control over the
> > machine while Johannes is considered about containers which might misuse
> > your approach to push out working sets of concurrency...
> > My concern with hierarchical approach is that it doesn't play well with
> > 0 default (which is needed if we want to make soft limit a guarantee,
> > right?). I do agree with Johannes about the potential misuse though.  So
> > it seems that both approaches have serious issues with configurability.
> > Does this summary clarify the issue a bit? Or I am confused as well ;)
> 
> Thank you for the good summary and now we are on the same page :)
> 
> Regarding the misuse case, here I am gonna layout the ground rule for
> setting up soft_limit:
> 
> "
> Never over-commit the system by softlimit.
> "

Which proves that we are not on the same page at all :-(

It's not about dealing with rare, non-sensical setups, it's about
suddenly trusting children to do the right thing.

And it's about suddenly REQUIRING all children to cooperate even for
the reasonable configuration case, instead of just having soft limits
apply hierarchically.

Meanwhile, you STILL haven't provided an argument why you couldn't
just fix your cgroup tree organization to make sense for the semantics
you require instead of pushing for such a bogus change.

It's like you're trying to redefine multiplication because you
accidentally used * instead of + in your equation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
