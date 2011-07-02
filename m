Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E5AC96B0012
	for <linux-mm@kvack.org>; Sat,  2 Jul 2011 10:15:14 -0400 (EDT)
Subject: Re: [PATCH 2/2] powerpc/mm: Fix memory_block_size_bytes() for
 non-pseries
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20110702102333.GC17482@elte.hu>
References: <1308013071.2874.785.camel@pasglop>
	 <20110701121516.GD28008@elte.hu> <1309562112.14501.257.camel@pasglop>
	 <20110702102333.GC17482@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 03 Jul 2011 00:15:01 +1000
Message-ID: <1309616101.14501.262.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, 2011-07-02 at 12:23 +0200, Ingo Molnar wrote:
> It's certainly not a hard rule - but note that the file in question 
> (arch/powerpc/platforms/pseries/hotplug-memory.c) has a rather 
> inconsistent comment style, sometimes even within the same function:
> 
>         /*
>          * Remove htab bolted mappings for this section of memory
>          */
> ...
> 
>         /* Ensure all vmalloc mappings are flushed in case they also
>          * hit that section of memory
>          */
> 
> That kind of inconsistency within the same .c file and within the 
> same function is not defensible with a "style is a matter of taste" 
> argument.

Right, that's a matter of different people with different taste mucking
around with the same file I suppose.

Most of this probably predates my involvement as a maintainer but even
if not (and I really can't be bothered digging into the history), it
might very well be something I didn't pay attention to while reviewing.

Seriously, it's so low on the scale of what matters ... I'm sure we both
have more valuable stuff to spend our time and energy on :-)

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
