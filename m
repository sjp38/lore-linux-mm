Date: Fri, 6 Aug 1999 09:33:32 +0100 (GMT)
From: Matthew Kirkwood <weejock@ferret.lmh.ox.ac.uk>
Subject: Re: SHM, Issue attaching Oracle >500MB shared mem
In-Reply-To: <199908051636781.SM00258@mailhost.directlink.net>
Message-ID: <Pine.LNX.4.10.9908060928050.15557-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Javan Dempsey <raz@mailhost.directlink.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Aug 1999, Javan Dempsey wrote:

> We're currently running a number of Linux based ia32 Oracle 8.0.5 DB
> Servers, and we seem to be running into a problem with attaching to >
> 500MB shared mem. I've increased SHMMAX and tweaked various other
> things in an attempt to fix the problem. Nothing seems to work, no
> matter what SHMMAX is set to, or anything else. SVRMGRL gives this
> error when trying to startup -

Where did you change this value?

Your capitals would seem to indicate that you hacked on the kernel,
but the new place to tune such parameters is /proc/sys/kernel/shmmax.

It would seem to default to 32Mb, which isn't nearly enough for a
big Oracle setup.

# echo `expr 1024 \* 1024 \* 1024` > /proc/sys/kernel/shmmax

should allow you 1Gb of shared memory.

Matthew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
