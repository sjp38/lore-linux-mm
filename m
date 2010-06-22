Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4CE506B01D2
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 08:14:25 -0400 (EDT)
Date: Tue, 22 Jun 2010 21:14:01 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] kmemleak: config-options: Default buffer size for kmemleak
Message-ID: <20100622121401.GC20140@linux-sh.org>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com> <1277189909-16376-1-git-send-email-sankar.curiosity@gmail.com> <4C20702C.1080405@cs.helsinki.fi> <1277196403-20836-1-git-send-email-sankar.curiosity@gmail.com> <20100622113135.GB20140@linux-sh.org> <1277208351.29532.5.camel@e102109-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277208351.29532.5.camel@e102109-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Sankar P <sankar.curiosity@gmail.com>, penberg@cs.helsinki.fi, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, lrodriguez@atheros.com, rnagarajan@novell.com, teheo@novell.com, linux-mm@kvack.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 01:05:51PM +0100, Catalin Marinas wrote:
> On Tue, 2010-06-22 at 12:31 +0100, Paul Mundt wrote:
> > On Tue, Jun 22, 2010 at 02:16:43PM +0530, Sankar P wrote:
> > > If we try to find the memory leaks in kernel that is
> > > compiled with 'make defconfig', the default buffer size
> > > of DEBUG_KMEMLEAK_EARLY_LOG_SIZE seem to be inadequate.
> > >
> > > Change the buffer size from 400 to 1000,
> > > which is sufficient for most cases.
> > >
> > Or you could just bump it up in your config where you seem to be hitting
> > this problem. The default of 400 is sufficient for most people, so
> > bloating it up for a corner case seems a bit premature. Perhaps
> > eventually we'll have no choice and have to tolerate the bloat, as we did
> > with LOG_BUF_SHIFT, but it's not obvious that we've hit that point with
> > kmemleak yet.
> 
> I agree. The 400 seems to be sufficient with standard kernel
> configurations (I usually try some of the Ubuntu configs on x86). The
> error message is hopefully clear enough about what needs to be changed.
> 
> The defconfig change for this specific platform may be a better option
> but I thought defconfigs are to provide a stable (and maybe close to
> optimal) configuration without all the debugging features enabled
> (especially those slowing things down considerably).
> 
I would be fine with that, but I don't see any correlation between the
posted dmesg and the defconfig? I've run the config in question without
hitting problems, so I'm a bit confused as to why that particular config
was singled out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
