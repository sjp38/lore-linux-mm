Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8B9F6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:19:37 -0400 (EDT)
Subject: Re: Detailed Stack Information Patch [0/3]
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090331203014.GR11935@one.firstfloor.org>
References: <1238511498.364.60.camel@matrix>
	 <87eiwdn15a.fsf@basil.nowhere.org> <1238523735.3692.30.camel@matrix>
	 <20090331203014.GR11935@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 23:25:09 +0200
Message-Id: <1238534709.11837.43.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

Hi Andi,

stop complaining about the monitor. This is only an additional
functionality.

The main purpose are part 1 and 2.

> 
> Well some implementation of it. There are certainly runtimes that
> switch stacks. For example what happens when someone uses sigaltstack()?
> 

What should happen with sigaltstack? This is complete independent from
the process and thread stack. So it works.


> That's the alloca() case, but you can disable both with the right options.
> There's still the "recursive function" case.
> 

And no idea ;-) 

> > 
> > The Monitor is part 3/3. And you are right it is not a complete rock
> > solid solution. But it works in many cases and thats is what counts.
> 
> For stack overflow one would think a rock solid solution
> is needed?  After all you'll crash if you miss a case.
> 

Again, the monitor is the only a part of the patch and i know that this
is a issue.

The first two patches will also work without the monitor and if you
don't like the monitor, no problem. It is a CONFIG_... parameter.

> To be honest it seems too much like a special case hack to me
> to include by default. It could be probably done with a systemtap
> script in the same way, but I would really recommend to just
> build with gcc's stack overflow checker while testing together
> with static checking.
> 

Thanks for the hack - I am not sure if you really had a look at my first
posting nor had a look into my code.

We discus about complete different things. You have from user land no
possibility to figure out where is the thread stack locate nor what was
the highest used thread stack address.

That is a simple debug information which can provide very easily which
the first two patches.

Stefani


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
