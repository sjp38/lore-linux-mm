Date: Sun, 14 Nov 2004 00:37:40 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041113233740.GA4121@x30.random>
References: <20041111112922.GA15948@logos.cnet> <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4194EA45.90800@tebibyte.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Ross <chris@tebibyte.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Fri, Nov 12, 2004 at 05:52:21PM +0100, Chris Ross wrote:
> 
> 
> Chris Ross escreveu:
> >It seems good.
> 
> Sorry Marcelo, I spoke to soon. The oom killer still goes haywire even 
> with your new patch. I even got this one whilst the machine was booting!

On monday I'll make a patch to place the oom killer at the right place.

Marcelo's argument that kswapd is a localized place isn't sound to me,
kswapd is still racing against all other task contexts, so if the task
context isn't reliable, there's no reason why kswapd should be more
reliable than the task context. the trick is to check the _right_
watermarks before invoking the oom killer, it's not about racing against
each other, 2.6 is buggy in not checking the watermarks. Moving the oom
killer in kswapd can only make thing worse, fix is simple, and it's the
opposite thing: move the oom killer up the stack outside vmscan.c.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
