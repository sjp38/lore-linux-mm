Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA26731
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 12:05:14 -0400
Received: from mirkwood.dummy.home (root@anx1p7.phys.uu.nl [131.211.33.96])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id SAA04397
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 18:05:07 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id SAA32603 for <linux-mm@kvack.org>; Thu, 25 Jun 1998 18:00:15 +0200
Date: Thu, 25 Jun 1998 18:00:15 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Memory management. (fwd)
Message-ID: <Pine.LNX.3.96.980625175920.31988G-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I found this message in my INBOX today. It might be interesting
to read...
(I know that Eric and Stephen are working on eliminating said
problem)

Rik.

---------- Forwarded message ----------
Date: Thu, 25 Jun 1998 16:22:11 +0200
From: Stefane Fermigier <fermigie@math.jussieu.fr>
To: H.H.vanRiel@phys.uu.nl
Subject: Memory management.

Hi,

thanks for submiting your page to Linux Center.

I have a question for the MM team: yesterday, there was a seminar on free
software at the Pari 8 university, and someone called Louis Leon, well
known as a benchmarker of workstations performances for the french
magazine ``LMB'' asked the following rather technical question.

He said that under most circumstances, Linux was able to get the best
results, but that when huge amounts of data were to be transfered from and
then to disk during the computations, performances were dropping badly.
This would appear when the size of the files that are manipulated 
is _half_ of the RAM of the systems, when one would think that RAM 
just (approximately) _equal_ to the size of the files would be enough.
According to Remy Card, this might be a question of ``double buffering'',
that is, the data would go to _two_ different RAM buffers instead of just
one.

A guy from the FreeBSD, who was speaking at the conference, was happy
to say that this doesn't happen under FreeBSD.

What do you think of this? Is it something that you are aware of? Are
you working on that kind of problems?

Regards,

	S.

-- 
Stefane Fermigier, MdC a l'Universite Paris 7. Tel: 01.44.27.61.01 (Bureau).
<www.math.jussieu.fr/~fermigie/>, <www.aful.org>, <www.linux-center.org>. 
"A complex system that works is invariably found to have evolved from a
simple system that worked." Grady Booch.
