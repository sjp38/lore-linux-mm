MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14652.24687.633129.713085@rhino.thrillseeker.net>
Date: Mon, 5 Jun 2000 22:22:39 -0400 (EDT)
From: Billy Harvey <Billy.Harvey@thrillseeker.net>
Subject: Re: [uPatch] Re: Graceful failure?
In-Reply-To: <m2r9abev5m.fsf@boreas.southchinaseas>
References: <Pine.LNX.4.21.0006051258370.31069-100000@duckman.distro.conectiva>
	<m2r9abev5m.fsf@boreas.southchinaseas>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Fremlin writes:

 > Rik van Riel <riel@conectiva.com.br> writes:

 > > On Mon, 5 Jun 2000, Billy Harvey wrote:

 > > > A "make -j" slowly over the course of 5 minutes drives the load
 > > > to about 30.  At first the degradation is controlled, with
 > > > sendmail refusing service, but at about 160 process visible in
 > > > top, top quits updating (set a 8 second updates), showing about
 > > > 2 MB swap used.  At this point it sounds like the system is
 > > > thrashing.

 > > That probably means you're a lot more in swap now and top
 > > has stopped displaying before you really hit the swap...

 > Allow me to hype my patch again. Could someone please test it?

 > It improves performance markedly (no horrible pauses in
 > vmscan.c:swap_out under heavy load).

I first tried Rik's two-line patch, and saw no noticeable difference
in the kernel's eventual failure.  I then tried John's vmscan.c patch
and observed the system slow to a crawl under a "make -j", but never
actually stop.  There were plenty of SIGKILLs sent to gcc during the
compilation by something.  After about an hour, several ^C's sent
killed the compilation and all was well.

Noticeable in this was that the swap seemed to be barely touched at
all (still showing 28K used out of 68M available).  FWIW, I am using
shm (I think it was smbmount that required it), which Rik alluded to
earlier as being suspect.

I see ac9 is out now - did either of these patches make it into that?

Regards,
Billy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
