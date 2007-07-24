Message-ID: <46A57068.3070701@yahoo.com.au>
Date: Tue, 24 Jul 2007 13:22:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org> <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
In-Reply-To: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jesper Juhl wrote:
> On 10/07/07, Con Kolivas <kernel@kolivas.org> wrote:
> 
>> On Tuesday 10 July 2007 18:31, Andrew Morton wrote:
>> > When replying, please rewrite the subject suitably and try to Cc: the
>> > appropriate developer(s).
>>
>> ~swap prefetch
>>
>> Nick's only remaining issue which I could remotely identify was to 
>> make it
>> cpuset aware:
>> http://marc.info/?l=linux-mm&m=117875557014098&w=2
>> as discussed with Paul Jackson it was cpuset aware:
>> http://marc.info/?l=linux-mm&m=117895463120843&w=2
>>
>> I fixed all bugs I could find and improved it as much as I could last 
>> kernel
>> cycle.
>>
>> Put me and the users out of our misery and merge it now or delete it 
>> forever
>> please. And if the meaningless handwaving that I 100% expect as a 
>> response
>> begins again, then that's fine. I'll take that as a no and you can 
>> dump it.
>>
> For what it's worth; put me down as supporting the merger of swap
> prefetch. I've found it useful in the past, Con has maintained it
> nicely and cleaned up everything that people have pointed out - it's
> mature, does no harm - let's just get it merged.  It's too late for
> 2.6.23-rc1 now, but let's try and get this in by -rc2 - it's long
> overdue...


Not talking about swap prefetch itself, but everytime I have asked
anyone to instrument or produce some workload where swap prefetch
helps, they never do.

Fair enough if swap prefetch helps them, but I also want to look at
why that is the case and try to improve page reclaim in some of
these situations (for example standard overnight cron jobs shouldn't
need swap prefetch on a 1 or 2GB system, I would hope).

Anyway, back to swap prefetch, I don't know why I've been singled out
as the bad guy here. I'm one of the only people who has had a look at
the damn thing and tried to point out areas where it could be improved
to the point of being included, and outlining things that are needed
for it to be merged (ie. numbers). If anyone thinks that makes me the
bad guy then they have an utterly inverted understanding of what peer
review is for.

Finally, everyone who has ever hacked on these heuristicy parts of the
VM has heaps of patches that help some workload or some silly test
case or (real or percieved) shortfall but have not been merged. It
really isn't anything personal.

If something really works, then it should be possible to get real
numbers in real situations where it helps (OK, swap prefetching won't
be as easy as a straight line performance improvement, but still much
easier than trying to measure something like scheduler interactivity).

Numbers are the best way to add weight to the pro-merge argument, so
for all the people who a whining about merging this and don't want
to actually work on the code -- post some numbers for where it helps
you!!

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
