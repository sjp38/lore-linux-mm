Subject: Re: VM benchmarks
From: Koni <koni@sgn.cornell.edu>
In-Reply-To: <401D8D64.8010605@cyberone.com.au>
References: <401D8D64.8010605@cyberone.com.au>
Content-Type: text/plain
Message-Id: <1075908453.6795.149.camel@localhost.localdomain>
Mime-Version: 1.0
Date: Wed, 04 Feb 2004 10:27:33 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It seems to me that increasing -jX doesn't necessarily result in a
linear increase in load since the kernel build process has all kinds of
dependencies and source files distributed in different nested
subdirectories. Thus, it may not be possible for make to spawn X gcc
instances say unless there are at least X independent files to compile
in the directory it's working in. Maybe something about kbuild that I
don't know, I just use make bzImage.

Perhaps it doesn't matter, from the graphs its obvious that you were
able to get the VM to thrash by raising the -jX parameter. Anyway, my
suggestion for something else to test would be to generate a contrived
build where all the source files are in the same directory and the
makefile has no dependencies, just a .c.o rule and a list of files. That
might remove some noise from the -jX variable. Perhaps the efax compile
is more like this, I don't know. Just a thought... might make it easier
to see the effects of small tweaks.

Cheers,
Koni

On Sun, 2004-02-01 at 18:36, Nick Piggin wrote:
> After playing with the active / inactive list balancing a bit,
> I found I can very consistently take 2-3 seconds off a non
> swapping kbuild, and the light swapping case is closer to 2.4.
> Heavy swapping case is better again. Lost a bit in the middle
> though.
> 
> http://www.kerneltrap.org/~npiggin/vm/4/
> 
> At the end of this I might come up with something that is very
> suited to kbuild and no good at anything else. Do you have any
> other ideas of what I should test?
> 
> Nick
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
