Date: Thu, 1 Jun 2000 08:26:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Poor I/O Performance (10x slower than 2.2)
In-Reply-To: <14645.55430.196015.898700@styx.uwaterloo.ca>
Message-ID: <Pine.LNX.4.21.0006010812450.1172-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Ostrowski <mostrows@styx.uwaterloo.ca>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 May 2000, Michal Ostrowski wrote:

> I've noticed some horrible I/O performance in recent 2.3
> kernels.  My first guess was that this was related to the
> various VM problems that have been running rampant recently, but
> now I'm not so sure.  Even though I've been reading reports that
> VM performance has been improving, I've seen no noticeable
> impact on my test results.

In fact, 2.3.99-pre9 doesn't contain most of the "new VM" stuff,
that went in in the -ac* series (and seems to have increased
performance very slightly).


	(most test results snipped for brevity)
> 		Celeron 500    Dual PIII 550
> 		test1-ac7      2.3.99-pre9
> 
> Threads Blocks	Time To Complete 1000 Reads (seconds)
> 	per		
> 	Read
> 
> 1	32	22.0	       32.3
> 
> 4	32	20.2	       28.5
> 
> 10	32      290	       345 *

The fact that performance really deteriorates when you
run more threads suggests that this may have something
to do with the elevator code.

> * 2.2.14 runs this test in 34 seconds.

How fast are 2.2.15 and the latest 2.2.16pre kernel?
The elevator code changed after 2.2.14, so it would
be an ideal testbed for seeing what the culprit is.

(VM changed too, but in a completely different way
from how 2.3/2.4 VM changed)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
