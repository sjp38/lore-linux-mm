Subject: Re: A possible winner in pre7-8
References: <Pine.LNX.4.10.10005082332560.773-100000@penguin.transmeta.com>
	<3917C33F.1FA1BAD4@sgi.com> <yttln1jtyqg.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "09 May 2000 19:33:27 +0200"
Date: 10 May 2000 05:29:48 +0200
Message-ID: <yttvh0nozf7.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "juan" == Juan J Quintela <quintela@fi.udc.es> writes:

Hi

juan> No way, here my tests run two iterations, and in the second iteration
juan> init was killed, and the system become unresponsive (headless machine,
juan> you know....).  I have no time now to do a more detailed report, more
juan> information later today.

I have been checking today pre7-8 + manfred patch.
(test as always while (true); do time ./mmap002; done).
Things have improved a lot from pre7-6, but they are not perfect.

With that patch I have obtained the following times:

real    2m41.772s
user    0m16.610s
sys     0m12.470s

(this is a typical value, there are fluctuations between 2m35 and
2m54).
It begin to kill processes after the 10th iteration.  After that, the
machine freezes.

The results for pre7-8 + manfred patch + andrea classzone 27 is

real    2m7.622s
user    0m15.480s
sys     0m8.240s

(almost no variations between runs +-1second).  And it is rock solid
here, no freezes at all.

The results for 2.2.15 are:

real    1m57.619s
user    0m16.320s
sys     0m11.820s

but it kills processes after 10/12 iterations.

I hope this helps.

Later, Juan.



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
