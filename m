Date: Thu, 16 Nov 2000 16:01:07 +0100 (MET)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: RE: KPATCH] Reserve VM for root (was: Re: Looking for better VM)
In-Reply-To: <200011142012.VAA00150@bug.ucw.cz>
Message-ID: <Pine.LNX.4.30.0011161513480.20626-100000@fs129-190.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pavel-velo@bug.ucw.cz
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jan 1997 pavel-velo@bug.ucw.cz wrote:

>    >main() { while(1) if (fork()) malloc(1); }
>    >With the patch below I could ssh to the host and killall the offending
>    >processes. To enable reserving VM space for root do
> what about main() { while(1) system("ftp localhost &"); }
> This. or so,ething similar should allow you to kill your machine
> even with your patch from normal user account

This or something similar didn't kill the box [I've tried all local
DoS from Packetstorm that I could find]. Please send a working
example. Of course probably it's possible to trigger root owned
processes to eat memory eagerly by user apps but that's a problem in
the process design running as root and not a kernel issue.

Note, I'm not discussing "local user can kill the box without limits",
I say Linux "deadlocks" [it starts its own autonom life and usually
your only chance is to hit the reset button] when there is continuous
VM pressure by user applications. If you think fork() kills the box
then ulimit the maximum number of user processes (ulimit -u). This is
a different issue and a bad design in the scheduler (see e.g. Tru64
for a better one).

BTW, I have a new version of the patch with that Linux behaves much
better from root's point of view when the memory is more significantly
overcommited. I'll post it if I have time [and there is interest].

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
