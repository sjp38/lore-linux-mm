Date: Sat, 20 Sep 2003 14:49:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Process in D state (was Re: 2.6.0-test5-mm2)
Message-Id: <20030920144902.47c2c7c4.akpm@osdl.org>
In-Reply-To: <200309201534.36362.rob@landley.net>
References: <20030914234843.20cea5b3.akpm@osdl.org>
	<200309201534.36362.rob@landley.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rob@landley.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rob Landley <rob@landley.net> wrote:
>
> But, twice in a row now I've made this happen:
> 
>   1391 pts/1    S      0:00 /bin/bash
>   1419 pts/1    S      0:00 /bin/sh ./build.sh
>   1423 pts/1    S      0:00 /bin/bash 
>  /home/landley/pending/newfirmware/make-stat
>   1447 pts/1    D      0:04 tar xvjf 
>  /home/landley/pending/newfirmware/base/linux
>   1448 pts/1    S      0:37 bzip2 -d
> 
>  All I have to do is run my script, it tries to extract the kernel tarball, and 
>  tar hangs in D state.
> 
>  How do I debug this?  (Is there some way to get the output of Ctrl-ScrLk to go 
>  to the log instead of just the console?  My system isn't currently hung, it's 
>  just got a process that is.  This process being hung prevents my partitions 
>  from being unmounted on shutdown, which is annoying.)

sysrq-T followed by `dmesg -s 1000000 > foo' should capture it.

>  Other miscelanous bugs: cut and paste only works some of the time (it pastes 
>  blanks other times, dunno if this was -test5 or -mm2; it worked fine in 
>  -test4).

vgacon? fbcon? X11?

>  The key repeat problem is still there, although still highly intermittent.

I think Andries says that some keyboards just forget to send up codes. 
We'll probably need some kernel boot parameter to support these, using the
keyboard's silly native autorepeat.

>  The boot hung enabling swap space once.  I don't know why.  (Init was already 
>  running and everything...)

Probably the O_DIRECT locking bug: I had `rpmv' getting stuck on boot for a
while.  mm3 fixed that.  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
