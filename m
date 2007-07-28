Date: Sat, 28 Jul 2007 14:03:01 -0700 (PDT)
From: david@lang.hm
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
In-Reply-To: <20070728122139.3c7f4290@the-village.bc.nu>
Message-ID: <Pine.LNX.4.64.0707281400580.32476@asgard.lang.hm>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
 <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
 <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm> <46AAEDEB.7040003@gmail.com>
 <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm> <46AB166A.2000300@gmail.com>
 <20070728122139.3c7f4290@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rene Herman <rene.herman@gmail.com>, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007, Alan Cox wrote:

>> It is. Prefetched pages can be dropped on the floor without additional I/O.
>
> Which is essentially free for most cases. In addition your disk access
> may well have been in idle time (and should be for this sort of stuff)
> and if it was in the same chunk as something nearby was effectively free
> anyway.

as I understand it the swap-prefetch only kicks in if the device is idle

> Actual physical disk ops are precious resource and anything that mostly
> reduces the number will be a win - not to stay swap prefetch is the right
> answer but accidentally or otherwise there are good reasons it may happen
> to help.
>
> Bigger more linear chunks of writeout/readin is much more important I
> suspect than swap prefetching.

I'm sure this is true while you are doing the swapout or swapin and the 
system is waiting for it. but with prefetch you may be able to avoid doing 
the swapin at a time when the system is waiting for it by doing it at a 
time when the system is otherwise idle.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
