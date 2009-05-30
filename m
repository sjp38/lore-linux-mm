Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E94AC5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 18:10:27 -0400 (EDT)
Date: Sun, 31 May 2009 00:10:24 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530221024.GA23204@elte.hu>
References: <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A21999E.5050606@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Larry H." <research@subreption.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Rik van Riel <riel@redhat.com> wrote:

> Ingo Molnar wrote:
>> * Larry H. <research@subreption.com> wrote:
>>> On 20:21 Sat 30 May     , Ingo Molnar wrote:
>
>>>> Freeing keys is an utter slow-path (if not then the clearing is  
>>>> the least of our performance worries), so any clearing cost is in 
>>>> the noise. Furthermore, kzfree() is an existing facility already in 
>>>> use. If it's reused by your patches that brings further advantages: 
>>>> kzfree(), if it has any bugs, will be fixed. While if you add a 
>>>> parallel facility kzfree() stays broken.
>>> Have you benchmarked the addition of these changes? I would like to 
>>> see benchmarks done for these (crypto api included), since you are 
>>> proposing them.
>>
>> You have it the wrong way around. _You_ have the burden of proof here 
>> really, you are trying to get patches into the upstream kernel. I'm not 
>> obliged to do your homework for you. I might be wrong, and you can 
>> prove me wrong.
>
> Larry's patches do not do what you propose they should do, so why 
> would he have to benchmark your idea?

My (and AFAICT Pekka's) suggestion was to use unconditional kzfree() 
in the few places where it matters: crypto/WEP key and input stream 
freeing.

His counter-argument was that it is unacceptable overhead - without 
any supporting data. I dont think the overhead is a problem in those 
cases (without any supporting data either).

Obviously the argument is best settled by measurements. Done by 
whoever wants to push this code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
