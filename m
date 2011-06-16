Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 285326B0082
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 03:14:41 -0400 (EDT)
Subject: Re: Oops in VMA code
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <BANLkTimB5gEZ2S=b9EiiWR-_u+o+wEPyjw@mail.gmail.com>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
	 <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
	 <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
	 <BANLkTikLLfJ6yGNVcZ+o1RFmRoqRVrRSYQ@mail.gmail.com>
	 <96D27CEC-8492-49F2-913F-F587DEC5E95E@suse.de>
	 <BANLkTimB5gEZ2S=b9EiiWR-_u+o+wEPyjw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 17:14:36 +1000
Message-ID: <1308208476.2516.67.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Wed, 2011-06-15 at 23:54 -0700, Linus Torvalds wrote:
> On Wed, Jun 15, 2011 at 11:20 PM, Alexander Graf <agraf@suse.de> wrote:
> >
> > On 16.06.2011, at 07:59, Linus Torvalds wrote:
> >>
> >> r26 has the value 0xc00090026236bbb0, and that "90" byte in the middle
> >> there looks bogus. It's not a valid pointer any more, but if that "9"
> >> had been a zero, it would have been.
> >
> > Please see my reply to Ben here.
> 
> Your reply to Ben seems to say that 0xc00000026236bbb0 wouldn't have
> been a valid address, because you don't have that much memory.
> 
> But that's clearly not true. All the other registers have valid
> pointers in them, and the stack pointer (r1) is c000000262987cd0, for
> example. And that stack is clearly valid - if the kernel stack pointer
> was corrupted, you'd never have gotten as far as reporting the oops.
> 
> So you may have only 8GB of RAM in that machine, but if so, there's
> some empty unmapped physical space. Because clearly your RAM is _not_
> limited to being mapped to below 0xc000000200000000.

Right. It's a G5, RAM goes from 0...2G and 2G onward, with an IO hole
from 2 to 4G.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
