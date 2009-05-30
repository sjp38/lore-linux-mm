Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B25066B00CE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 10:09:35 -0400 (EDT)
Message-ID: <4A213DF9.2040207@redhat.com>
Date: Sat, 30 May 2009 10:08:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
References: <20090522073436.GA3612@elte.hu>	 , <20090530054856.GG29711@oblivion.subreption.com>	 , <1243679973.6645.131.camel@laptop>	 <4A211BA8.8585.17B52182@pageexec.freemail.hu> <1243689707.6645.134.camel@laptop>
In-Reply-To: <1243689707.6645.134.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: pageexec@freemail.hu, "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Sat, 2009-05-30 at 13:42 +0200, pageexec@freemail.hu wrote:
>>> Why waste time on this?
>> e.g., when userland executes a syscall, it 'can run kernel code'. if that kernel
>> code (note: already exists, isn't provided by the attacker) gives unintended
>> kernel memory back to userland, there is a problem. that problem is addressed
>> in part by early sanitizing of freed data.
> 
> Right, so the whole point is to minimize the impact of actual bugs,
> right? So why not focus on fixing those actual bugs? Can we create tools
> to help us find such bugs faster? We use sparse for a lot of static
> checking, we create things like lockdep and kmemcheck to dynamically
> find trouble.
> 
> Can we instead of working around a problem, fix the actual problem?

Do you drive without seatbelts, because the real fix
is to stay out of accidents?

No software is bug free.

Let me repeat that: no software is bug free.

This means your security strategy cannot rely on
software being bug free.

This is why every security strategy is a "belt and
suspenders" thing, where:
1) code is audited to remove as many bugs as possible, and
2) the system is configured in such a way that the impact
    of the remaining bugs is limited

For example, if you check your own system you will find
that system daemons like bind and httpd run with limited
privileges.  This is done because, again, no software is
bug free and you want to limit the damage that can be done
after a bug is exploited.


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
