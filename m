Received: from ucla.edu (pool0008-max4.ucla-ca-us.dialup.earthlink.net [207.217.13.200])
	by panther.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id AAA00274
	for <linux-mm@kvack.org>; Sat, 16 Sep 2000 00:02:37 -0700 (PDT)
Message-ID: <39C31C9F.1C202CD8@ucla.edu>
Date: Sat, 16 Sep 2000 00:09:19 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Happiness with t8-vmpatch4 (was Re:  Does page-aging really work?)
References: <Pine.LNX.4.21.0009081937020.1206-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guys - 
	I have done a few small tests on t8-vmpatch4 (64Mb RAM, 166Mhz UP
PPro), and I must say that I am very happy with the results.  More
comparison with test8 vanilla confirms that Rik's version is much more
responsive, also that Rik is (or course) correct - unused process are
indeed swapped out, but shared pages from (I assume) libc remain.

	Observations:
   1. test8-vmpatch4 does not swap very much at first, but then swaps a
lot of memory in a short time when triggered.
	Specifically, I untarred a kernel source tree and saw NO swapping . 
The working set was NOT evicted :)  I then started more programs, and
saw that the cache shrunk a lot: still no swapping.  Then I ran the
untar again, and the kernel swapped out 22Mb very quickly.  However, I
must say that it was still very smooth - I didn't even notice the
swapping until I looked at xosview; normally it is quite audible.  Also,
the choice of pages for swapping out seemed to be VERY accurate - there
was virtually no page-in as long as I was watching...

  2. I guess we could wish that unused programs got swapped a bit sooner
instead of all at once - but presumably that can be tuned.

	Congrats on the great code!  Tuning does indeed seem to be fixing the
problems that I saw before.

thanks again,
-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
