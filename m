Subject: Re: page faults
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com> 	<m1wvsc8ytq.fsf@flinx.hidden> <14356.37630.420222.582735@liveoak.engr.sgi.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 26 Oct 1999 09:00:35 -0500
In-Reply-To: "William J. Earl"'s message of "Mon, 25 Oct 1999 10:27:26 -0700 (PDT)"
Message-ID: <m1ln8qcjcs.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"William J. Earl" <wje@cthulhu.engr.sgi.com> writes:

> Eric W. Biederman writes:
> ...
>  > If the hardware cannot support two processors hitting the region simultaneously,
>  > (support would be worst case the graphics would look strange)
>  > you could have problems.
> ...
>       One could reasonably take the view that a threads-aware graphics library
> should be thread-safe.  That is, if the hardware needs to have concurrent
> threads in a single process serialize access to the hardware, then the 
> library plugin for that hardware should do the required serialization.
> 
>       This of course the neglects the question of whether a broken
> user-mode program could damage the hardware, but then a broken
> single-threaded user-mode program, with no other programs using the
> hardware, could just as easily damage the hardware.  That is, if the
> hardware is not safe for direct access in general, threading does not
> make it any less safe.

Except on logically ``single thread'' hardware. Which I have heard exists.
Where the breakage point is simple writers hitting the harware at the
same time.

And since James work seems to have been how to protect the world from
broken hardware. . .

Also for the sgi hardware the design I believe is with the kernel
doing all of the thread/porocess synchronization by mapping/unmapping
the hardware.  That technique does not work on linux.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
