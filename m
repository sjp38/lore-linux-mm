Subject: Re: Free memory level in 2.6.16?
References: <1160034527.23009.7.camel@localhost>
From: Andi Kleen <ak@suse.de>
Date: 05 Oct 2006 22:01:53 +0200
In-Reply-To: <1160034527.23009.7.camel@localhost>
Message-ID: <p73k63ezg3y.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Bergman <sbergman@rueb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steve Bergman <sbergman@rueb.com> writes:

> Due to some problems I was having with the CentOS4.4 kernel, I just
> moved a box (x86 with 4GB ram) to 2.6.16.29 from kernel.org.
> 
> All is well, but I am curious about one thing.  This is a fairly memory
> hungry box, serving about 40 gnome desktops via xdmcp.  All VM settings
> are at the default.  Swappiness=60, min_free_kbytes=3831.
> 
> However, it seems to seek out about 150MB for the level of free memory
> that it maintains.  Typically I see somewhere between 100MB an 500MB in
> swap, buffers+cache is about 500MB, and 150MB is free.
> 
> If I cat from /dev/md0 to /dev/null, the free memory does go down, to
> 25MB or so,  but then I can watch as it seeks out about 150MB of free
> memory.
> 
> To me, free memory is wasted memory.  Is this a bug or a feature?

Normally it keeps some memory free for interrupt handlers which
cannot free other memory. But 150MB is indeed a lot, especially
it's only in the ~900MB lowmem zone.

You could play with /proc/sys/vm/lowmem_reserve_ratio but must
likely some defaults need tweaking.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
