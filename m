Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C19CE5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 16:39:59 -0400 (EDT)
Message-ID: <4A21999E.5050606@redhat.com>
Date: Sat, 30 May 2009 16:39:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page	allocator
References: <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu>
In-Reply-To: <20090530190828.GA31199@elte.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "Larry H." <research@subreption.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Larry H. <research@subreption.com> wrote:
>> On 20:21 Sat 30 May     , Ingo Molnar wrote:

>>> Freeing keys is an utter slow-path (if not then the clearing is 
>>> the least of our performance worries), so any clearing cost is 
>>> in the noise. Furthermore, kzfree() is an existing facility 
>>> already in use. If it's reused by your patches that brings 
>>> further advantages: kzfree(), if it has any bugs, will be fixed. 
>>> While if you add a parallel facility kzfree() stays broken.
>> Have you benchmarked the addition of these changes? I would like 
>> to see benchmarks done for these (crypto api included), since you 
>> are proposing them.
> 
> You have it the wrong way around. _You_ have the burden of proof 
> here really, you are trying to get patches into the upstream kernel. 
> I'm not obliged to do your homework for you. I might be wrong, and 
> you can prove me wrong.

Larry's patches do not do what you propose they
should do, so why would he have to benchmark your
idea?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
