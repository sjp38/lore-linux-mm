Date: Wed, 25 Jul 2007 01:33:45 -0700 (PDT)
From: david@lang.hm
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <Pine.LNX.4.64.0707250130200.18679@asgard.lang.hm>
Message-ID: <Pine.LNX.4.64.0707250132520.18679@asgard.lang.hm>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
  <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
 <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm> <46A7031D.5080300@gmail.com>
 <Pine.LNX.4.64.0707250104180.2229@asgard.lang.hm> <46A709DC.4080501@gmail.com>
 <Pine.LNX.4.64.0707250130200.18679@asgard.lang.hm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, david@lang.hm wrote:

> Subject: Re: -mm merge plans for 2.6.23
> 
> On Wed, 25 Jul 2007, Rene Herman wrote:
>
>>  On 07/25/2007 10:07 AM, david@lang.hm wrote:
>> 
>> >   On Wed, 25 Jul 2007, Rene Herman wrote:
>> 
>> > >   Something like this?
>>
>>  [ ... ]
>> 
>> >   when the swap readahead is enabled does it make a significant 
>> >   difference
>> >   in the time to do the random access?
>>
>>  I don't use swap prefetch (nor -ck or -mm). If someone who has the patch
>>  applied waits to hit enter until swap prefetch has prefetched it all back
>>  in again, it certainly will.
>>
>>  Swap prefetch's potential to do larger reads back from swapspace than a
>>  random segfaulting app could well be very significant. Reads are dwarved
>>  by seeks. If this program does what you wanted, please use it to show us.
>
> I haven't used swap prefetch either, the call was put out for what could be 
> used to test the performance, and I was suggesting a test.
>
> if nobody else follows up on this I'll try to get some time to test it myself 
> in a day or two.

this assumes that this isn't ruled an invalid test in the meantime.

in any case thanks for codeing this up so quickly.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
