Subject: Re: page faults
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com> <m1wvsc8ytq.fsf@flinx.hidden> <14356.37630.420222.582735@liveoak.engr.sgi.com>
From: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
Date: 26 Oct 1999 15:50:08 +0200
In-Reply-To: "William J. Earl"'s message of "Mon, 25 Oct 1999 10:27:26 -0700 (PDT)"
Message-ID: <kfy7lkaqlin.fsf@kieraypc01.p.y.ki.era.ericsson.se>
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

The hardware _is_ safe for direct access, but _not_ while the
accelerator is running.

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
