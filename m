From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Date: Sat, 28 Jul 2007 17:48:50 -0400
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <200707281156.53439.dhazelton@enter.net> <Pine.LNX.4.64.0707281403510.32476@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707281403510.32476@asgard.lang.hm>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707281748.50381.dhazelton@enter.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Rene Herman <rene.herman@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 28 July 2007 17:06:50 david@lang.hm wrote:
> On Sat, 28 Jul 2007, Daniel Hazelton wrote:
> > On Saturday 28 July 2007 04:55:58 david@lang.hm wrote:
> >> On Sat, 28 Jul 2007, Rene Herman wrote:
> >>> On 07/27/2007 09:43 PM, david@lang.hm wrote:
> >>>>  On Fri, 27 Jul 2007, Rene Herman wrote:
> >>>>>  On 07/27/2007 07:45 PM, Daniel Hazelton wrote:
> >>
> >> nobody is arguing that swap prefetch helps in the second cast.
> >
> > Actually, I made a mistake when tracking the thread and reading the code
> > for the patch and started to argue just that. But I have to admit I made
> > a mistake - the patches author has stated (as Rene was kind enough to
> > point out) that swap prefetch can't help when memory is filled.
>
> I stand corrected, thaks for speaking up and correcting your position.

If you had made the statement before I decided to speak up you would have been 
correct :)

Anyway, I try to always admit when I've made a mistake - its part of my 
philosophy. (There have been times when I haven't done it, but I'm trying to 
make that stop entirely)

> >> what people are arguing is that there are situations where it helps for
> >> the first case. on some machines and version of updatedb the nighly run
> >> of updatedb can cause both sets of problems. but the nightly updatedb
> >> run is not the only thing that can cause problems
> >
> > Solving the cache filling memory case is difficult. There have been a
> > number of discussions about it. The simplest solution, IMHO, would be to
> > place a (configurable) hard limit on the maximum size any of the kernels
> > caches can grow to. (The only solution that was discussed, however, is a
> > complex beast)
>
> limiting the size of the cache is also the wrong thing to do in many
> situations. it's only right if the cache pushes out other data you care
> about, if you are trying to do one thing as fast as you can you really do
> want the system to use all the memory it can for the cache.

After thinking about this you are partially correct. There are those sorts of 
situations where you want the system to use all the memory it can for caches. 
OTOH, if those situations could be described in some sort of simple 
heuristic, then a soft-limit that uses those heuristics to determine when to 
let the cache expand could exploit the benefits of having both a limited and 
unlimited cache. (And, potentially, if the heuristic has allowed a cache to 
expand beyond the limit then, when the heuristic no longer shows the oversize 
cache is no longer necessary it could trigger and automatic reclaim of that 
memory.)

(I'm willing to help write and test code to do this exactly. There is no 
guarantee that I'll be able to help with more than testing - I don't 
understand the parts of the code involved all that well)

DRH

-- 
Dialup is like pissing through a pipette. Slow and excruciatingly painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
