Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53F416B00D4
	for <linux-mm@kvack.org>; Sat, 30 May 2009 10:48:38 -0400 (EDT)
Message-ID: <4A214752.7000303@redhat.com>
Date: Sat, 30 May 2009 10:48:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
References: <20090522073436.GA3612@elte.hu>	 <20090530054856.GG29711@oblivion.subreption.com>	 <1243679973.6645.131.camel@laptop>	 <4A211BA8.8585.17B52182@pageexec.freemail.hu>	 <1243689707.6645.134.camel@laptop>	 <20090530153023.45600fd2@lxorguk.ukuu.org.uk> <1243694737.6645.142.camel@laptop>
In-Reply-To: <1243694737.6645.142.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Sat, 2009-05-30 at 15:30 +0100, Alan Cox wrote:
>>> Right, so the whole point is to minimize the impact of actual bugs,
>>> right? So why not focus on fixing those actual bugs? Can we create tools
>>> to help us find such bugs faster? We use sparse for a lot of static
>>> checking, we create things like lockdep and kmemcheck to dynamically
>>> find trouble.
>>>
>>> Can we instead of working around a problem, fix the actual problem?
>> Why do cars have crashworthiness and seatbelts ? Why not fix the actual
>> problem (driving errors) ? I mean lets face it they make the vehicle
>> heavier, less fuel efficient, less fun and more annoying to use.
> 
> We can't find every crash bug either, yet we still ship the kernel and
> people actually use it too.
> 
> What makes these security bugs so much more important than all the other
> ones?

The fact that we can do something about them.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
