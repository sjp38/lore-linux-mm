From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Wed, 31 May 2006 11:17:11 +1000 (EST)
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
In-Reply-To: <447C055A.9070906@sgi.com>
Message-ID: <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
 <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
 <447C055A.9070906@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jes

I concede that I am acutely aware that 3.5% is just too high,  but we know 
which abstractions are causing the problems.

We will hope to nail down some of these problems in the next few weeks
and then feed again.

What level of degradation in peformance in acceptable (if any)?


Cheers

Paul Davies

On Tue, 30 May 2006, Jes Sorensen wrote:

> Paul Cameron Davies wrote:
>> Hi Jes
>>
>> It is currently causing a degradation, but we are in the process
>> of performance tuning.
>>
>> There is a small cost associated with the PTI at the moment.
>
> Hi Paul,
>
> Bugger! I was hoping it was the other way round :( 3.5% falls into the
> bucket of pretty expensive in my book, so I'll cross my fingers that
> you nail the source of it.
>
> Cheers,
> Jes
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
