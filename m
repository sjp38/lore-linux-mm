Date: Wed, 17 Nov 1999 05:18:33 +0100 (CET)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: [patch] zoned-2.3.28-K2 [ramdisk OOM]
In-Reply-To: <Pine.LNX.4.10.9911161329430.3924-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.Linu.4.10.9911170454270.418-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 1999, Ingo Molnar wrote:

> 
> the latest patchset is at:
> 
> 	http://www.redhat.com/~mingo/zoned-2.3.28-K2
> 
> this patch is supposed to fix all known problems (including the 16MB kept
> free thing), let me know if there is still something left.

Hi Ingo,

I ran into an OOM problem while testing.  Having heard someone mention
ramdisk troubles, I enabled it and booted with ramdisk_size=16384. Made
an fs (mke2fs /dev/ram0) mounted it and ran Bonnie -s 12 a few times.
Result was terminal OOM.  Everything else seems to work fine, so this
may just be a driver bug(?).  I can't revert my tree just yet to find
out for sure.

Memleak results with line numbers translated to zoned-2.3.28-K2 stock.

buffer.c:1054: 15698 13710 15260 DELTA: 28970
filemap.c:1852: 3430 3448 3921 DELTA: 7369
slab.c:507: 468 173 142 DELTA: 315

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
