From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14357.60716.436104.461584@liveoak.engr.sgi.com>
Date: Tue, 26 Oct 1999 11:04:28 -0700 (PDT)
Subject: Re: page faults
In-Reply-To: <m1ln8qcjcs.fsf@flinx.hidden>
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com>
	<m1wvsc8ytq.fsf@flinx.hidden>
	<14356.37630.420222.582735@liveoak.engr.sgi.com>
	<m1ln8qcjcs.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman writes:
 > "William J. Earl" <wje@cthulhu.engr.sgi.com> writes:
...
 > >       This of course the neglects the question of whether a broken
 > > user-mode program could damage the hardware, but then a broken
 > > single-threaded user-mode program, with no other programs using the
 > > hardware, could just as easily damage the hardware.  That is, if the
 > > hardware is not safe for direct access in general, threading does not
 > > make it any less safe.
 > 
 > Except on logically ``single thread'' hardware. Which I have heard exists.
 > Where the breakage point is simple writers hitting the harware at the
 > same time.
 > 
 > And since James work seems to have been how to protect the world from
 > broken hardware. . .

       Threading cannot make this more hazardous.  Suppose two threads, A and B,
accessing the hardware concurrently, were each to do a series of instructions
I[i].  Suppose these instructions were interleaved:

       I[0]-A
       I[0]-B
       I[1]-A
       I[1]-B
       I[2]-A
       I[2]-B
       ...

and that this broke the hardware.  Then suppose that, instead, 
thread A simply executed a series of instructions with same effect
on the hardware as the above series of instructions (with thread B
not executing at all).  Then a single thread would damage the hardware.
That is, if some series of user-mode instructions can damage the hardware,
then broken threaded programs (where "broken" includes not adequately
serializing their operations) are no more or less hazardous than
a broken single threaded program.  If you rely on correct user-mode code
(neglecting threading), then you are always at risk of having a broken
application damage the hardware.

 > Also for the sgi hardware the design I believe is with the kernel
 > doing all of the thread/porocess synchronization by mapping/unmapping
 > the hardware.  That technique does not work on linux.

     That is the way IRIX handles the hardware.  It is not trivially
implementable on Linux.  The more important point is that SGI hardware
can be context-switched.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
