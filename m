From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <199911171007.KAA23444@raistlin.arm.linux.org.uk>
Subject: Re: [patch] zoned-2.3.28-K2 [ramdisk OOM]
Date: Wed, 17 Nov 1999 10:07:17 +0000 (GMT)
In-Reply-To: <Pine.Linu.4.10.9911170454270.418-100000@mikeg.weiden.de> from "Mike Galbraith" at Nov 17, 99 05:18:33 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Mike Galbraith writes:
> I ran into an OOM problem while testing.  Having heard someone mention
> ramdisk troubles, I enabled it and booted with ramdisk_size=16384. Made
> an fs (mke2fs /dev/ram0) mounted it and ran Bonnie -s 12 a few times.
> Result was terminal OOM.  Everything else seems to work fine, so this
> may just be a driver bug(?).  I can't revert my tree just yet to find
> out for sure.

It's probably my fault - Ingo included my broken patch into K2, and I
have since asked him to revert my procfs changes and include my
task-struct refcounting patch instead.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
