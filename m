Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA12868
	for <linux-mm@kvack.org>; Fri, 24 Jul 1998 12:11:05 -0400
Date: Fri, 24 Jul 1998 16:25:56 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87af5zlcjq.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.980724161908.21942A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 24 Jul 1998, Zlatko Calusic wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > These solutions are somewhat the same, but your one may take
> > a little less computational power and has a tradeoff in the
> > fact that it is very inflexible.
> 
> Same? Not in your wildest dream. :)
> 
> Limiting means puting "arbitrary" limit. Then page cache would NEVER
> grow above that limit.

There's also a 'soft limit', or borrow percentage. Ultimately
the minimum and maximum percentages should be 0 and 100 %
respectively.

> Triple aging has all good characteristics of aging.
> Why do you think it is inflexible?

Because there's no way to tune the 'priority' of the page aging.
It could be good to do triple aging, but it could be a non-optimal
number on other machines ... and there's no way to get out of it!

> I will post another, completely different set of benchmarks today.
> Under different initial conditions, so as to simulate different
> machines and loads.

Good, I like this. You will probably get somewhat different
results with this...

Oh, and changing the code to:

int i;
for ( i = page_cache_penalty; i--;)
	age_page(page);

and making page_cache_pentalty sysctl tunable will certainly
make your tests easier...

> I'm very satisfied with changes (in .109 I think)
> free_memory_available() went through. Old function was much too much
> unnessecary complicated and not useful at all. And unreadable.

It _was_ useful; it has always been useful to test for the
amount of memory fragmentation.

In fact, Linus himself said (when free_memory_available()
was introduced in 2.1.89) that he would not accept any
function which used the amount of free pages.

After some protests (by me) Linus managed to explain to us
exactly _why_ we should test for fragmentation, I suggest
we all go through the archives again and reread the arguments...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
