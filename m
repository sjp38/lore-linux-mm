Date: Thu, 26 Jul 2007 17:12:07 -0700 (PDT)
From: david@lang.hm
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <46A930A0.1030701@garzik.org>
Message-ID: <Pine.LNX.4.64.0707261705160.4183@asgard.lang.hm>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <20070726111326.873f7b0a.akpm@linux-foundation.org> <200707270004.46211.dirk@liji-und-dirk.de>
 <200707270033.41055.dirk@liji-und-dirk.de> <46A92DF4.6000301@garzik.org>
 <Pine.LNX.4.64.0707261627220.4183@asgard.lang.hm> <46A930A0.1030701@garzik.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Dirk Schoebel <dirk@liji-und-dirk.de>, ck@vds.kolivas.org, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Eric St-Laurent <ericstl34@sympatico.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007, Jeff Garzik wrote:

> david@lang.hm wrote:
>>  On Thu, 26 Jul 2007, Jeff Garzik wrote:
>> 
>> >  Dirk Schoebel wrote:
>> > >   as long as the maintainer follows the kernel development things can 
>> > >   be
>> > >   left in, if the maintainer can't follow anymore they are taken out 
>> > >  quite
>> > >  fast again. (This statement mostly counts for parts of the kernel 
>> > >  where a
>> > >  choice is possible or the coding overhead of making such choice 
>> > >  possible
>> > >   is quite low.)
>> > 
>> > 
>> >  This is just not good engineering.
>> > 
>> >  It is axiomatic that it is easy to add code, but difficult to remove 
>> >  code. It takes -years- to remove code that no one uses.  Long after the 
>> >  maintainer disappears, the users (and bug reports!) remain.
>>
>>  I'll point out that the code that's so hard to remove is the code that
>>  exposes an API to userspace.
>
> True.
>
>
>>  code that's an internal implementation (like a couple of the things being
>>  discussed) gets removed much faster.
>
> Not true.  It is highly unlikely that code will get removed if it has active 
> users, even if the maintainer has disappeared.

if you propose removing code in such a way that performance suffers then 
yes, it's hard to remove (and it should be).

but if it has no API the code is only visable to the users as a side 
effect of it's use. if the new code works better then it can be replaced.

the scheduler change that we're going through right now is an example, new 
code came along that was better and the old code went away very quickly.

the SLAB/SLOB/SLUB/S**B debate is another example. currently the different 
versions have different performance advantages and disadvantages, as one 
drops behind to the point where one of the others is better at all times, 
it goes away.

> The only things that get removed rapidly are those things mathematically 
> guaranteed to be dead code.
>
> _Behavior changes_, driver removals, feature removals happen more frequently 
> than userspace ABI changes -- true -- but the rate of removal is still very, 
> very slow.

a large part of this is that it's so hard to get a replacement that works 
better (this is very definantly a compliment to the kernel coders :-)



> It is axiomatic that we are automatically burdened with new code for at 
> least 10 years :)  That's what you have to assume, when accepting 
> anything.

for userspace API's 10 years is reasonable, for internal features it's 
not. there is a LOT of internal stuff that was in the kernel 10 (or even 
5) years ago that isn't there now. the key is that the behavior as far as 
users is concerned is better now.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
