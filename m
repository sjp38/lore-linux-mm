Message-ID: <46A6E80B.6030704@yahoo.com.au>
Date: Wed, 25 Jul 2007 16:04:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>  <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>  <46A58B49.3050508@yahoo.com.au>  <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>  <46A6CC56.6040307@yahoo.com.au>  <46A6D7D2.4050708@gmail.com> <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au> <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

david@lang.hm wrote:
> On Wed, 25 Jul 2007, Nick Piggin wrote:

>> OK, this is where I start to worry. Swap prefetch AFAIKS doesn't fix
>> the updatedb problem very well, because if updatedb has caused swapout
>> then it has filled memory, and swap prefetch doesn't run unless there
>> is free memory (not to mention that updatedb would have paged out other
>> files as well).
>>
>> And drop behind doesn't fix your usual problem where you are downloading
>> from a server, because that is use-once write(2) data which is the
>> problem. And this readahead-based drop behind also doesn't help if data
>> you were reading happened to be a sequence of small files, or otherwise
>> not in good readahead order.
>>
>> Not to say that neither fix some problems, but for such conceptually
>> big changes, it should take a little more effort than a constructed test
>> case and no consideration of the alternatives to get it merged.
> 
> 
> well, there appears to be a fairly large group of people who have 
> subjective opinions that it helps them. but those were dismissed becouse 
> they aren't measurements.

Not at all. But there is also seems to be some people also experiencing
problems with basic page reclaim on some of the workloads where these
things help. I am not dismissing anybody's claims about anything; I want
to try to solve some of these problems.

Interestingly, some of the people ranting the most about how the VM sucks
are the ones helping least in solving these basic problems.


> so now the measurements of the constructed test case aren't acceptable.
> 
> what sort of test case would be acceptable?

Well I never said real world tests aren't acceptable, they are. There is
a difference between an "it feels better for me", and some actual real
measurement and analysis of said workload.

And constructed test cases of course are useful as well, I didn't say
they weren't. I don't know what you mean by "acceptable", but you should
read my last paragraph again.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
