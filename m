Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 082326B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 15:42:20 -0400 (EDT)
Date: Sun, 12 Jul 2009 21:59:47 +0200 (CEST)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [BUG 2.6.30] Bad page map in process
In-Reply-To: <20090712095731.3090ef56@siona>
Message-ID: <Pine.LNX.4.64.0907122151010.13280@axis700.grange>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
 <Pine.LNX.4.64.0907101900570.27223@sister.anvils> <20090712095731.3090ef56@siona>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, kernel@avr32linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Jul 2009, Haavard Skinnemoen wrote:

> On Fri, 10 Jul 2009 19:34:06 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > I've not looked up avr32 pte layout, is 13f26ed4 good or bad?
> > I hope avr32 people can tell more about the likely cause.
> 
> It looks OK for a user mapping, assuming you have at least 64MB of
> SDRAM (the SDRAM starts at 0x10000000) -- all the normal userspace flags
> are set and all the kernel-only flags are unset. It's marked as
> executable, so it could be that the segfault was caused by the CPU
> executing the wrong code.
> 
> The virtual address 0x4377f876 is a bit higher than what you normally
> see on avr32 systems, but there's not necessarily anything wrong with
> it -- userspace goes up to 0x80000000.
> 
> Btw, is preempt enabled when you see this?

No, preempt was off.

I can give a couple more details to the problem:

1. it might well be hardware-related.

2. the specific BUG that I posted originally wasn't very interesting, 
because it wasn't the first one. Having read a few posts I wasn't quite 
sure how really severe this BUG was, i.e., whether or not it requiret a 
reboot. There used to be a message like "reboot is required" around this 
sort of exceptions, but then it has been removed, so, I thought, it wasn't 
required any more. But the fact is, that once one such BUG has occurred, 
new ones will come from various applications and eventually the system 
will become unusable.

3. What makes it a kind of hard to believe that it's a hardware problem, 
is that up to now we have only been able to produce the _first_ such 
segfault and BUG with just one specific user-space application. In 
principle the application doesn't do anything critical. It just uses Qt ta 
draw on the framebuffer. And we have been able to reproduce the problem by 
running just a truncated version of the app - just the Qt and local class 
initialisation. Running such an application repeatedly eventually produces 
a segfault, and at some point also the "bad page map" BUG.

We're currently trying to investigate and fix the hardware, will post our 
results.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
