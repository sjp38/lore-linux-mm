Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 351B05F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 22:52:19 -0400 (EDT)
Message-ID: <4CC0FBDC.4010700@zytor.com>
Date: Thu, 21 Oct 2010 19:50:04 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [GIT PULL] memblock for 2.6.37
References: <201010220050.o9M0ognt032167@hera.kernel.org> <AANLkTi=2tPU6qwuoOEfS7NfsNX+7vCYhvkHzNOcx4Gf3@mail.gmail.com>
In-Reply-To: <AANLkTi=2tPU6qwuoOEfS7NfsNX+7vCYhvkHzNOcx4Gf3@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, CAI Qian <caiqian@redhat.com>, "David S. Miller" <davem@davemloft.net>, Felipe Balbi <balbi@ti.com>, Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Kevin Hilman <khilman@deeprootsystems.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <michael@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Russell King <rmk@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner <tglx@linutronix.de>, Tomi Valkeinen <tomi.valkeinen@nokia.com>, Vivek Goyal <vgoyal@redhat.com>, Yinghai Lu <yinghai@kernel.org>, ext Grazvydas Ignotas <notasas@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/21/2010 06:59 PM, Linus Torvalds wrote:
> On Thu, Oct 21, 2010 at 5:50 PM, H. Peter Anvin <hpa@linux.intel.com> wrote:
>>
>> The unmerged branch is at:
>>
>>  git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core-memblock-for-linus
>>
>> The premerged branch is at:
>>
>>  git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core-memblock-for-linus-merged
> 
> I always tend to take the unmerged version, because I want to see what
> the conflicts are (it gives me some view of what clashes), but when
> people do pre-merges I then try to compare my merge against theirs.
> 

Sounds like a very good idea.  I'll take it as a request to continue to
do both if there are anything but trivial conflicts.


> However, in this case, your pre-merged version differs. But I think
> it's your merge that was incorrect. You left this line:
> 
>    obj-$(CONFIG_HAVE_EARLY_RES) += early_res.o
> 
> in kernel/Makefile, even though kernel/early_res.c is gone.
> 
> I'll push out my merge, but please do verify that it all looks ok.
> 
>                                Linus
> 

You're right, my mistake.  Thanks for checking and fixing it up.

I will pull your tree later and test if and add the fixes for the other
trees.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
