Message-ID: <46AC9F2C.8090601@gmail.com>
Date: Sun, 29 Jul 2007 16:07:40 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	<20070727030040.0ea97ff7.akpm@linux-foundation.org>	<1185531918.8799.17.camel@Homer.simpson.net>	<200707271345.55187.dhazelton@enter.net>	<46AA3680.4010508@gmail.com>	<Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>	<46AAEDEB.7040003@gmail.com>	<Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>	<46AB166A.2000300@gmail.com>	<20070728122139.3c7f4290@the-village.bc.nu>	<46AC4B97.5050708@gmail.com> <20070729141215.08973d54@the-village.bc.nu>
In-Reply-To: <20070729141215.08973d54@the-village.bc.nu>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/29/2007 03:12 PM, Alan Cox wrote:

>> What are the tradeoffs here? What wants small chunks? Also, as far as
>> I'm aware Linux does not do things like up the granularity when it
>> notices it's swapping in heavily? That sounds sort of promising...
> 
> Small chunks means you get better efficiency of memory use - large chunks
> mean you may well page in a lot more than you needed to each time (and 
> cause more paging in turn). Your disk would prefer you fed it big linear
> I/O's - 512KB would probably be my first guess at tuning a large box 
> under load for paging chunk size.

That probably kills my momentary hope that I was looking at yet another good 
use of large soft-pages seeing as how 512K would be going overboard a bit 
right? :-/

> More radically if anyone wants to do real researchy type work - how about
> log structured swap with a cleaner  ?

Right over my head. Why does log-structure help anything?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
