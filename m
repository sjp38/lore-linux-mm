Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EE2F56B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 08:52:52 -0400 (EDT)
Date: Wed, 25 May 2011 14:52:05 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: (Short?) merge window reminder
In-Reply-To: <4DDC2236.6010608@mit.edu>
Message-ID: <alpine.LRH.2.00.1105251447000.1874@twin.jikos.cz>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com> <20110523192056.GC23629@elte.hu> <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com> <4DDC2236.6010608@mit.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@MIT.EDU>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Tue, 24 May 2011, Andy Lutomirski wrote:

> Also, when someone in my lab installs <insert ancient enterprise distro 
> here> on a box that's running software I wrote that needs to support 
> modern high-speed peripherals, then I can say "What?  You seriously 
> expect this stuff to work on Linux 2007?  Let's install a slightly less 
> stable distro from at least 2010."  This sounds a lot less nerdy than 
> "What?  You seriously expect this stuff to work on Linux 2.6.27?  Let's 
> install a slightly less stable distro that uses at least 2.6.36."

I hate to jump into this excellent example of bike-shedding discussion, 
but anyway ...

Your example doesn't really reflect reality.

It's common for older enterprise distributions to gradually incorporate a 
lot of backported code (and most importantly new hardware support 
code/drivers) while not upgrading the kernel major version. So yes, you 
will in reality get 2.6.16 kernel (at least according to uname) with 
libata with newer service packs of SLES 10, for example (and you could 
find many of those across distributions).

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
