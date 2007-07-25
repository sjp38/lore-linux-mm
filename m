Message-ID: <46A72CEB.7050101@gmail.com>
Date: Wed, 25 Jul 2007 12:58:51 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>  <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>  <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm> <46A7031D.5080300@gmail.com> <Pine.LNX.4.64.0707250104180.2229@asgard.lang.hm> <46A709DC.4080501@gmail.com> <Pine.LNX.4.64.0707250130200.18679@asgard.lang.hm> <Pine.LNX.4.64.0707250132520.18679@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707250132520.18679@asgard.lang.hm>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Ray Lee <ray-lk@madrabbit.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/25/2007 10:33 AM, david@lang.hm wrote:

>> I haven't used swap prefetch either, the call was put out for what 
>> could be used to test the performance, and I was suggesting a test.
>>
>> if nobody else follows up on this I'll try to get some time to test it 
>> myself in a day or two.
> 
> this assumes that this isn't ruled an invalid test in the meantime.

Let's save a little time and guess. While two instances of the hog are 
running no physical memory is free (as together they take up 1.5x physical) 
meaning that swap-prefetch wouldn't get a change to do anything and wouldn't 
make a difference. As such, the two instances test as you suggested would in 
fact not be testing anything it seems.

However, if you quit one, and idle long enough to continue with the other 
one until swap-prefetch prefetched all its memory back in, it should be a 
difference on the order of minutes, even total if swap prefetch fetched it 
back in without seeking al over swap-space, and "total" isn't applicable if 
the idle time really is free.

A program randomly touching single pages all over memory is a contrived 
worst case scenario and not a real-world issue. It is a boundary condition 
though, and it's simply quite impossible to think of any example where 
swap-prefetch would _not_ give you a snappier feeling machine after you've 
been idling.

So really the only question would seem to be -- does it hurt any if you have 
_not_ been?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
