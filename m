From: pavel-velo@bug.ucw.cz
Message-Id: <200011142012.VAA00150@bug.ucw.cz>
Subject: RE: KPATCH] Reserve VM for root (was: Re: Looking for better VM)
Date: Wed, 1 Jan 1997 22:21 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi!

   >I've also never said OOM killer should be disabled. In theory the
   >non-overcommitting systems deadlock, Linux survives. Ironically
   >usually it's just the opposite in practice. Any user can
   >deadlock/crash Linux [default install, no quotas] but not an
   >non-overcommitting system [root can clean up]. Here is an example code
   >"simulating" a leaking daemon that will "deadlock" Linux even with
   >your OOM killer patch [that is anyway *MUCH* better than the actually
   >non-existing one in 2.2.x kernels]:
   >
   >main() { while(1) if (fork()) malloc(1); }
   >
   >With the patch below I could ssh to the host and killall the offending
   >processes. To enable reserving VM space for root do 

what about main() { while(1) system("ftp localhost &"); }

This. or so,ething similar should allow you to kill your machine even with your
patch from normal user account

														Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
