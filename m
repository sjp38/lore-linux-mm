Date: Fri, 27 Jul 2007 12:43:14 -0700 (PDT)
From: david@lang.hm
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
In-Reply-To: <46AA3680.4010508@gmail.com>
Message-ID: <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
 <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007, Rene Herman wrote:

> On 07/27/2007 07:45 PM, Daniel Hazelton wrote:
>
>>  Updatedb or another process that uses the FS heavily runs on a users
>>  256MB P3-800 (when it is idle) and the VFS caches grow, causing memory
>>  pressure that causes other applications to be swapped to disk. In the
>>  morning the user has to wait for the system to swap those applications
>>  back in.
>>
>>  Questions about it:
>>  Q) Does swap-prefetch help with this? A) [From all reports I've seen (*)]
>>  Yes, it does. 
>
> No it does not. If updatedb filled memory to the point of causing swapping 
> (which noone is reproducing anyway) it HAS FILLED MEMORY and swap-prefetch 
> hasn't any memory to prefetch into -- updatedb itself doesn't use any 
> significant memory.

however there are other programs which are known to take up significant 
amounts of memory and will cause the issue being described (openoffice for 
example)

please don't get hung up on the text 'updatedb' and accept that there are 
programs that do run intermittently and do use a significant amount of ram 
and then free it.

David Lang

> Here's swap-prefetch's author saying the same:
>
> http://lkml.org/lkml/2007/2/9/112
>
> |  It can't help the updatedb scenario. Updatedb leaves the ram full and
> |  swap prefetch wants to cost as little as possible so it will never
> |  move anything out of ram in preference for the pages it wants to swap
> |  back in.
>
> Now please finally either understand this, or tell us how we're wrong.
>
> Rene.
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
