Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 242496B0062
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 04:27:35 -0500 (EST)
Subject: Re: [Xen-devel] Re: OOPS and panic on 2.6.29-rc1 on xen-x86
From: Christophe Saout <christophe@saout.de>
In-Reply-To: <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com>
References: <20090112172613.GA8746@shion.is.fushizen.net>
	 <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 13 Jan 2009 10:25:31 +0100
Message-Id: <1231838731.4823.2.camel@leto.intern.saout.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, xen-devel@lists.xensource.com
List-ID: <linux-mm.kvack.org>

Hi Bryan,

> I've bisected the bug in question, and the faulty commit appears to be:
> commit e97a630eb0f5b8b380fd67504de6cedebb489003
> Author: Nick Piggin <npiggin@suse.de>
> Date:   Tue Jan 6 14:39:19 2009 -0800
> 
>     mm: vmalloc use mutex for purge
> 
>     The vmalloc purge lock can be a mutex so we can sleep while a purge is
>     going on (purge involves a global kernel TLB invalidate, so it can take
>     quite a while).
> 
>     Signed-off-by: Nick Piggin <npiggin@suse.de>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> The bug is easily reproducable by a kernel build on -j4 - it will
> generally OOPS and panic before the build completes.
> Also, I've tested it with ext3, and it still occurs, so it seems
> unrelated to btrfs at least :)

Nice!

Reverting this also fixes the BUG() I was seeing when testing the Dom0
patches on 2.6.29-rc1+tip.  It just ran stable for an hour compiling
gimp and playing music on my notebook (and then I had to leave).

Thanks,
	Christophe


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
